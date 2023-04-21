// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IPolicy} from "./interfaces/IPolicy.sol";
import {IGateway} from "./interfaces/IGateway.sol";
import {IAddressRegistry} from "./interfaces/IAddressRegistry.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "forge-std/console2.sol";

contract Gateway is IGateway {
    address private _registry;

    struct Amounts {
        uint256 input;
        uint256 fee;
    }

    mapping(address => Amounts) public gatewayOf;

    constructor(address registry) {
        _registry = registry;
    }

    /**
     * @dev Split ERC20 into user and treasury shares
     * @param _to The address to send user shares to
     * @param _amount The amount of shares to split
     * @param _token The address of the token to split
     */
    function split(address _to, uint256 _amount, address _token) external {
        require(IERC20(_token).balanceOf(msg.sender) >= _amount, "Insufficient balance");
        require(_amount > 0, "Must send tokens");

        uint256 treasuryShares = _getTreasuryShares(_amount);
        address treasury = _getTreasuryAddress();
        uint256 userShares = _amount - treasuryShares;

        gatewayOf[_to] = Amounts(_amount, userShares);

        // transfer user shares to user
        bool userTransfer = IERC20(_token).transferFrom(msg.sender, _to, userShares);
        require(userTransfer, "Failed to transfer tokens to user");

        // transfer treasury shares to treasury
        bool treasuryTransfer = IERC20(_token).transferFrom(msg.sender, treasury, treasuryShares);
        require(treasuryTransfer, "Failed to transfer tokens to treasury");

        delete gatewayOf[_to];
    }

    /**
     * @dev Split ETH into user and treasury shares
     * @param _to The address to send user shares to
     */
    function split(address _to) external payable {
        require(msg.value > 0, "Must send ETH");

        uint256 treasuryShares = _getTreasuryShares(msg.value);
        address treasury = _getTreasuryAddress();
        uint256 userShares = msg.value - treasuryShares;

        gatewayOf[_to] = Amounts(msg.value, userShares);

        // transfer user shares to user
        (bool sentToUser,) = _to.call{value: userShares}("");
        require(sentToUser, "Failed to send Ether to user");

        // transfer treasury shares to treasury
        (bool sentToTreasury,) = treasury.call{value: treasuryShares}("");
        require(sentToTreasury, "Failed to send Ether to treasury");

        delete gatewayOf[_to];
    }

    /**
     * @dev Get the amount of treasury shares from a total amount
     * @param _amount The total amount of shares
     * @return The amount of treasury shares
     */
    function _getTreasuryShares(uint256 _amount) internal view returns (uint256) {
        return IPolicy(IAddressRegistry(_registry).registries("Policy")).shareOfTreasury(_amount);
    }

    /**
     * @dev Get the treasury address
     * @return The treasury address
     */
    function _getTreasuryAddress() internal view returns (address) {
        return IAddressRegistry(_registry).registries("Treasury");
    }
}
