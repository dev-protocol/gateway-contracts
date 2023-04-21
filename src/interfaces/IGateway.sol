// SPDX-License-Identifier: MPL-2.0
// solhint-disable-next-line compiler-version
pragma solidity ^0.8.13;

interface IGateway {
    function split(address _to, uint256 _amount, address _token) external;

    function split(address _to) external payable;
}
