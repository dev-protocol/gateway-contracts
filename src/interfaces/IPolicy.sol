// SPDX-License-Identifier: MPL-2.0
// solhint-disable-next-line compiler-version
pragma solidity ^0.8.13;

interface IPolicy {
    function shareOfTreasury(uint256 _supply) external view returns (uint256);
}
