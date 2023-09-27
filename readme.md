# BaseX smart contract

### Running the code
* uses Truffle and Remix IDE
* `git clone ...`
* `remixd -s . -u https://remix.ethereum.org/`

### Integration with Kleros

Creating a proxy contract that has single purpose: **INTEGRATION WITH KLEROS**

### Kleros parameters

Defaults as much as possible, convention over configuration.

Reasonably low deposit (so that it is not a barrier to entry)

<!--
### Adding organisations

Each organisation accrues PVT (positive value token) and NVT (negative value token), that's why need to keep them unique

### Adding reports and evaluations

It is possible to add:
* report of work but no evaluation
* report of work and evaluation at the same time
* evaluation only

Avoiding duplicate evaluations:
* if a pending evaluation exists, this will be indicated in the UI
* multiple simultaneous evaluations are possible, as long as they cover different areas of impact / different time periods

### Incentive to submit report

Putting your organisation and related report on the list is a signal to the market that you are serious about impact and ESG

### Incentive to evaluate

Ability to mint PVT and NVT tokens

COMPETITOR: Launched 9 days ago - https://gov.gitcoin.co/t/reviewing-gitcoin-grantee-impact-momus-eth-gitcoinreviews-co/15215?u=krrisis

-->

### Read more

https://wiki.basex.com

### Deployment launch sequence

* Deploy list of organisations to Kleros in their UI: https://curate.kleros.io/factory _(Is this a list of lists?  **YES**)_
* Add the newly created list to global "list of lists" in Kleros UI
* Save the address of the list to: `migrations/1_deploy_upgradeable.js`

LAUNCH CHECKLIST
* 1. Deploy BaseX, following the instructions from: https://forum.openzeppelin.com/t/openzeppelin-upgrades-step-by-step-tutorial-for-truffle/3579 
  * `npx truffle migrate --network goerli` _(need to delete previous build files)_
  * `truffle run verify BaseX --network goerli` 
* 2A. Deploy PVT NVT (passing address of BaseX to grant roles)
* 2B. If already deployed - update the BaseX (the proxy) on these contracts to grant required roles
  * PVT: https://goerli.etherscan.io/address/0xee1b27c2d7edc390da423ea0f269825dc13184eb
  * NVT: https://goerli.etherscan.io/address/0x08418B63f49252fD4674C425AD7099a852BfE353
  * Note that here using 0x85 address, not the MetaMask2 (which is the current deployer of other contracts)
* 3. Set PVT NVT address at BaseX
* 4. On the front-end update contract address and ABI
* 5. On the back-end _(now we have Express backend)_ update contract address and ABI 

~~If KlerosProxy updates, we can reuse existing PVT NVT contracts, there is a convenient method `updateBaseX` that will grant minting / burning roles.~~ — we are using upgradeable contracts, the BaseX address will stay the same

UPGRADE CHECKLIST:
1. Create a new file BaseXV4.sol
2. **NICE TO HAVE** Use OpenZeppelin plugin to ensure that the new contract is compatible with the old one
3. Deploy the new contract using Remix
4. Verify the new contract on Etherscan
5. Update the proxy admin to point to the new contract
6. Update the ABI in front-end
7. Update the readme below with latest implementation address

### Deployed addresses
Implementation (ABI from here): https://goerli.etherscan.io/address/0x670a62Df56AF21ef05B85BbCdf3516ea77d4e2A8
Proxy admin: https://goerli.etherscan.io/address/0x91d1562b186de782E83d8A54d6CED6331B1E7EC3
BaseX proxy (always call this one): https://goerli.etherscan.io/address/0xE9A042d7Faf38C2C1419AfF1b4b9aBccC3dD1eF7
