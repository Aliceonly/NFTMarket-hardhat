const { network } = require("hardhat")

function sleep(timeInMs) {
    return new Promise((resolve) => setTimeout(resolve, timeInMs))
}

async function moveBlocks(amount, sleepAmount = 0) {
    console.log("Moving blocks...")
    for (let i = 0; i < amount; i++) {
        await network.provider.request({
            method: "evm_mine",
            params:[]
        })
        if (sleepAmount) {
            console.log(`Sleeping for ${sleepAmount}ms`)
            await sleep(sleepAmount)
        }
    }
}

module.exports={moveBlocks,sleep}