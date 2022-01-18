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
    }

    struct OrderBuy {
        uint256 id;
        uint256 matchedOrderId;
        bool isPaid;
    }

    uint256 public lastestOrderId;
    mapping(address => mapping(uint256 => OrderSell)) orderSells;
    mapping(uint256 => OrderBuy) orderBuys;

    constructor() {}

    function createSellOrder(
        address tokenAddress,
        uint256 amount,
        uint256 price
    ) public {
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        uint256 newOrderId = lastestOrderId++;
        orderSells[msg.sender][newOrderId] = OrderSell({
            id: newOrderId,
            tokenName: IERC20(tokenAddress),
            amount: amount,
            price: price,
            isMatched: false
        });
    }

    function matchOrder(uint256 orderId) public {
        require(orderSells[msg.sender][orderId].isMatched == false);
        orderSells[msg.sender][orderId].isMatched = true;
        uint256 newOrderId = lastestOrderId++;
        orderBuys[newOrderId] = OrderBuy({
            id: newOrderId,
            matchedOrderId: orderId,
            isPaid: false
        });
    }

    function payFinish(uint256 orderId) public {
        orderBuys[orderId].isPaid = true;
    }
}
