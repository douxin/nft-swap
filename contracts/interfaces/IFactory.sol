// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IFactory {
    function createPool(address nftCollection) external returns (address);
    function isSupport(address nftCollection, address pool) external view returns (bool);
}