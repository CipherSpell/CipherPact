pragma solidity ^0.8.1;

contract Escrow {
    address owner;

    //Buyer will stake 2x his purchase value, which the extra will be refunded upon contract fulfillment
    uint8 constant GUARANTEE_RATIO = 2;

    constructor() {
        owner = msg.sender;
    }

    mapping(bytes32 => uint) productPrice;
    mapping(bytes32 => string) productHash;
    mapping(bytes32 => address) private seller;
    mapping(bytes32 => address) private buyer;

    mapping(bytes32 => uint) collateral;

    enum State {
        AWAITING_PAYMENT,
        AWAITING_DELIVERY,
        COMPLETE
    }

    mapping(bytes32 => State) currentState;

    modifier verifyGuaranteeRatio(bytes32 identifierHash) {
        require(msg.value >= productPrice[identifierHash] * GUARANTEE_RATIO, string(abi.encodePacked("You must deposit ", GUARANTEE_RATIO,
            "x the price of the product as guarantee for the significance of confirming a purchase (Refundable upon contract fulfillment)")));
        _;
    }

    modifier onlyBuyer(bytes32 identifierHash) {
        require(msg.sender == buyer[identifierHash], "Only the designated buyer for this Escrow Agreement can confirm the delivery");
        _;
    }

    //Seller gets productPrice + collateral
    function collateralizedPrice(uint _productPrice) public returns (bytes32, uint) {
        //Get oracle price feed to calculate price in ETH, seller will have to send to smart contract
    }

    //Seller sends contract productPrice + collateral
    function newEscrow(uint _productPrice, string memory _productHash, bytes32 collateralIdentifier) public payable returns (bytes32) {
        require(msg.value >= collateral[collateralIdentifier], string(abi.encodePacked("You must deposit ", GUARANTEE_RATIO,
            "x the price of the product as guarantee for the significance of initiating an agreement (Refundable upon contract fulfillment)")));

        bytes32 hash = keccak256(abi.encodePacked(_productPrice, _productHash, msg.sender));

        productPrice[hash] = _productPrice;
        productHash[hash] = _productHash;
        seller[hash] = msg.sender;

        return hash;
    }

    function deposit(bytes32 identifierHash) verifyGuaranteeRatio(identifierHash) public payable {
        buyer[identifierHash] = msg.sender;
        currentState[identifierHash] = State.AWAITING_DELIVERY;
    }

    function confirmDelivery(bytes32 identifierHash) onlyBuyer(identifierHash) public {

    }

}
