// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "./Address.sol";

contract A {
    using Address for address;
    uint256 public value;

    function setValue(uint256 _value) public {
        value = _value;
    }
}

contract B {
    using Address for address;
    uint256 public value;

    function setAValue(address aAddress, uint256 _value) public {
        aAddress.functionCall(abi.encodeWithSignature("setValue(uint256)", _value));
    }
    
    function setAValueByDelegatecall(address aAddress, uint256 _value) public {
        aAddress.delegatecall(abi.encodeWithSignature("setValue(uint256)", _value));
    }
}
