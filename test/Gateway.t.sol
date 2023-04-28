// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Gateway.sol";
import "forge-std/console2.sol";
import {TokenMock} from "./mocks/TokenMock.sol";
import {PolicyMock} from "./mocks/PolicyMock.sol";
import {LockupMock} from "./mocks/LockupMock.sol";

address constant TREASURY = address(0x1);
address constant ALICE = address(0x2);
address constant PROPERTY = address(0x3);
bytes32 constant PAYLOAD = bytes32(0);

contract AddressRegisteryMock {
    mapping(string => address) private _registries;

    constructor() {
        _registries["Treasury"] = address(TREASURY);
        _registries["Policy"] = address(new PolicyMock());
        _registries["Lockup"] = address(new LockupMock());
    }

    function registries(string memory _name) public view returns (address) {
        return _registries[_name];
    }
}

contract GatewayTest is Test {
    Gateway public gateway;

    function setUp() public {
        gateway = new Gateway(address(new AddressRegisteryMock()));
    }

    /**
     * @dev Tests sending ETH to the gateway
     */
    function testEthSplit() public {
        uint256 amount = 100;
        uint256 expectedTreasuryShares = 5;
        uint256 userShares = amount - expectedTreasuryShares;

        gateway.split{value: amount}(ALICE, PROPERTY, PAYLOAD);

        assertEq(address(TREASURY).balance, expectedTreasuryShares);
        assertEq(address(0x2).balance, userShares);
    }

    /**
     * Return value should be the new staking position ID from LockupMock
     */
    function testStakingPositionId() public {
        uint256 amount = 100;

        /**
         * Testing sending ETH
         */
        assertEq(gateway.split{value: amount}(ALICE, PROPERTY, PAYLOAD), 1);

        /**
         * Testing sending ERC20
         */

        TokenMock token = new TokenMock();
        token.mint(address(this), amount);
        token.approve(address(gateway), amount);
        assertEq(gateway.split(ALICE, PROPERTY, PAYLOAD, amount, address(token)), 1);
    }

    /**
     * @dev Tests sending ERC20 tokens to the gateway
     */
    function testTokenSplit() public {
        uint256 amount = 100;
        uint256 expectedTreasuryShares = 5;
        uint256 userShares = amount - expectedTreasuryShares;

        TokenMock token = new TokenMock();
        token.mint(address(this), amount);
        token.approve(address(gateway), amount);

        gateway.split(ALICE, PROPERTY, PAYLOAD, amount, address(token));

        assertEq(token.balanceOf(address(TREASURY)), expectedTreasuryShares);
        assertEq(token.balanceOf(address(ALICE)), userShares);
    }

    /**
     * @dev Reverts when sending tokens with zero value
     */
    function testRevertWhenTokenSendZero() public {
        uint256 amount = 100;

        TokenMock token = new TokenMock();
        token.mint(address(this), amount);
        token.approve(address(gateway), amount);

        vm.expectRevert("Must send tokens");
        gateway.split(ALICE, PROPERTY, PAYLOAD, 0, address(token));
    }

    /**
     * @dev Reverts when sending ETH with zero value
     */
    function testRevertWhenEthSendZero() public {
        vm.expectRevert("Must send ETH");
        gateway.split{value: 0}(ALICE, PROPERTY, PAYLOAD);
    }
}
