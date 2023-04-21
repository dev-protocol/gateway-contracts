// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "forge-std/console2.sol";

contract TokenMock is ERC20 {
    constructor() ERC20("Mock", "MOCK") {}

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }
}
