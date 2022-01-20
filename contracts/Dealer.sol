// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Dealer {
    struct OrderSell {
        uint256 id;
        IERC20 tokenName;
        uint256 amount;
        uint256 price;
        bool isMatched;
        bool isCanceled;
    }

    struct OrderBuy {
        uint256 id;
        uint256 matchedOrderId;
        bool isPaid;
    }

    uint256 public lastestOrderId;
    mapping(address => mapping(uint256 => OrderSell)) orderSells;
    mapping(uint256 => OrderBuy) orderBuys;
    mapping(address => bool) admins;

    constructor(address _admin) {
        admins[_admin] = true;
    }

    modifier isAdmin() {
        require(admins[msg.sender] == true);
        _;
    }

    modifier isNotMatched(uint256 orderId) {
        require(orderSells[msg.sender][orderId].isMatched == false);
        _;
    }

    modifier isNotCanceled(uint256 orderId) {
        require(orderSells[msg.sender][orderId].isCanceled == false);
        _;
    }

    modifier isNotPaid(uint256 orderId) {
        require(orderBuys[orderId].isPaid == false);
        _;
    }

    function addAdmin(address _admin) public isAdmin {
        admins[_admin] = true;
    }

    function revokeAdmin(address _admin) public isAdmin {
        admins[_admin] = false;
    }

    function createSellOrder(
        address tokenAddress,
        uint256 amount,
        uint256 price
    ) public returns (uint256) {
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        uint256 newOrderId = lastestOrderId++;
        orderSells[msg.sender][newOrderId] = OrderSell({
            id: newOrderId,
            tokenName: IERC20(tokenAddress),
            amount: amount,
            price: price,
            isMatched: false,
            isCanceled: false
        });
        return newOrderId;
    }

    function cancelOrder(uint256 orderId)
        public
        isNotMatched(orderId)
        isNotCanceled(orderId)
    {
        orderSells[msg.sender][orderId].isCanceled = true;
        orderSells[msg.sender][orderId].tokenName.transfer(
            msg.sender,
            orderSells[msg.sender][orderId].amount
        );
    }

    function matchOrder(uint256 orderId)
        public
        isAdmin
        isNotMatched(orderId)
        isNotCanceled(orderId)
        returns (uint256)
    {
        orderSells[msg.sender][orderId].isMatched = true;
        uint256 newOrderId = lastestOrderId++;
        orderBuys[newOrderId] = OrderBuy({
            id: newOrderId,
            matchedOrderId: orderId,
            isPaid: false
        });
        return newOrderId;
    }

    function payFinish(uint256 orderId) public isNotPaid(orderId) {
        orderBuys[orderId].isPaid = true;
    }
}
