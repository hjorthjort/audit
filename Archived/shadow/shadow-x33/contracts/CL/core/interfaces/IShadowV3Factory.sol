// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title The interface for the Shadow V3 Factory
/// @notice The Shadow V3 Factory facilitates creation of Shadow V3 pools and control over the protocol fees
interface IShadowV3Factory {
    /// @notice Emitted when a pool is created
    /// @param token0 The first token of the pool by address sort order
    /// @param token1 The second token of the pool by address sort order
    /// @param fee The fee collected upon every swap in the pool, denominated in hundredths of a bip
    /// @param tickSpacing The minimum number of ticks between initialized ticks
    /// @param pool The address of the created pool
    event PoolCreated(
        address indexed token0, address indexed token1, uint24 indexed fee, int24 tickSpacing, address pool
    );

    /// @notice Emitted when a new tickspacing amount is enabled for pool creation via the factory
    /// @dev unlike UniswapV3, we map via the tickSpacing rather than the fee tier
    /// @param tickSpacing The minimum number of ticks between initialized ticks
    /// @param fee The fee, denominated in hundredths of a bip
    event TickSpacingEnabled(int24 indexed tickSpacing, uint24 indexed fee);

    /// @notice Emitted when the protocol fee is changed
    /// @param feeProtocolOld The previous value of the protocol fee
    /// @param feeProtocolNew The updated value of the protocol fee
    event SetFeeProtocol(uint8 feeProtocolOld, uint8 feeProtocolNew);

    /// @notice Emitted when the protocol fee is changed
    /// @param pool The pool address
    /// @param feeProtocolOld The previous value of the protocol fee
    /// @param feeProtocolNew The updated value of the protocol fee
    event SetPoolFeeProtocol(address pool, uint8 feeProtocolOld, uint8 feeProtocolNew);

    /// @notice Emitted when a pool's fee is changed
    /// @param pool The pool address
    /// @param newFee The updated value of the protocol fee
    event FeeAdjustment(address pool, uint24 newFee);

    /// @notice Emitted when the fee collector is changed
    /// @param oldFeeCollector The previous implementation
    /// @param newFeeCollector The new implementation
    event FeeCollectorChanged(address indexed oldFeeCollector, address indexed newFeeCollector);

    /// @notice Returns the PoolDeployer address
    /// @return The address of the PoolDeployer contract
    function shadowV3PoolDeployer() external returns (address);

    /// @notice Returns the fee amount for a given tickSpacing, if enabled, or 0 if not enabled
    /// @dev A tickSpacing can never be removed, so this value should be hard coded or cached in the calling context
    /// @dev unlike UniswapV3, we map via the tickSpacing rather than the fee tier
    /// @param tickSpacing The enabled tickSpacing. Returns 0 in case of unenabled tickSpacing
    /// @return initialFee The initial fee
    function tickSpacingInitialFee(int24 tickSpacing) external view returns (uint24 initialFee);

    /// @notice Returns the pool address for a given pair of tokens and a tickSpacing, or address 0 if it does not exist
    /// @dev tokenA and tokenB may be passed in either token0/token1 or token1/token0 order
    /// @dev unlike UniswapV3, we map via the tickSpacing rather than the fee tier
    /// @param tokenA The contract address of either token0 or token1
    /// @param tokenB The contract address of the other token
    /// @param tickSpacing The tickSpacing of the pool
    /// @return pool The pool address
    function getPool(address tokenA, address tokenB, int24 tickSpacing) external view returns (address pool);

    /// @notice Creates a pool for the given two tokens and fee
    /// @dev unlike UniswapV3, we map via the tickSpacing rather than the fee tier
    /// @param tokenA One of the two tokens in the desired pool
    /// @param tokenB The other of the two tokens in the desired pool
    /// @param tickSpacing The desired tickSpacing for the pool
    /// @param sqrtPriceX96 initial sqrtPriceX96 of the pool
    /// @dev tokenA and tokenB may be passed in either order: token0/token1 or token1/token0.
    /// @dev The call will revert if the pool already exists, the tickSpacing is invalid, or the token arguments are invalid.
    /// @return pool The address of the newly created pool
    function createPool(address tokenA, address tokenB, int24 tickSpacing, uint160 sqrtPriceX96)
        external
        returns (address pool);

    /// @notice Enables a tickSpacing with the given initialFee amount
    /// @dev unlike UniswapV3, we map via the tickSpacing rather than the fee tier
    /// @dev tickSpacings may never be removed once enabled
    /// @param tickSpacing The spacing between ticks to be enforced for all pools created
    /// @param initialFee The initial fee amount, denominated in hundredths of a bip (i.e. 1e-6)
    function enableTickSpacing(int24 tickSpacing, uint24 initialFee) external;

    /// @notice Returns the default protocol fee value
    /// @return _feeProtocol The default protocol fee percentage
    function feeProtocol() external view returns (uint8 _feeProtocol);

    /// @notice Returns the protocol fee percentage for a specific pool
    /// @dev If the fee is 0 or the pool is uninitialized, returns the Factory's default feeProtocol
    /// @param pool The address of the pool
    /// @return _feeProtocol The protocol fee percentage for the specified pool
    function poolFeeProtocol(address pool) external view returns (uint8 _feeProtocol);

    /// @notice Sets the default protocol fee percentage
    /// @param _feeProtocol New default protocol fee percentage for token0 and token1
    function setFeeProtocol(uint8 _feeProtocol) external;

    /// @notice Retrieves the parameters used in constructing a pool
    /// @dev Called by the pool constructor to fetch the pool's parameters
    /// @return factory The factory address
    /// @return token0 The first token of the pool by address sort order
    /// @return token1 The second token of the pool by address sort order
    /// @return fee The initialized fee tier of the pool, denominated in hundredths of a bip
    /// @return tickSpacing The minimum number of ticks between initialized ticks
    function parameters()
        external
        view
        returns (address factory, address token0, address token1, uint24 fee, int24 tickSpacing);

    /// @notice Updates the fee collector address
    /// @param _feeCollector The new fee collector address
    function setFeeCollector(address _feeCollector) external;

    /// @notice Updates the swap fee for a specific pool
    /// @param _pool The address of the pool to modify
    /// @param _fee The new fee value, scaled where 1_000_000 = 100%
    function setFee(address _pool, uint24 _fee) external;

    /// @notice Returns the current fee collector address
    /// @dev The fee collector contract determines the distribution of protocol fees
    /// @return The address of the fee collector contract
    function feeCollector() external view returns (address);

    /// @notice Updates the protocol fee percentage for a specific pool
    /// @param pool The address of the pool to modify
    /// @param _feeProtocol The new protocol fee percentage to assign
    function setPoolFeeProtocol(address pool, uint8 _feeProtocol) external;

    /// @notice Enables fee protocol splitting upon gauge creation
    /// @param pool The address of the pool to enable fee splitting for
    function gaugeFeeSplitEnable(address pool) external;

    /// @notice Updates the voter contract address
    /// @param _voter The new voter contract address
    function setVoter(address _voter) external;

    /// @notice Checks if a given address is a V3 pool
    /// @param _pool The address to check
    /// @return isV3 True if the address is a V3 pool, false otherwise
    function isPairV3(address _pool) external view returns (bool isV3);

    /// @notice Initializes the factory with a pool deployer
    /// @param poolDeployer The address of the pool deployer contract
    function initialize(address poolDeployer) external;
}
