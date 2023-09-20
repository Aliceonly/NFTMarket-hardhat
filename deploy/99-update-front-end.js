const { ethers, network } = require("hardhat")
const fs = require("fs")

const frontEndContractsFile = "../../nftmarket-nextjs/constants/networkMapping.json"

module.exports = async function () {
    if (process.env.UPDATE_FRONT_END) {
        await updateContractAddress()
    }
}

async function updateContractAddress() {
    const nftMarketplace = await ethers.getContract("NFTMarketplace")
    const chainId = network.config.chainId.toString()
    const contractAddresses = JSON.parse(fs.readFileSync(frontEndContractsFile, "utf8"))
    if (chainId in contractAddresses) {
        if (!contractAddresses[chainId]["NFTMarketplace"].includes(nftMarketplace.address)) {
            contractAddresses[chainId]["NFTMarketplace"].push(nftMarketplace.address)
        } else {
            contractAddresses[chainId] = { NFTMarketplace: nftMarketplace.address }
        }
        fs.writeFileSync(frontEndContractsFile, JSON.stringify(contractAddresses))
    }
}

module.exports.tags = ["all", "frontend"]