// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.x;

interface IGaugeFactory {
    /// @notice create a legacy gauge for a specific pool
    /// @param pool the address of the pool
    /// @return newGauge is the address of the created gauge
    function createGauge(address pool) external returns (address newGauge);
}
