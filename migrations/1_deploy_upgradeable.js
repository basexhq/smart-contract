const BaseX = artifacts.require('BaseX');
 
const { deployProxy } = require('@openzeppelin/truffle-upgrades');
 
module.exports = async function (deployer) {
  await deployProxy(BaseX, ["0x55A3d9Bd99F286F1817CAFAAB124ddDDFCb0F314" /* factory */, "0x370Aa27bc8c7Db549494568D6AD704520Cb48C87" /* organisations */ ], { deployer, initializer: 'initializer' });
};