// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// --- OpenZeppelin (standard) ---
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// --- Local ---
import {LibProtocolConstants} from "libraries/LibProtocolConstants.sol";

/**
 * @title IPXToken
 * @notice Fixed-supply protocol token minted entirely at genesis.
 * @dev No mint or burn post-deploy. Maximum supply is 1 billion IPX (18 decimals).
 */
contract IPXToken is ERC20 {
    // --- Errors ---

    error SupplyCapExceeded();

    // --- Constructor ---

    /**
     * @notice Mints the full IPX supply to the genesis receiver.
     * @param genesisReceiver Address receiving the entire `MAX_SUPPLY_IPX`.
     */
    constructor(address genesisReceiver) ERC20("IPX Exchange", "IPX") {
        _mint(genesisReceiver, LibProtocolConstants.MAX_SUPPLY_IPX);
    }
}
