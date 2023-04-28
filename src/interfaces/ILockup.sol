// SPDX-License-Identifier: MPL-2.0
// solhint-disable-next-line compiler-version
pragma solidity ^0.8.13;

interface ILockup {
    function depositToProperty(address _property, uint256 _amount, bytes32 _payload) external returns (uint256);
}
