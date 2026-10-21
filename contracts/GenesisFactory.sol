// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// --- Local ---
import {GenesisDistributor} from "launch/GenesisDistributor.sol";
import {TGEVestingDeployer} from "launch/TGEVestingDeployer.sol";
import {DeferredVestingVault} from "launch/DeferredVestingVault.sol";
import {TestTokenFactory} from "launch/TestTokenFactory.sol";
import {IPXToken} from "tokens/IPXToken.sol";

/**
 * @title GenesisFactory
 * @notice Collapses the Genesis setup chain — GenesisDistributor, the token, the DeferredVestingVault
 *         implementation, and TGEVestingDeployer — into the single transaction that deploys this
 *         contract. Everything below runs inside the constructor, so one signature produces a fully
 *         wired, ready-to-configure set of contracts instead of five separate ones.
 * @dev `configure()` and `execute()` on `GenesisDistributor` are deliberately left OUT of this contract
 *      and stay separate, caller-signed transactions — that gap is what lets the recorded recipient
 *      list be inspected on-chain before any tokens move. This factory only owns `GenesisDistributor`
 *      for the instant it takes to call `setToken()`, then immediately hands ownership to `owner_` so
 *      only the real caller can ever call `configure()`/`execute()`. `TGEVestingDeployer` is deployed
 *      already owned by `owner_` directly, since this factory never calls it.
 */
contract GenesisFactory {
    // --- Immutable outputs — set once, in the constructor, and readable for free afterward ---

    address public immutable genesisDistributor;
    address public immutable ipxToken;
    address public immutable vestingImplementation;
    address public immutable tgeVestingDeployer;

    event GenesisSetup(
        address indexed owner,
        address genesisDistributor,
        address ipxToken,
        address vestingImplementation,
        address tgeVestingDeployer,
        bool testMode
    );

    /**
     * @param owner_ The real caller — ends up owning `GenesisDistributor`, `TGEVestingDeployer`, and (in
     *        test mode) the test token clone itself; never the inert distributor.
     * @param testMode When true, deploys a disposable `TestTokenFactory` and mints a caller-named test
     *        token instead of the real, fixed-supply `IPXToken`.
     * @param tokenName Test-mode only — ignored when `testMode` is false (`IPXToken` hardcodes its name).
     * @param tokenSymbol Test-mode only — ignored when `testMode` is false.
     * @param testSupplyWad Test-mode only — whole-token supply (18 decimals) minted to the distributor.
     */
    constructor(
        address owner_,
        bool testMode,
        string memory tokenName,
        string memory tokenSymbol,
        uint256 testSupplyWad
    ) {
        // 1. GenesisDistributor — owned by this factory just long enough to call setToken() below.
        genesisDistributor = address(new GenesisDistributor(address(this)));

        // 2. The genesis token — real IPXToken, or a disposable test-mode clone.
        if (testMode) {
            TestTokenFactory factory = new TestTokenFactory();
            ipxToken = factory.deployTestToken(tokenName, tokenSymbol, genesisDistributor, owner_, testSupplyWad);
        } else {
            ipxToken = address(new IPXToken(genesisDistributor));
        }

        // 3. Connect them — only this factory can call this right now, since it owns the distributor.
        GenesisDistributor(genesisDistributor).setToken(ipxToken);

        // 4. Vesting infrastructure — owned by owner_ directly; this factory never calls it.
        vestingImplementation = address(new DeferredVestingVault());
        tgeVestingDeployer = address(new TGEVestingDeployer(vestingImplementation, ipxToken, owner_));

        // 5. Hand the distributor to the real caller — only owner_ can configure()/execute() from here.
        GenesisDistributor(genesisDistributor).transferOwnership(owner_);

        emit GenesisSetup(owner_, genesisDistributor, ipxToken, vestingImplementation, tgeVestingDeployer, testMode);
    }
}
