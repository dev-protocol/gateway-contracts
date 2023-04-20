// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {IPolicy} from "./interfaces/IPolicy.sol";
import {IAddressRegistry} from "./interfaces/IAddressRegistry.sol";

contract Gateway {
    address private _registry;

    constructor(address registry) {
        _registry = registry;
    }

    function split(address _token, uint256 _amount) external {}

    function split() external payable {}

    function _getTreasuryShares(
        uint256 _amount
    ) internal view returns (uint256) {
        return
            IPolicy(IAddressRegistry(_registry).registries("Policy"))
                .shareOfTreasury(_amount);
    }

    function _getTreasuryAddress() internal view returns (address) {
        return IAddressRegistry(_registry).registries("Treasury");
    }
}
