// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IPolicy} from "./interfaces/IPolicy.sol";
import {ILockup} from "./interfaces/ILockup.sol";
import {IGateway} from "./interfaces/IGateway.sol";
import {IAddressRegistry} from "./interfaces/IAddressRegistry.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "forge-std/console2.sol";

contract Gateway is IGateway {
    address private _registry;

    struct Amounts {
        address tokenAddress;
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
     * @return stakingPositionId The ID of the created new staking position
     */
    function split(address _to, address _propertyAddress, bytes32 _payload, uint256 _amount, address _token)
        external
        returns (uint256 stakingPositionId)
    {
        require(IERC20(_token).balanceOf(msg.sender) >= _amount, "Insufficient balance");
        require(_amount > 0, "Must send tokens");

        uint256 treasuryShares = _getTreasuryShares(_amount);
        address treasury = _getTreasuryAddress();
        uint256 userShares = _amount - treasuryShares;

        gatewayOf[_to] = Amounts(_token, _amount, userShares);

        // deposit to property
        stakingPositionId = ILockup(_getLockupAddress()).depositToProperty(_propertyAddress, 0, _payload);

        // transfer user shares to user
        bool userTransfer = IERC20(_token).transferFrom(msg.sender, _to, userShares);
        require(userTransfer, "Failed to transfer tokens to user");

        // transfer treasury shares to treasury
        bool treasuryTransfer = IERC20(_token).transferFrom(msg.sender, treasury, treasuryShares);
        require(treasuryTransfer, "Failed to transfer tokens to treasury");

        delete gatewayOf[_to];

        return stakingPositionId;
    }

    /**
     * @dev Split ETH into user and treasury shares
     * @param _to The address to send user shares to
     * @param _propertyAddress The address of the property to split
     * @param _payload The payload to send to the property
     * @return stakingPositionId The ID of the created new staking position
     */
    function split(address _to, address _propertyAddress, bytes32 _payload)
        external
        payable
        returns (uint256 stakingPositionId)
    {
        require(msg.value > 0, "Must send ETH");

        uint256 treasuryShares = _getTreasuryShares(msg.value);
        address treasury = _getTreasuryAddress();
        uint256 userShares = msg.value - treasuryShares;

        gatewayOf[_to] = Amounts(address(0), msg.value, userShares);

        // deposit to property
        stakingPositionId = ILockup(_getLockupAddress()).depositToProperty(_propertyAddress, 0, _payload);

        // transfer user shares to user
        (bool sentToUser,) = _to.call{value: userShares}("");
        require(sentToUser, "Failed to send Ether to user");

        // transfer treasury shares to treasury
        (bool sentToTreasury,) = treasury.call{value: treasuryShares}("");
        require(sentToTreasury, "Failed to send Ether to treasury");

        delete gatewayOf[_to];

        return stakingPositionId;
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

    /**
     * @dev Get the lockup address
     * @return The lockup address
     */
    function _getLockupAddress() internal view returns (address) {
        return IAddressRegistry(_registry).registries("Lockup");
    }
}
