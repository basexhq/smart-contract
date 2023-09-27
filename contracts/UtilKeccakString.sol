// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

// This is to quickly convert JSONIPFS string into Bytes32
contract String2Bytes32 {
    function stringToBytes32(string memory str) public pure returns (bytes32) {
        bytes32 result = keccak256(bytes(str));
        return result;
    }
}