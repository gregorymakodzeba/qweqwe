require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');

const settings = {
  optimizer: {    
    enabled: true,
    runs: 20
  } 
};

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {  
  networks: {    
    bsc: {
      url: "https://bsc-dataseed1.binance.org",
      accounts: ["be331e0f5120038424eeec8cc726e3213ad9038429500a4667f6b57b161d31c0"],
      gas: 8000000
    },
    mainnet: {
      url: "https://eth-mainnet.g.alchemy.com/v2/4Dqo63W4vEpd0JqC-gdgxesm8m2zCI2H",
      accounts: ["be331e0f5120038424eeec8cc726e3213ad9038429500a4667f6b57b161d31c0"],
      gas: 8000000
    },
    bsc_testnet: {
      url: "https://data-seed-prebsc-1-s3.binance.org:8545/",
      accounts: ["be331e0f5120038424eeec8cc726e3213ad9038429500a4667f6b57b161d31c0"],
      gas: 8000000
    },
    hardhat: {
      forking: {
        url: "https://speedy-nodes-nyc.moralis.io/a10eefa668498184b33afab6/bsc/testnet/",
        accounts: ["be331e0f5120038424eeec8cc726e3213ad9038429500a4667f6b57b161d31c0"],
        gas: 8000000
      }
    }
  },
  solidity: {
    compilers: [
      { version: '0.5.0', settings },
      // { version: '0.6.12', settings },
      // { version: '0.7.6', settings },
      { version: '0.8.2', settings },
      { version: '0.8.4', settings },
      {
        version: '0.8.9', settings
      },
      {
        version: '0.8.11', settings
      },
      {
        version: '0.8.13', settings
      },
      {
        version: '0.8.17', settings
      }
    ],

  },
  etherscan: {
    apiKey: "SR5J31NFEH7DQPUAN6TQH4C5Q5FGVI91KF"
  }
};

