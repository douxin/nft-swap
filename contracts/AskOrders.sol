// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";

contract AskOrders {
    using Counters for Counters.Counter;

    struct AskOrder {
        uint256 listOrderId;
        uint256 askTokenId;
        address askTokenOwner;
        uint256 askedAt;
    }

    Counters.Counter askOrderId;

    // askTokenId => listOrderId => bool
    mapping(uint256 => mapping (uint256 => bool)) internal isAsked;

    // askOrderId => AskOrder instance
    mapping(uint256 => AskOrder) internal askOrders;

    constructor() {
        askOrderId.increment();
    }

    function isAskedFor(uint256 listOrderId_, uint256 askTokenId) internal view returns (bool) {
        return isAsked[askTokenId][listOrderId_];
    }

    function _addAskOrder(uint256 listOrderId_, uint256 askTokenId, address askTokenOwner) internal virtual returns (uint256) {
        bool isAsked_ = isAskedFor(listOrderId_, askTokenId);
        require(!isAsked_, "Asked");

        uint256 _askOrderId = askOrderId.current();
        askOrderId.increment();

        askOrders[_askOrderId] = AskOrder({
            listOrderId: listOrderId_,
            askTokenId: askTokenId,
            askTokenOwner: askTokenOwner,
            askedAt: block.timestamp
        });

        isAsked[askTokenId][listOrderId_] = true;

        return _askOrderId;
    }

    /**
     * @dev ask for swap with myTokenId
     */
    function ask(uint256 listTokenId, uint256 listOrderId, uint256 askTokenId) external virtual returns (uint256 askOrderId) {}
}
