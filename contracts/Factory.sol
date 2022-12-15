// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IFactory.sol";
import "./Pool.sol";

contract Factory is Ownable, IFactory {
    mapping (address => address) _pools;

    event CollectionCreated(address indexed collection_, address indexed user);

    function createPool(address nftCollection) external returns (address) {
        require(_pools[nftCollection] == address(0), "Collection Created");
        bytes32 salt = keccak256(abi.encode(nftCollection));
        Pool pool = new Pool{salt: salt}(nftCollection);

        _pools[nftCollection] = address(pool);
        return address(pool);
    }

    function isSupport(address nftCollection, address pool) public view returns (bool) {
        return _pools[nftCollection] == pool;
    }
}