// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title LibProtocolConstants
 * @notice Protocol-wide numeric constants for IPX Tokenomics v4.
 * @dev All basis-point values use `BPS = 10_000`. USDC amounts use 6 decimals.
 */
library LibProtocolConstants {
    /// @dev Denominator for basis-point math (100% = 10_000).
    uint256 internal constant BPS = 10_000;

    /// @dev Fixed-point scalar for 18-decimal ratios (1 WAD = 1e18).
    uint256 internal constant WAD = 1e18;

    /// @dev Maximum IPX genesis supply (1 billion tokens, 18 decimals).
    uint256 internal constant MAX_SUPPLY_IPX = 1_000_000_000 * WAD;

    /// @dev Hard floor on α: pFinal/p0 ≈ 2.50× (Blockbuster LOW).
    uint256 internal constant ALPHA_BPS_MIN = 5_710;

    /// @dev Hard ceiling on α: pFinal/p0 ≈ 1.40× (Independent HIGH).
    uint256 internal constant ALPHA_BPS_MAX = 8_330;

    /// @dev Standard MEDIUM default (~2.00×). Launch α is selected per (tier, risk), not this constant.
    uint256 internal constant ALPHA_BPS_DEFAULT = 6_670;

    uint256 internal constant ALPHA_INDEPENDENT_MIN_BPS = 7_410;
    uint256 internal constant ALPHA_INDEPENDENT_MAX_BPS = 8_330;
    uint256 internal constant ALPHA_STANDARD_MIN_BPS = 6_350;
    uint256 internal constant ALPHA_STANDARD_MAX_BPS = 7_020;
    uint256 internal constant ALPHA_BLOCKBUSTER_MIN_BPS = 5_710;
    uint256 internal constant ALPHA_BLOCKBUSTER_MAX_BPS = 6_250;

    /// @dev Platform fee on creator cashout gross (10.00%).
    uint256 internal constant PLATFORM_CASHOUT_FEE_BPS = 1_000;

    /// @dev Platform share of Aave yield skimmed at market cancel (10.00%). Remainder stays in the refund NAV.
    uint256 internal constant CANCEL_YIELD_PLATFORM_FEE_BPS = 1_000;

    /// @dev Swap fee charged by IPXRouter in IPX (0.50%), paid to platform treasury only.
    uint256 internal constant ROUTER_FEE_BPS = 50;

    /// @dev Share of protocol vault transfers and secondary V2 claimFees directed to stakers (85.00%).
    uint256 internal constant STAKER_SHARE_BPS = 8_500;

    /// @dev Slipstream rebalance trigger threshold (20% edge).
    uint256 internal constant REBALANCE_EDGE_BPS = 2_000;

    /// @dev USDC buffer retained in protocol vault (3.00%).
    uint256 internal constant USDC_BUFFER_BPS = 300;

    /// @dev Precision scalar for staking reward index calculations.
    uint256 internal constant REWARD_PRECISION = 1e18;

    /// @dev USDC token decimal count.
    uint256 internal constant USDC_DECIMALS = 6;

    /// @dev Scale from USDC micro-units to 18-decimal units (10 ** (18 - 6)).
    uint256 internal constant USDC_TO_WAD = 1e12;

    /// @dev Default Chainlink answer staleness window in seconds.
    uint256 internal constant DEFAULT_MAX_STALENESS = 3600;

    /// @dev Grace period after sequencer recovery before oracle reads are accepted.
    uint256 internal constant SEQUENCER_GRACE_SECONDS = 3600;

    /// @dev Base L2 sequencer uptime feed.
    address internal constant BASE_SEQUENCER_UPTIME = 0xBCF85224fc0756B9Fa45aA7892530B47e10b6433;

    /// @dev Minimum remaining pool-reserve inventory as BPS of initial `xPool` (10.00%).
    uint256 internal constant MIN_POOL_BPS = 1_000;

    /// @dev Default hard cap on market lifetime from `createdAt` (90 days).
    uint256 internal constant MARKET_MAX_DURATION = 90 days;

    /// @dev Default inactivity window after last purchase (21 days). Zero disables idle expiry.
    uint256 internal constant MARKET_IDLE_TTL = 21 days;

    /// @dev Idle expiry cannot fire before this life (30 days).
    uint256 internal constant MARKET_MIN_LIFE = 30 days;

    /// @dev Auto-expire only if remaining raise value exceeds this BPS of `target` (40.00%).
    uint256 internal constant EXPIRE_MIN_REMAINING_BPS = 4_000;

    /// @dev Delay between default notice and claim finalization (48 hours).
    uint256 internal constant TIMELOCK_SECONDS = 172800;
}
