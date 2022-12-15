// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IPool {
    function confirmSwap(uint256 listOrderId_, uint256 listTokenId_, uint256 askOrderId_, uint256 askTokenId_) external;
}