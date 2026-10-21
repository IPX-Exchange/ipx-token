// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// --- OpenZeppelin (standard) ---
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title GenesisDistributor
 * @notice One-shot, atomic split of a token's entire genesis balance into the allocation table.
 * @dev Owner-gated (multisig). Every state-changing function is one-time-only, so the contract is
 *      inert forever once `execute()` succeeds. `configure()` and `execute()` are separate transactions
 *      by design, so the plan can be reviewed on-chain before funds move. The sum check is self-verifying
 *      against the actual token balance held at `configure()` time, not a hardcoded constant.
 */
contract GenesisDistributor is Ownable {
    using SafeERC20 for IERC20;

    // --- Errors ---

    error TokenNotSet();
    error TokenAlreadySet();
    error ZeroAddress();
    error LengthMismatch();
    error EmptyDistribution();
    error DuplicateOrZeroRecipient(address recipient);
    error ZeroAmount(uint256 index);
    error SumMismatch(uint256 sumOfAmounts, uint256 actualBalance);
    error AlreadyConfigured();
    error NotConfigured();
    error AlreadyExecuted();
    error ResidualBalance(uint256 remaining);

    // --- Events ---

    event TokenSet(address indexed token);
    event Configured(uint256 recipientCount, uint256 totalAmount);
    event Distributed(bytes32 indexed label, address indexed recipient, uint256 amount);
    event Executed(uint256 recipientCount, uint256 totalAmount);

    // --- State ---

    IERC20 public ipx;
    bool public configured;
    bool public executed;

    address[] private _recipients;
    uint256[] private _amounts;
    bytes32[] private _labels;

    constructor(address owner_) Ownable(owner_) {}

    /**
     * @notice Sets the token this distributor will split. Callable once, before `configure()`.
     * @dev Deploy this contract first, deploy the token with `genesisReceiver = address(this)`, then
     *      call this to record the token address. Splitting deployment this way avoids any
     *      constructor-ordering dependency between the token and the distributor.
     */
    function setToken(address token_) external onlyOwner {
        if (token_ == address(0)) revert ZeroAddress();
        if (address(ipx) != address(0)) revert TokenAlreadySet();
        ipx = IERC20(token_);
        emit TokenSet(token_);
    }

    /**
     * @notice Records the genesis split. Callable once. Reverts unless the recipient amounts sum to
     *         exactly this contract's current token balance — the plan must fully and exactly account
     *         for every token held, no more, no less.
     */
    function configure(
        address[] calldata recipients_,
        uint256[] calldata amounts_,
        bytes32[] calldata labels_
    ) external onlyOwner {
        if (address(ipx) == address(0)) revert TokenNotSet();
        if (configured) revert AlreadyConfigured();

        uint256 len = recipients_.length;
        if (len == 0) revert EmptyDistribution();
        if (len != amounts_.length || len != labels_.length) revert LengthMismatch();

        uint256 sum;
        for (uint256 i; i < len; ++i) {
            address recipient = recipients_[i];
            if (recipient == address(0)) revert DuplicateOrZeroRecipient(recipient);
            for (uint256 j; j < i; ++j) {
                if (recipients_[j] == recipient) revert DuplicateOrZeroRecipient(recipient);
            }
            if (amounts_[i] == 0) revert ZeroAmount(i);
            sum += amounts_[i];
        }

        uint256 balance = ipx.balanceOf(address(this));
        if (sum != balance) revert SumMismatch(sum, balance);

        _recipients = recipients_;
        _amounts = amounts_;
        _labels = labels_;
        configured = true;

        emit Configured(len, sum);
    }

    /**
     * @notice Executes the recorded split. Callable once. Transfers every recipient's amount and then
     *         asserts the contract's own balance is exactly zero — if it is not, the whole transaction
     *         reverts (nothing partially moves) rather than leaving dust or a silent shortfall.
     */
    function execute() external onlyOwner {
        if (!configured) revert NotConfigured();
        if (executed) revert AlreadyExecuted();
        executed = true; // effects before interactions

        uint256 len = _recipients.length;
        uint256 total;
        for (uint256 i; i < len; ++i) {
            ipx.safeTransfer(_recipients[i], _amounts[i]);
            emit Distributed(_labels[i], _recipients[i], _amounts[i]);
            total += _amounts[i];
        }

        uint256 remaining = ipx.balanceOf(address(this));
        if (remaining != 0) revert ResidualBalance(remaining);

        emit Executed(len, total);
    }

    // --- Views ---

    function recipientsLength() external view returns (uint256) {
        return _recipients.length;
    }

    function recipientAt(uint256 index) external view returns (address recipient, uint256 amount, bytes32 label) {
        return (_recipients[index], _amounts[index], _labels[index]);
    }

    function allRecipients() external view returns (address[] memory, uint256[] memory, bytes32[] memory) {
        return (_recipients, _amounts, _labels);
    }
}
