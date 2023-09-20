const { ethers, network } = require("hardhat")
const { moveBlocks } = require("../utils/move-blocks")

const TOKEN_ID = 0

async function buyItem() {
    const nftMarketplace = await ethers.getContract("NFTMarketplace")
    const baseNft = await ethers.getContract("BasicNft")

    const listing = await nftMarketplace.getListing(baseNft.address, TOKEN_ID)
    const price = listing.price.toString()
    const tx = await nftMarketplace.buyItem(baseNft.address, TOKEN_ID,{value:price})
    await tx.wait(1)
    console.log("Bought NFT!")
    if (network.config.chainId == "31337") {
        await moveBlocks(2, (sleepAmount = 1000))
    }
}
