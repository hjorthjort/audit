// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.x;

import '../../core/interfaces/IShadowV3Pool.sol';
import './PoolAddress.sol';

/// @notice Provides validation for callbacks from Shadow V3 Pools
library CallbackValidation {
    /// @notice Returns the address of a valid Shadow V3 Pool
    /// @param deployer The contract address of the Shadow V3 deployer
    /// @param tokenA The contract address of either token0 or token1
    /// @param tokenB The contract address of the other token
    /// @param tickSpacing The tickSpacing of the pool
    /// @return pool The V3 pool contract address
    function verifyCallback(
        address deployer,
        address tokenA,
        address tokenB,
        int24 tickSpacing
    ) internal view returns (IShadowV3Pool pool) {
        return verifyCallback(deployer, PoolAddress.getPoolKey(tokenA, tokenB, tickSpacing));
    }

    /// @notice Returns the address of a valid Shadow V3 Pool
    /// @param deployer The contract address of the Shadow V3 deployer
    /// @param poolKey The identifying key of the V3 pool
    /// @return pool The V3 pool contract address
    function verifyCallback(
        address deployer,
        PoolAddress.PoolKey memory poolKey
    ) internal view returns (IShadowV3Pool pool) {
        pool = IShadowV3Pool(PoolAddress.computeAddress(deployer, poolKey));
        require(msg.sender == address(pool));
    }
}
