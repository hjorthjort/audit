// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.x;

import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol';

contract TestERC20Metadata is ERC20Permit {
    constructor(uint256 amountToMint, string memory name, string memory symbol) ERC20(name, symbol) ERC20Permit(name) {
        _mint(msg.sender, amountToMint);
    }
}
