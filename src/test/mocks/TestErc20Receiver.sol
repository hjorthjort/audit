pragma solidity ^0.8.23;

contract TestErc20Receiver {
    constructor() {}

    function onERC20Received(address underlyingToken, uint256 amount) external {}
}
