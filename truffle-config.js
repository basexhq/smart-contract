const { projectId, privateKey, etherscanAPI } = require('./secrets.json');
const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
  mocha: {
    enableTimeouts: false
  },
  networks: {
    mainnet: {
      provider: () => new HDWalletProvider([privateKey], `https://mainnet.infura.io/v3/${projectId}`),
      network_id: 1,
      gas: 9000000,
      timeoutBlocks: 20000,
      skipDryRun: true, 
      gasPrice: 202000000000
    },
    goerli: {
      provider: () => new HDWalletProvider([privateKey], `https://goerli.infura.io/v3/${projectId}`),
      network_id: 5,
      gas: 10000000,
      timeoutBlocks: 20000,
      skipDryRun: true,
      gasPrice: 20000000000
    },
   },

  // Configure your compilers
  compilers: {
    solc: {
      version: "^0.8.19"    // Fetch exact version from solc-bin (default: truffle's version)
      // settings: {          // See the solidity docs for advice about optimization and evmVersion
      //  optimizer: {
      //    enabled: true,
      //    runs: 200
      //  },
      // }
    },
  },

  plugins: [
    'truffle-plugin-verify' 
  ],

  // truffle deploy --network goerli
  // truffle run verify BaseX --network goerli

  api_keys: {
    etherscan: etherscanAPI
  }

 };