// SPDX-License-Identifier: MPL-2.0
// solhint-disable-next-line compiler-version
pragma solidity ^0.8.13;

interface IGateway {
    function split(address _to, address _propertyAddress, bytes32 _payload, uint256 _amount, address _token)
        external
        returns (uint256);

    function split(address _to, address _propertyAddress, bytes32 _payload) external payable returns (uint256);
}
