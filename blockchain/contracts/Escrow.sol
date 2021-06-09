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
        COMPLETE
    }

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

    //Seller sends contract productPrice + collateral
    function newEscrow(uint _productPrice, string memory _productHash) public payable returns (bytes32) {
        require(msg.value >= _productPrice * GUARANTEE_RATIO, string(abi.encodePacked("You must deposit ", GUARANTEE_RATIO,
            "x the price of the product as guarantee for the significance of initiating an agreement (Refundable upon contract fulfillment)")));

        collateral[msg.sender] = msg.value - _productPrice;

        bytes32 hash = keccak256(abi.encodePacked(_productPrice, _productHash, msg.sender));

        productPrice[hash] = _productPrice;
        productHash[hash] = _productHash;
        seller[hash] = msg.sender;

        return hash;
    }

    function deposit(bytes32 identifierHash) verifyGuaranteeRatio(identifierHash) public payable {
        collateral[msg.sender] = msg.value - productPrice[identifierHash];
        buyer[identifierHash] = msg.sender;
        currentState[identifierHash] = State.AWAITING_DELIVERY;
    }

    function confirmDelivery(bytes32 identifierHash) onlyBuyer(identifierHash) public {
        payable(seller[identifierHash]).transfer(productPrice[identifierHash]);
        payable(buyer[identifierHash]).transfer(productPrice[identifierHash]);

        currentState[identifierHash] = State.COMPLETE;
    }

}
