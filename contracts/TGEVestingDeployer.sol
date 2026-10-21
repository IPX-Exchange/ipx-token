// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// --- OpenZeppelin (standard) ---
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

// --- Local ---
import {DeferredVestingVault} from "launch/DeferredVestingVault.sol";

/**
 * @title TGEVestingDeployer
 * @notice Deploys and funds one `DeferredVestingVault` clone per beneficiary for the TGE's vesting
 *         buckets. Each vault is created and funded immediately (typically at Genesis, so every
 *         beneficiary's allocation is visible right away) with its clock unset — the vault's own owner
 *         later calls `activateVesting()` directly on it once the real start date is known.
 * @dev Cloning and initializing happen in the same transaction, so no other caller can ever observe an
 *      uninitialized clone at a predictable address.
 */
contract TGEVestingDeployer is Ownable {
    using SafeERC20 for IERC20;

    // --- Errors ---

    error ZeroAddress();
    error ZeroAmount();

    // --- Events ---

    event VaultDeployed(
        address indexed vault,
        bytes32 indexed projectId,
        address indexed beneficiary,
        uint256 amount,
        uint64 duration,
        uint64 cliffDuration,
        bool revocable
    );

    // --- Immutable config ---

    address public immutable vestingImplementation;
    IERC20 public immutable ipx;

    constructor(address vestingImplementation_, address ipx_, address owner_) Ownable(owner_) {
        if (vestingImplementation_ == address(0) || ipx_ == address(0)) revert ZeroAddress();
        vestingImplementation = vestingImplementation_;
        ipx = IERC20(ipx_);
    }

    /**
     * @notice Deploys a fresh `DeferredVestingVault` clone for `beneficiary` and funds it with `amount`
     *         IPX. Callable only by the owner (the protocol multisig). Its clock is not started — call
     *         `activateVesting()` on the returned vault once the real start date is known.
     * @param projectId Arbitrary identifier for grouping (e.g. keccak256("IPX-TGE")).
     * @param beneficiary Wallet that will receive vested tokens via `release()`.
     * @param vaultOwner Revocation and activation authority for this vault (typically the same multisig).
     * @param durationSeconds Total linear vesting duration after the cliff.
     * @param cliffSeconds Cliff duration added to the eventual start.
     * @param amount IPX amount to lock in this vault.
     * @param revocable Whether `vaultOwner` may revoke unvested tokens on termination.
     */
    function deployAndFund(
        bytes32 projectId,
        address beneficiary,
        address vaultOwner,
        uint64 durationSeconds,
        uint64 cliffSeconds,
        uint256 amount,
        bool revocable
    ) external onlyOwner returns (address vault) {
        return _deployAndFund(projectId, beneficiary, vaultOwner, durationSeconds, cliffSeconds, amount, revocable);
    }

    /// @notice One vault's parameters, for `deployAndFundMany` — every entry carries its own schedule.
    struct VaultSpec {
        address beneficiary;
        uint256 amount;
        uint64 durationSeconds;
        uint64 cliffSeconds;
        bool revocable;
    }

    /**
     * @notice Deploys and funds one vault per entry in a single transaction, each with its own schedule —
     *         so a TGE with several distinct vesting schedules (e.g. team, advisors, investors) needs one
     *         signature, not one per schedule. Reverts the whole call if any entry is invalid.
     * @return vaults The deployed vault addresses, in the same order as `specs`.
     */
    function deployAndFundMany(bytes32 projectId, address vaultOwner, VaultSpec[] calldata specs)
        external
        onlyOwner
        returns (address[] memory vaults)
    {
        uint256 len = specs.length;
        vaults = new address[](len);
        for (uint256 i; i < len; ++i) {
            VaultSpec calldata s = specs[i];
            vaults[i] = _deployAndFund(
                projectId, s.beneficiary, vaultOwner, s.durationSeconds, s.cliffSeconds, s.amount, s.revocable
            );
        }
    }

    /**
     * @notice Batch convenience wrapper around `deployAndFund` for many beneficiaries sharing the same
     *         schedule (e.g. an entire tier of advisors). Reverts the whole batch if any entry is invalid.
     */
    function deployAndFundBatch(
        bytes32 projectId,
        address[] calldata beneficiaries,
        address vaultOwner,
        uint64 durationSeconds,
        uint64 cliffSeconds,
        uint256[] calldata amounts,
        bool revocable
    ) external onlyOwner returns (address[] memory vaults) {
        uint256 len = beneficiaries.length;
        require(len == amounts.length, "length mismatch");
        vaults = new address[](len);
        for (uint256 i; i < len; ++i) {
            vaults[i] = _deployAndFund(
                projectId, beneficiaries[i], vaultOwner, durationSeconds, cliffSeconds, amounts[i], revocable
            );
        }
    }

    function _deployAndFund(
        bytes32 projectId,
        address beneficiary,
        address vaultOwner,
        uint64 durationSeconds,
        uint64 cliffSeconds,
        uint256 amount,
        bool revocable
    ) internal returns (address vault) {
        if (beneficiary == address(0) || vaultOwner == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();

        vault = Clones.clone(vestingImplementation);
        DeferredVestingVault(vault).initialize(
            projectId, beneficiary, address(ipx), durationSeconds, cliffSeconds, amount, revocable, vaultOwner
        );
        ipx.safeTransfer(vault, amount);

        emit VaultDeployed(vault, projectId, beneficiary, amount, durationSeconds, cliffSeconds, revocable);
    }
}
