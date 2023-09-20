// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

error NFTMarketplace__PriceMustAboveZero();
error NFTMarketplace__NotApprovedForMarketplace();
error NFTMarketplace__AlreadyListed(address nftAddress, uint256 tokenId);
error NFTMarketplace__NotOwner();

contract NFTMarketplace {
    struct Listing {
        uint256 price;
        address seller;
    }

    event ItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    //mapping(NFT Address -> NFT tokenID -> Listing)
    mapping(address => mapping(uint256 => Listing)) private s_listings;

    modifier notListed(address nftAddress, uint256 tokenId, address owner) {
        if (s_listings[nftAddress][tokenId].price > 0)
            revert NFTMarketplace__AlreadyListed(nftAddress,tokenId);
        _;
    }

    modifier isOwner(address nftAddress, uint256 tokenId, address spender) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (spender != owner) {
            revert NFTMarketplace__NotOwner();
        }
        _;
    }
        
    }

    /**
     * 1.listItem
     * 2.buyItem
     * 3.cancelItem
     * 4.updateListing
     * 5.withdrewProceeds
     */

    function listItem(address nftAddress, uint256 tokenId, uint256 price) external notListed(nftAddress, tokenId, msg.sender) isOwner(nftAddress, tokenId, msg.sender) {
        if (price <= 0) revert NFTMarketplace__PriceMustAboveZero();
        IERC721 nft = IERC721(nftAddress);
        if (nft.getApproved(tokenId) != address(this))
            revert NFTMarketplace__NotApprovedForMarketplace();
        s_listings[nftAddress][tokenId] = Listing(price, msg.sender);
        emit ItemListed(msg.sender, nftAddress, tokenId, price);
    }

    //1.将NFT转账给合约
    //2.approve合约出售NFT
}
