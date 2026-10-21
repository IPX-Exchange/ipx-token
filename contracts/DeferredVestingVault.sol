// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// --- OpenZeppelin (upgradeable) ---
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

// --- OpenZeppelin (standard) ---
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title DeferredVestingVault
 * @notice Linear vesting vault that can be deployed and funded before the real vesting-start date is
 *         known. `initialize()` fixes the beneficiary, amount, duration and cliff length, but leaves the
 *         clock unset (`started = false`) — `vestedAmount()` is 0 and nothing is releasable until the
 *         owner calls `activateVesting()` with the real start timestamp, typically once the LGE date is
 *         known. This lets every beneficiary's allocation be created and made visible at Genesis without
 *         committing to a start date yet.
 * @dev A standalone contract (not a modified `VestingVault`) so this stays isolated from the graduation
 *      vesting path, which uses `VestingVault` directly and must keep its current one-shot semantics.
 */
contract DeferredVestingVault is Initializable {
    using SafeERC20 for IERC20;

    // --- Errors ---

    error Unauthorized();
    error AlreadyStarted();
    error CliffNotReached(uint256 cliffEnd, uint256 currentTimestamp);
    error NothingToRelease();

    // --- State Variables ---

    bytes32 public projectId;
    address public beneficiary;
    IERC20 public token;
    uint64 public start;
    uint64 public duration;
    uint64 public cliffDuration; // added to `start` once activated, to produce `cliff`
    uint64 public cliff;
    address public owner;
    bool public revocable;
    bool public revoked;
    bool public started;

    uint256 public totalAmount;
    uint256 public released;

    /// @dev Set by `transferOwnership`, cleared once `acceptOwnership` completes (or the transfer is cancelled).
    address public pendingOwner;

    // --- Events ---

    event VestingActivated(uint64 start, uint64 cliff);
    event Released(address indexed beneficiary, uint256 amount, uint256 timestamp);
    event VestingRevoked(bytes32 indexed projectId, uint256 unreleased, uint256 timestamp);
    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // --- Constructor ---

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // --- Initializer ---

    /**
     * @notice Initializes a cloned vault, funded and beneficiary-assigned, with its clock not yet started.
     * @param projectId_ Project identifier.
     * @param beneficiary_ Token recipient; defaults to `owner_` if zero.
     * @param token_ Vested ERC-20 token (IPX).
     * @param durationSeconds Total vesting duration in seconds, counted from the eventual start.
     * @param cliffDurationSeconds Cliff duration added to start once activated.
     * @param amount Total tokens locked in the vault.
     * @param revocable_ Whether owner may revoke unvested tokens.
     * @param owner_ Revocation and activation authority (protocol multisig).
     */
    function initialize(
        bytes32 projectId_,
        address beneficiary_,
        address token_,
        uint64 durationSeconds,
        uint64 cliffDurationSeconds,
        uint256 amount,
        bool revocable_,
        address owner_
    ) external initializer {
        projectId = projectId_;
        beneficiary = beneficiary_ == address(0) ? owner_ : beneficiary_;
        token = IERC20(token_);
        duration = durationSeconds;
        cliffDuration = cliffDurationSeconds;
        revocable = revocable_;
        owner = owner_;
        totalAmount = amount;
    }

    // --- External Functions ---

    /**
     * @notice Proposes a new owner. The change only takes effect once `newOwner` calls `acceptOwnership()`, so a
     *         mistyped address can never lock the vault. Passing the zero address cancels a pending transfer.
     */
    function transferOwnership(address newOwner) external {
        if (msg.sender != owner) revert Unauthorized();
        pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner, newOwner);
    }

    /// @notice Completes an ownership transfer. Callable only by the address proposed in `transferOwnership()`.
    function acceptOwnership() external {
        if (msg.sender != pendingOwner) revert Unauthorized();
        address previousOwner = owner;
        owner = msg.sender;
        pendingOwner = address(0);
        emit OwnershipTransferred(previousOwner, msg.sender);
    }

    /**
     * @notice Starts the vesting clock. Owner-only, callable once. Typically called once the real LGE
     *         date is known — before this, `vestedAmount()` is always 0.
     */
    function activateVesting(uint64 startTimestamp) external {
        if (msg.sender != owner) revert Unauthorized();
        if (started) revert AlreadyStarted();
        started = true;
        start = startTimestamp;
        cliff = startTimestamp + cliffDuration;
        emit VestingActivated(startTimestamp, cliff);
    }

    /**
     * @notice Returns total vested amount at a given timestamp. Always 0 before activation.
     * @param timestamp Timestamp to evaluate vesting at.
     * @return Vested token amount at `timestamp`.
     */
    function vestedAmount(uint64 timestamp) public view returns (uint256) {
        if (!started || timestamp < cliff) return 0;
        if (timestamp >= start + duration || duration == 0) return totalAmount;
        return (totalAmount * (timestamp - start)) / duration;
    }

    /**
     * @notice Releases vested tokens to the beneficiary.
     */
    function release() external {
        uint256 totalVested = vestedAmount(uint64(block.timestamp));
        uint256 releasable = totalVested - released;
        if (releasable == 0) revert NothingToRelease();

        uint256 balance = token.balanceOf(address(this));
        if (releasable > balance) releasable = balance;

        released += releasable;
        token.safeTransfer(beneficiary, releasable);
        emit Released(beneficiary, releasable, block.timestamp);
    }

    /**
     * @notice Revokes unvested tokens and returns them to owner. Owner only. If called before
     *         activation, nothing has vested yet, so the entire balance returns to owner.
     */
    function revoke() external {
        if (msg.sender != owner) revert Unauthorized();
        if (!revocable || revoked) revert Unauthorized();

        revoked = true;
        uint256 totalVested = vestedAmount(uint64(block.timestamp));
        uint256 releasable = totalVested - released;
        uint256 balance = token.balanceOf(address(this));

        if (releasable > 0) {
            if (releasable > balance) releasable = balance;
            released += releasable;
            balance -= releasable;
            token.safeTransfer(beneficiary, releasable);
        }

        if (balance > 0) {
            token.safeTransfer(owner, balance);
        }

        emit VestingRevoked(projectId, balance, block.timestamp);
    }
}
