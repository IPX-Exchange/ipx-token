<p align="center">
  <img src="https://www.ipx.exchange/token-logo.png" alt="IPX" width="120" height="120" />
</p>

<h1 align="center">IPX Token</h1>

<p align="center">
  The native token of <a href="https://www.ipx.exchange"><b>IPX Exchange</b></a><br />
  Fixed supply &nbsp;·&nbsp; No mint &nbsp;·&nbsp; No burn &nbsp;·&nbsp; Base mainnet
</p>

<p align="center">
  <img alt="Network" src="https://img.shields.io/badge/network-Base-0052FF?style=flat-square" />
  <img alt="Standard" src="https://img.shields.io/badge/standard-ERC--20-111827?style=flat-square" />
  <img alt="Supply" src="https://img.shields.io/badge/supply-1%2C000%2C000%2C000-F97316?style=flat-square" />
  <img alt="Mint and burn" src="https://img.shields.io/badge/mint%20%2F%20burn-none-16A34A?style=flat-square" />
</p>

<p align="center">
  <a href="https://www.ipx.exchange">Website</a> &nbsp;·&nbsp;
  <a href="https://www.ipx.exchange/about/token">Token page</a> &nbsp;·&nbsp;
  <a href="https://www.ipx.exchange/about/whitepaper">Whitepaper</a> &nbsp;·&nbsp;
  <a href="https://basescan.org/token/0x32fe0F0fa6E712f3d232fF050a8eC33b37384CC5">Basescan</a> &nbsp;·&nbsp;
  <a href="contracts">Contracts</a>
</p>

---

IPX is the native token of [IPX Exchange](https://www.ipx.exchange), a platform where creators raise production funding and each project's token then trades. It is an ERC-20 token on Base with a fixed supply.

## Token details

| | |
|---|---|
| **Name / symbol** | IPX Exchange / IPX |
| **Standard** | ERC-20, 18 decimals |
| **Network** | Base Mainnet (chain ID 8453) |
| **Contract** | [`0x32fe0F0fa6E712f3d232fF050a8eC33b37384CC5`](https://basescan.org/token/0x32fe0F0fa6E712f3d232fF050a8eC33b37384CC5) |
| **Total supply** | 1,000,000,000 IPX, created once at Genesis on 23 September 2026 |
| **Mint / burn** | None. The contract has no mint function and no burn function, so supply never grows or shrinks. |
| **Source code** | Verified on [Basescan](https://basescan.org/token/0x32fe0F0fa6E712f3d232fF050a8eC33b37384CC5#code). A reference copy of the contracts is in [`contracts/`](contracts). |

## What IPX does

- **Routing asset:** every purchase on a project's market routes through IPX.
- **Graduation collateral:** the IPX collected during a project's raise pairs with the project's token to open its market.
- **Quote currency:** a graduated project's token trades against IPX.
- **Staking:** IPX stakers can claim a share of what the Protocol Vault receives. The amount varies with activity and there is no guaranteed return.

IPX is not equity in the company that operates the platform, and it does not carry on-chain governance votes.

## Allocation

The full supply was created at Genesis on 23 September 2026 and distributed on-chain. **244,800,000 IPX (24.48%)** is unlocked: it is held in four wallets and has been freely transferable since Genesis. The other **755,200,000 IPX (75.52%)** is locked in **29 vesting vaults**, one contract per beneficiary.

| Category | Share | IPX | Unlocked | Locked | Release of the locked part |
|---|--:|--:|--:|--:|---|
| Team & core contributors | 31.87% | 318,700,000 | 0 | 318,700,000 | 12-month cliff, then 24 months. Fully vested at month 36. |
| Treasury & operations | 21% | 210,000,000 | 84,000,000 | 126,000,000 | No cliff. The locked part vests over 12 months. |
| Ecosystem: grants, partnerships & bounties | 14% | 140,000,000 | 140,000,000 | 0 | Nothing is locked. Held for grants and bounties as they are awarded. |
| Investors | 12.9% | 129,000,000 | 0 | 129,000,000 | 12-month cliff, then 24 months. Fully vested at month 36. |
| Reserved for future rounds | 9.23% | 92,300,000 | 0 | 92,300,000 | 12-month cliff, then 24 months. Fully vested at month 36. |
| Advisors & service providers | 7.5% | 75,000,000 | 20,800,000 | 54,200,000 | Foundation pool: No cliff. The locked part vests over 12 months.<br>Strategic partners: 12-month cliff, then 24 months. Fully vested at month 36.<br>Open World: No cliff. The locked part vests over 5 months. |
| Community airdrop | 3.5% | 35,000,000 | 0 | 35,000,000 | No cliff. Fully vested at month 24. |

## Vesting

The vesting clock starts at the liquidity generation event (LGE). It is started once per vault by the launch owner, and until a vault's clock starts nothing is released from it. Cliffs and durations are counted from that start date (a month is 30 days). Vesting is linear per second over the whole duration, and nothing is claimable before the cliff ends. The vaults cannot be revoked.

Whether a vault has started, and how much it has released, is read directly from the vault on Basescan (`started`, `start`, `released`) and is shown live on the [token page](https://www.ipx.exchange/about/token).

### Where to verify

Every vesting vault was created and funded by the TGEVestingDeployer, and each one is an [EIP-1167](https://eips.ethereum.org/EIPS/eip-1167) clone of the vault implementation listed under Contracts. All of them appear as `VaultDeployed` events in the deployer's [Events tab](https://basescan.org/address/0x085Dfc2059EA2CB3516742ecDFf910E0291DF68f#events) on Basescan, with beneficiary, amount, cliff and duration. Any vault can be read on Basescan to see `totalAmount`, `cliffDuration`, `duration`, `started`, `start` and `released`. The live list of vaults and the wallets that hold the unlocked supply is on the [token page](https://www.ipx.exchange/about/token).

## Contracts

These are the contracts used at Genesis. All are verified on Basescan, and a reference copy of the source is in [`contracts/`](contracts).

| Contract | Address | Role |
|---|---|---|
| IPX token | [`0x32fe0F0fa6E712f3d232fF050a8eC33b37384CC5`](https://basescan.org/address/0x32fe0F0fa6E712f3d232fF050a8eC33b37384CC5#code) | The ERC-20 token. No mint and no burn function. |
| GenesisFactory | [`0x466FDD846D70Bc22B07a62346a70868238a91ed5`](https://basescan.org/address/0x466FDD846D70Bc22B07a62346a70868238a91ed5#code) | Deployed the token, the distributor, the vault logic and the vesting deployer in a single transaction. |
| GenesisDistributor | [`0x38f1F84D10AAc1B177d039acd5794E8a128cba00`](https://basescan.org/address/0x38f1F84D10AAc1B177d039acd5794E8a128cba00#code) | Split the whole supply once, at Genesis, between the holders and the vesting vaults. It has no further role. |
| TGEVestingDeployer | [`0x085Dfc2059EA2CB3516742ecDFf910E0291DF68f`](https://basescan.org/address/0x085Dfc2059EA2CB3516742ecDFf910E0291DF68f#code) | Created and funded every vesting vault. Each vault it deployed is listed in its Events tab. |
| Vesting vault (logic) | [`0x5801EFdD5394CB4e602659B675291625Cb40A706`](https://basescan.org/address/0x5801EFdD5394CB4e602659B675291625Cb40A706#code) | The code every vesting vault clones. |

Source files in `contracts/`: `IPXToken.sol`, `LibProtocolConstants.sol`, `GenesisFactory.sol`, `GenesisDistributor.sol`, `TGEVestingDeployer.sol` and `DeferredVestingVault.sol`. They were compiled with Solidity 0.8.24 (optimizer on, 200 runs, via-IR), and import paths follow the build remappings of the main project, so the standard-JSON source on Basescan is the reference for compiling them. The compiled runtime code of the five contracts matches the code deployed on Base.

---

> [!IMPORTANT]
> This page is for information only. IPX is not a promise of profit or return, and its price is not guaranteed. Read the [risk disclosure](https://www.ipx.exchange/risks) before using the platform.

<p align="center">
  <sub>
    <a href="https://www.ipx.exchange/about">About IPX</a> &nbsp;·&nbsp;
    <a href="https://www.ipx.exchange/about/team">Team</a> &nbsp;·&nbsp;
    <a href="mailto:support@ipx.exchange">support@ipx.exchange</a><br />
    IPX Exchange, Inc.
  </sub>
</p>
