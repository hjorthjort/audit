// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.x;

interface IFeeDistributorFactory {
    function createFeeDistributor(address pairFees) external returns (address);
}
