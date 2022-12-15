// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";

abstract contract ListOrders {
    using Counters for Counters.Counter;

    enum ListOrderStatus {
        New,
        Cancel,
        Confirm,
        Done
    }

    struct ListOrder {
        uint256 tokenId;
        address owner;
        ListOrderStatus status;
        uint256 listedAt;
    }

    Counters.Counter listOrderId;

    // tokenId => listOrderId => listOrder instance
    mapping(uint256 => mapping(uint256 => ListOrder)) internal _listOrders;

    // tokenId => bool
    mapping(uint256 => bool) internal isListing;

    // tokenId => listOrderId
    mapping(uint256 => uint256) internal currentListOrder;

    constructor() {
        listOrderId.increment();
    }

    modifier canSwap(uint256 tokenId) {
        // check if list
        require(isListing[tokenId], "Token not listed");
        
        // check current orderId
        uint256 orderId = currentListOrder[tokenId];
        require(orderId != 0, "Order not found");

        // check ListOrder status
        ListOrderStatus _status = _listOrders[tokenId][orderId].status;
        require(_status == ListOrderStatus.New, "Status not valid");

        _;
    }

    function generateListOrderId() internal returns (uint256 orderId_) {
        orderId_ = listOrderId.current();
        listOrderId.increment();
    }

    function currentOrderIdOf(uint256 tokenId_) internal view returns (uint256) {
        return currentListOrder[tokenId_];
    }

    /**
     * @dev list item
     */
    function list(uint256 tokenId) public virtual {}
}