// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/IPool.sol";
import "./ListOrders.sol";
import "./AskOrders.sol";

contract Pool is IPool, ListOrders, AskOrders {
    error TokenNotExist(uint256 tokenId);

    event TokenList(address indexed owner, address collection, uint256 tokenId);

    address public factory;
    IERC721 public immutable nftCollection;

    // listOrderId => askOrderId
    mapping(uint256 => uint256) private _swapedOrders;

    mapping(address => uint256) private _swapePools;

    constructor(address collection_) {
        factory = msg.sender;
        nftCollection = IERC721(collection_);
    }

    function isOwnerOfToken(
        uint256 tokenId_,
        address owner_
    ) internal view returns (bool) {
        try nftCollection.ownerOf(tokenId_) returns (address owner) {
            return owner_ == owner;
        } catch {
            revert TokenNotExist(tokenId_);
        }
    }

    /**
     * @dev list item
     */
    function list(uint256 tokenId) public override {
        require(!isListing[tokenId], "Item Listed");

        bool isOwner = isOwnerOfToken(tokenId, msg.sender);
        require(isOwner, "Not Owner");

        isListing[tokenId] = true;

        uint256 orderId = generateListOrderId();

        _listOrders[tokenId][orderId] = ListOrder({
            tokenId: tokenId,
            owner: msg.sender,
            status: ListOrderStatus.New,
            listedAt: block.timestamp
        });

        nftCollection.approve(address(this), tokenId);

        emit TokenList(msg.sender, address(nftCollection), tokenId);
    }

    /**
     * @dev ask for swap with myTokenId
     */
    function ask(
        uint256 listTokenId,
        uint256 listOrderId,
        uint256 askTokenId
    ) public override canSwap(listTokenId) returns (uint256 askOrderId) {
        bool isOwner = isOwnerOfToken(askTokenId, msg.sender);
        require(isOwner, "Not Owner");

        uint256 listOrderId_ = currentOrderIdOf(listTokenId);
        require(listOrderId_ == listOrderId, "Order id not match");

        askOrderId = _addAskOrder(listOrderId, askTokenId, msg.sender);
    }

    function confirmSwap(
        uint256 listOrderId_,
        uint256 listTokenId_,
        uint256 askOrderId_,
        uint256 askTokenId_
    ) external canSwap(listTokenId_) {
        // check the asked token is still owner to saved owner,
        // incase the owner has transfered the token
        require(isAsked[askTokenId_][askOrderId_], "Ask order invalid");

        address ownerOfAskToken = askOrders[askOrderId_].askTokenOwner;
        bool isOwnerOfAskToken = isOwnerOfToken(askTokenId_, ownerOfAskToken);
        require(isOwnerOfAskToken, "Ask owner not match");

        _swapedOrders[listOrderId_] = askOrderId_;

        address ownerOfListToken = _listOrders[listTokenId_][listOrderId_]
            .owner;

        _swapePools[ownerOfListToken] = askTokenId_;
        _swapePools[ownerOfAskToken] = listTokenId_;
    }

    function claimToken(uint256 tokenId) public {
        require(_swapePools[msg.sender] == tokenId, "No Permission to swap");
        nftCollection.transferFrom(address(this), msg.sender, tokenId);
    }

    function cancelListOf(uint256 listOrderId_, uint256 listTokenId_) public {
        isListing[listTokenId_] = false;
        _listOrders[listTokenId_][listOrderId_].status = ListOrderStatus.Cancel;
    }

    function cancelAskOf(uint256 askOrderId_, uint256 askTokenId_) public {
        isAsked[askTokenId_][askOrderId_] = false;
    }
}
