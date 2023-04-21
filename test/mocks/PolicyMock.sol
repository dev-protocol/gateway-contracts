// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract PolicyMock {
    function shareOfTreasury(uint256 _amount) public pure returns (uint256) {
        uint256 gatewayFeeBasisPoints = 500; // 5%
        return (_amount * gatewayFeeBasisPoints) / 10000;
    }
}
