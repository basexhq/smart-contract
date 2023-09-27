/* COMMENTED OUT 
   ALREADY DEPLOYED
   WAS CAUSING SOME ISSUES WHEN DEPLOYING BaseX

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "node_modules/@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract PVT is ERC20PresetMinterPauser {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    address public BaseX;

    constructor(address BaseXaddr) ERC20PresetMinterPauser("Positive Value Token", "PVT") {
        BaseX = BaseXaddr; // When verifying contract use https://abi.hashex.org/ to encode constructor paremeters

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender()); // https://medium.com/coinmonks/my-first-erc20-token-7d5d16632818
        
        _grantRole(ADMIN_ROLE, msg.sender); // Creator of PVT NVT retains the right to change BaseX address
        _grantRole(MINTER_ROLE, BaseX);

        // We do not want any excessive permissions, renoucing 
        _revokeRole(MINTER_ROLE, msg.sender);
        _revokeRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function updateBaseX(address newBaseX) public onlyRole(ADMIN_ROLE) {
        _revokeRole(MINTER_ROLE, BaseX);
        _grantRole(MINTER_ROLE, newBaseX);
        BaseX = newBaseX;
    }
}

// Should be exactly copy-pasta from above, no funny business
contract NVT is ERC20PresetMinterPauser {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    address public BaseX;

    constructor(address BaseXaddr) ERC20PresetMinterPauser("Negative Value Token", "NVT") {
        BaseX = BaseXaddr; // When verifying contract use https://abi.hashex.org/ to encode constructor paremeters

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender()); // https://medium.com/coinmonks/my-first-erc20-token-7d5d16632818
        
        _grantRole(ADMIN_ROLE, msg.sender); // Creator of PVT NVT retains the right to change BaseX address
        _grantRole(MINTER_ROLE, BaseX);

        // We do not want any excessive permissions, renoucing 
        _revokeRole(MINTER_ROLE, msg.sender);
        _revokeRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function updateBaseX(address newBaseX) public onlyRole(ADMIN_ROLE) {
        _revokeRole(MINTER_ROLE, BaseX);
        _grantRole(MINTER_ROLE, newBaseX);
        BaseX = newBaseX;
    }
}

*/