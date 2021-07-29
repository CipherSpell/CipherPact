pragma solidity ^0.8.4;

contract Escrow {
    address owner;

    // Buyer will stake 2x his purchase value, which the extra will be refunded upon contract fulfillment
    uint8 constant GUARANTEE_RATIO = 2;

    constructor() {
        owner = msg.sender;
    }

    struct Agent {
        address addr;
        uint balance;

        bytes32 pubKeyHalf1;
        bytes32 pubKeyHalf2;
    }

    struct Agreement {
        bytes32 agreementIdentifier;
        State currentState;

        uint productPrice;
        string productHash; // placeholder, will have more details once encrypt-and-swap is implemented
        Agent buyer;
        Agent seller;
        uint expiryDate;
    }
    mapping(bytes32 => Agreement) public agreements;

    enum State {
        AWAITING_PAYMENT,
        AWAITING_DELIVERY,
        COMPLETE,
        EXPIRED
    }

    event AgreementHashCreated(address seller, bytes32 indexed hash);
    event DepositMade(address buyer, bytes32 indexed hash);
    event AgreementCancelled(address seller, bytes32 indexed hash);
    event DeliveryConfirmed(address buyer, bytes32 indexed hash);
    event RefundRequested(address seller, bytes32 indexed hash, uint amount);

    modifier verifyGuaranteeRatio(bytes32 identifierHash) {
        require(msg.value >= agreements[identifierHash].productPrice * GUARANTEE_RATIO, string(abi.encodePacked("You must deposit ", GUARANTEE_RATIO,
            "x the price of the product as guarantee for the significance of confirming a purchase (Refundable upon contract fulfillment)")));
        _;
    }

    modifier onlyBuyer(bytes32 identifierHash) {
        require(msg.sender == agreements[identifierHash].buyer.addr, "Only the designated buyer for this Escrow Agreement can confirm the delivery");
        _;
    }

    modifier onlySeller(bytes32 identifierHash) {
        require(msg.sender == agreements[identifierHash].seller.addr, "Only the designated seller for this Escrow Agreement can call this function");
        _;
    }

    modifier notExpired(bytes32 identifierHash) {
        require(agreements[identifierHash].currentState != State.EXPIRED, "This escrow agreement has expired");
        _;
    }

    modifier isExpired(bytes32 identifierHash) {
        require(block.timestamp >= agreements[identifierHash].expiryDate, "This escrow agreement has not yet expired");
        _;
    }

    modifier isAwaitingPayment(bytes32 identifierHash) {
        require(agreements[identifierHash].currentState == State.AWAITING_PAYMENT, "Payment already received");
        _;
    }

    modifier isAwaitingDelivery(bytes32 identifierHash) {
        require(agreements[identifierHash].currentState == State.AWAITING_DELIVERY, "Delivery already received");
        _;
    }

    function resetBalances(bytes32 identifierHash) internal {
        agreements[identifierHash].seller.balance = 0;
        agreements[identifierHash].buyer.balance = 0;

        agreements[identifierHash].productPrice = 0;
    }

    //Seller sends contract productPrice + collateral
    function newEscrow(uint _productPrice, string memory _productHash, uint _expiry) public payable returns (bytes32) {
        require(msg.value >= _productPrice * GUARANTEE_RATIO, string(abi.encodePacked("You must deposit ", GUARANTEE_RATIO,
            "x the price of the product as guarantee for the significance of initiating an agreement (Refundable upon contract fulfillment)")));

        bytes32 hash = keccak256(abi.encode(_productPrice, _productHash, msg.sender,
            keccak256(abi.encodePacked(block.timestamp + block.difficulty + uint(
            keccak256(abi.encodePacked(block.coinbase))) / block.timestamp))
            )
        );

        // placeholder buyer, seller public key set as 0 for now, will readjust when implementing encrypt-and-swap -> See https://github.com/CipherSpell/CipherPact/issues/10
        agreements[hash] = Agreement(hash, State.AWAITING_PAYMENT, _productPrice, _productHash, Agent(address(this),0, 0, 0), Agent(msg.sender, msg.value, 0, 0), _expiry);

        emit AgreementHashCreated(msg.sender, hash);

        return hash;
    }

    /* Allows seller to cancel the agreement and retrieves his eth. Can only be called before buyer deposits
     * ether and locks the contract
     */
    function cancelAgreement(bytes32 identifierHash) public {
        require(agreements[identifierHash].currentState == State.AWAITING_PAYMENT, "Contract has been locked, action is now impossible");
        payable(agreements[identifierHash].seller.addr).transfer(agreements[identifierHash].seller.balance);

        resetBalances(identifierHash);
        emit AgreementCancelled(msg.sender, identifierHash);

        agreements[identifierHash].currentState = State.EXPIRED;
    }

    function deposit(bytes32 identifierHash) verifyGuaranteeRatio(identifierHash) notExpired(identifierHash) isAwaitingPayment(identifierHash) public payable {
        agreements[identifierHash].buyer = Agent(msg.sender, msg.value, 0, 0);

        emit DepositMade(msg.sender, identifierHash);

        agreements[identifierHash].currentState = State.AWAITING_DELIVERY;
    }

    function confirmDelivery(bytes32 identifierHash) onlyBuyer(identifierHash) notExpired(identifierHash) isAwaitingDelivery(identifierHash) public {
        payable(agreements[identifierHash].seller.addr).transfer(agreements[identifierHash].seller.balance + agreements[identifierHash].productPrice);
        payable(agreements[identifierHash].buyer.addr).transfer(agreements[identifierHash].buyer.balance - agreements[identifierHash].productPrice); // Send back buyer's collateral

        resetBalances(identifierHash);
        emit DeliveryConfirmed(msg.sender, identifierHash);

        agreements[identifierHash].currentState = State.COMPLETE;
    }

    function buyerDidNotConfirm(bytes32 identifierHash) onlySeller(identifierHash) isExpired(identifierHash) public {
        agreements[identifierHash].currentState = State.EXPIRED;
        payable(agreements[identifierHash].seller.addr).transfer(agreements[identifierHash].seller.balance);

        emit RefundRequested(msg.sender, identifierHash, agreements[identifierHash].seller.balance);
        resetBalances(identifierHash);

        agreements[identifierHash].currentState = State.EXPIRED;
    }

    /* TODO Escrow via encrypt-and-swap -> See https://github.com/CipherSpell/CipherPact/issues/10
     * Digital products esscrows will be enforced by Public Key Cryptography while physical products
     * escrows, with Kleros (a decentralized arbitration service) https://www.youtube.com/watch?v=WA0-A9lMaSI
     */
    function disputeDelivery(bytes32 identifierHash, string memory _productHash) onlyBuyer(identifierHash) public {
        /*
         * Very naive implementation for now (just acting as a placeholder while I research for better methods). Logic
         * being that the buyer contests the delivery by sending to the contract the hash of the delivered product.
         * Should there be a mismatch, the seller has cheated and the buyer will receive their collateral back, and the
         * seller's slashed. Should there be no mismatch, then the buyer has attempted a fraudulent dispute and will have
         * their collateral slashed.
         *
         * Problems with current implementation: Relies on the honesty of the buyer to submit the real productHash
         * obtained (doesn't make sense if we are advocating for a trustless nature). Because product delivery happens
         * off-chain, nothing stops the buyer from initiating a dispute with a falsy productHash since the contract
         * has no way to know.
         *
         * Potential solution: Add validators to act as arbitrators -> Seller and Buyer both agree on the number of
         * validators -> Seller initiates new Agreement with both Seller and Buyer public keys and generated
         * productHash -> Seller encrypts the digital product with the Buyer's public key -> Seller delivers the digital
         * product to validators via contract-generated .onion link -> Validators hash the product
         *
         * Validators get a percentage of the convicted party's collateral
         */

        Agent memory buyer = agreements[identifierHash].buyer;
        Agent memory seller = agreements[identifierHash].seller;

        bool mismatch = keccak256(abi.encode(_productHash)) != keccak256(abi.encode(agreements[identifierHash].productHash));

        payable(mismatch ? buyer.addr : seller.addr).transfer(mismatch ? buyer.balance : seller.balance);
        resetBalances(identifierHash);

        agreements[identifierHash].currentState = State.COMPLETE;
    }

}
