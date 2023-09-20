const { ethers, network } = require("hardhat")
const {moveBlocks} = require("../utils/move-blocks")

const TOKEN_ID = 0

async function cancel() {
    const nftMarketplace = await ethers.getContract("NFTMarketplace")
    const baseNft = await ethers.getContract("BasicNft")
    const tx = await nftMarketplace.cancelListing(baseNft.address, TOKEN_ID)
    await tx.wait(1)
    console.log("NFT canceled!")
    if (network.config.chainId == "31337") {
        await moveBlocks(2,(sleepAmount = 1000))
    }
}


cancel()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
