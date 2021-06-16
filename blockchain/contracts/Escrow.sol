pragma solidity ^0.8.4;

contract Escrow {
    address owner;

    //Buyer will stake 2x his purchase value, which the extra will be refunded upon contract fulfillment
    uint8 constant GUARANTEE_RATIO = 2;

    constructor() {
        owner = msg.sender;
    }

    //TODO Reconstruct as enums

    mapping(bytes32 => uint) public productPrice;
    mapping(bytes32 => string) public productHash;
    mapping(bytes32 => address) public seller;
    mapping(bytes32 => address) public buyer;

    mapping(address => uint) public collateral;
    mapping(bytes32 => uint) public expiryDates;

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

    mapping(bytes32 => State) public currentState;

    modifier verifyGuaranteeRatio(bytes32 identifierHash) {
        require(msg.value >= productPrice[identifierHash] * GUARANTEE_RATIO, string(abi.encodePacked("You must deposit ", GUARANTEE_RATIO,
            "x the price of the product as guarantee for the significance of confirming a purchase (Refundable upon contract fulfillment)")));
        _;
    }

    modifier onlyBuyer(bytes32 identifierHash) {
        require(msg.sender == buyer[identifierHash], "Only the designated buyer for this Escrow Agreement can confirm the delivery");
        _;
    }

    modifier onlySeller(bytes32 identifierHash) {
        require(msg.sender == seller[identifierHash], "Only the designated seller for this Escrow Agreement can call this function");
        _;
    }

    modifier notExpired(bytes32 identifierHash) {
        require(currentState[identifierHash] != State.EXPIRED, "This escrow agreement has expired");
        _;
    }

    modifier isExpired(bytes32 identifierHash) {
        require(block.timestamp >= expiryDates[identifierHash], "This escrow agreement has not yet expired");
        _;
    }

    modifier isAwaitingPayment(bytes32 identifierHash) {
        require(currentState[identifierHash] == State.AWAITING_PAYMENT, "Payment already received");
        _;
    }

    modifier isAwaitingDelivery(bytes32 identifierHash) {
        require(currentState[identifierHash] == State.AWAITING_DELIVERY, "Delivery already received");
        _;
    }

    function resetBalances(bytes32 identifierHash) internal {
        collateral[seller[identifierHash]] = 0;
        collateral[buyer[identifierHash]] = 0;
        productPrice[identifierHash] = 0;
    }

    //Seller sends contract productPrice + collateral
    function newEscrow(uint _productPrice, string memory _productHash) public payable returns (bytes32) {
        require(msg.value >= _productPrice * GUARANTEE_RATIO, string(abi.encodePacked("You must deposit ", GUARANTEE_RATIO,
            "x the price of the product as guarantee for the significance of initiating an agreement (Refundable upon contract fulfillment)")));

        collateral[msg.sender] = msg.value - _productPrice;

        bytes32 hash = keccak256(abi.encode(_productPrice, _productHash, msg.sender,
            keccak256(abi.encodePacked(block.timestamp + block.difficulty + uint(
            keccak256(abi.encodePacked(block.coinbase))) / block.timestamp))
            )
        );

        productPrice[hash] = _productPrice;
        productHash[hash] = _productHash;
        seller[hash] = msg.sender;

        emit AgreementHashCreated(msg.sender, hash);

        return hash;
    }

    /* Allows seller to cancel the agreement and retrieves his eth. Can only be called before buyer deposits
     * ether and locks the contract
     */
    function cancelAgreement(bytes32 identifierHash) public {
        require(currentState[identifierHash] == State.AWAITING_PAYMENT, "Contract has been locked, action is now impossible");
        payable(seller[identifierHash]).transfer(collateral[seller[identifierHash]] + productPrice[identifierHash]);

        resetBalances(identifierHash);
        emit AgreementCancelled(msg.sender, identifierHash);

        currentState[identifierHash] = State.EXPIRED;
    }

    function deposit(bytes32 identifierHash) verifyGuaranteeRatio(identifierHash) notExpired(identifierHash) isAwaitingPayment(identifierHash) public payable {
        collateral[msg.sender] = msg.value - productPrice[identifierHash];
        buyer[identifierHash] = msg.sender;

        emit DepositMade(msg.sender, identifierHash);

        currentState[identifierHash] = State.AWAITING_DELIVERY;
    }

    function confirmDelivery(bytes32 identifierHash) onlyBuyer(identifierHash) notExpired(identifierHash) isAwaitingDelivery(identifierHash) public {
        payable(seller[identifierHash]).transfer(collateral[seller[identifierHash]] + (productPrice[identifierHash] * 2));
        payable(buyer[identifierHash]).transfer(collateral[msg.sender]);

        resetBalances(identifierHash);
        emit DeliveryConfirmed(msg.sender, identifierHash);

        currentState[identifierHash] = State.COMPLETE;
    }

    function buyerDidNotConfirm(bytes32 identifierHash) onlySeller(identifierHash) isExpired(identifierHash) public {
        currentState[identifierHash] = State.EXPIRED;
        payable(seller[identifierHash]).transfer(collateral[seller[identifierHash]] + productPrice[identifierHash]);

        emit RefundRequested(msg.sender, identifierHash, collateral[seller[identifierHash]] + productPrice[identifierHash]);
        resetBalances(identifierHash);

        currentState[identifierHash] = State.EXPIRED;
    }
    
    //TODO Escrow via encrypt-and-swap
    function disputeDelivery(bytes32 identifierHash) onlyBuyer(identifierHash) public {

    }

}
