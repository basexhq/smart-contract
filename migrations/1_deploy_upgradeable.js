const BaseX = artifacts.require('BaseX');
 
const { deployProxy } = require('@openzeppelin/truffle-upgrades');
 
module.exports = async function (deployer) {
  await deployProxy(BaseX, ["0x55A3d9Bd99F286F1817CAFAAB124ddDDFCb0F314" /* factory */, "0x1a76c3a4c47c4c4d9ae7f6abbea22ccdaa38fff2" /* organisations */ ], { deployer, initializer: 'initializer' });
};