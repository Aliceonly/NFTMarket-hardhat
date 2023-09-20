1.搭建一个去中心化的NFT交易所
    1.listItem
    2.buyItem
    //遵循Pull over Push,分散直接转账eth风险
        //Sending Money To User ❌
        //Have them withdraw money ✔
        使用safeTransferFrom确保NFT所有权转移
        使用ReentrancyGuard互斥锁防止重入
    3.cancelItem
    4.updateListing
    5.withdrewProceeds

铸造和挂售NFT脚本
取消挂售NFT脚本
买入NFT脚本
本地evm挖矿脚本
链接前端脚本