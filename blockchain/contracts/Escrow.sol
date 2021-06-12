pragma solidity ^0.8.4;

contract Escrow {
    address owner;

    //Buyer will stake 2x his purchase value, which the extra will be refunded upon contract fulfillment
    uint8 constant GUARANTEE_RATIO = 2;

    constructor() {
        owner = msg.sender;
    }

    mapping(bytes32 => uint) public productPrice;
    mapping(bytes32 => string) public productHash;
    mapping(bytes32 => address) public seller;
    mapping(bytes32 => address) public buyer;

    mapping(address => uint) public collateral;

    enum State {
        AWAITING_PAYMENT,
        AWAITING_DELIVERY,
        COMPLETE,
        EXPIRED
    }

    event AgreementHashCreated(address indexed seller, bytes32 indexed hash);

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

    modifier notExpired(bytes32 identifierHash) {
        require(currentState[identifierHash] != State.EXPIRED, "This escrow agreement has expired");
        _;
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
    function cancelAgreement() public {

    }

    function deposit(bytes32 identifierHash) verifyGuaranteeRatio(identifierHash) notExpired(identifierHash) public payable {
        collateral[msg.sender] = msg.value - productPrice[identifierHash];
        buyer[identifierHash] = msg.sender;
        currentState[identifierHash] = State.AWAITING_DELIVERY;
    }

    function confirmDelivery(bytes32 identifierHash, bool accepted) onlyBuyer(identifierHash) notExpired(identifierHash) public {
        if(accepted) {
            payable(seller[identifierHash]).transfer(collateral[seller[identifierHash]] + (productPrice[identifierHash] * 2));
            payable(buyer[identifierHash]).transfer(collateral[msg.sender]);

            currentState[identifierHash] = State.COMPLETE;
        } else {

        }
    }

}
