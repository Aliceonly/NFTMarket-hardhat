// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

error NFTMarketplace__PriceMustAboveZero();
error NFTMarketplace__NotApprovedForMarketplace();
error NFTMarketplace__AlreadyListed(address nftAddress, uint256 tokenId);
error NFTMarketplace__NotOwner();
error NFTMarketplace__NotListed(address nftAddress, uint256 tokenId);
error NFTMarketplace__PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);
error NFTMarketplace__NoProceeds();
error NFTMarketplace__TransferFailed();

contract NFTMarketplace is ReentrancyGuard {
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

    event ItemBought(
        address indexed buyer,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    )

    event ItemCanceled(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId
    )

    //mapping(NFT Address -> NFT tokenID -> Listing)
    mapping(address => mapping(uint256 => Listing)) private s_listings;
    //SellerAddress -> AmountEarned
    mapping(address => uint256) private s_proceeds;

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
    
    modifier isListed(address nftAddress, uint256 tokenId) {
        if (s_listings[nftAddress][tokenId].price <= 0)
            revert NFTMarketplace__NotListed(nftAddress,tokenId);
        _;
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

    function buyItem(address nftAddress, uint256 tokenId) external payable isListed(nftAddress, tokenId) nonReentrant {
        Listing memory listedItem = s_listings[nftAddress][tokenId];
        if(msg.value < listedItem.price){
            revert NFTMarketplace__PriceNotMet(nftAddress, tokenId, price);
        }
        //遵循Pull over Push,分散直接转账eth风险
        //Sending Money To User ❌
        //Have them withdraw money ✔
        s_proceeds[listedItem.seller] += msg.value;
        delete(s_listings[nftAddress][tokenId]);
        IERC721(nftAddress).safeTransferFrom(listedItem.seller,msg.sender,tokenId);

        //检查NFT所有权转移
        emit ItemBought(msg.sender, nftAddress, tokenId, listedItem.price);
    }

    function cancelListing(address nftAddress, uint256 tokenId) external isOwner(nftAddress,tokenId,msg.sender) isListed(nftAddress,tokenId) {
        delete(s_listings[nftAddress][tokenId]);
        emit ItemCanceled(msg.sender,nftAddress, tokenId);
    }

    function updateListing(address nftAddress, uint256 tokenId, uint256 newPrice) external payable isOwner(nftAddress,tokenId,msg.sender) isListed(nftAddress,tokenId) {
        if (price <= 0) revert NFTMarketplace__PriceMustAboveZero();
        s_listings[nftAddress][tokenId].price = newPrice;
        emit ItemListed(msg.sender, nftAddress, tokenId, newPrice);
    }

    function withdarwProceeds() external {
        uint256 proceeds = s_proceeds[msg.sender];
        if (proceeds <= 0) revert NFTMarketplace__NoProceeds();
        s_proceeds[msg.sender] = 0;
        (bool success,) = payable(msg.sender).call{value: proceeds}("");
        if (!success) revert NFTMarketplace__TransferFailed();
    }

    //1.将NFT转账给合约
    //2.approve合约出售NFT
}
