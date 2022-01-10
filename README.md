# spells-goerli

![Build Status](https://github.com/makerdao/spells-goerli/actions/workflows/.github/workflows/tests.yaml/badge.svg?branch=master)

Staging repo for MakerDAO's Goerli executive spells.

## Instructions

### Getting Started

```bash
$ git clone git@github.com:makerdao/spells-goerli.git
$ dapp update
```

### Adding Collaterals to the System

If the weekly executive needs to onboard a new collateral:

1. Update the `onboardNewCollaterals()` function in `DssSpellCollateralOnboarding.sol`.
2. Update the values in `src/tests/collaterals.sol`
3. uncomment the `onboardNewCollaterals();` in the `actions()` function in `DssSpellAction`

### Build

```bash
$ make
```

### Test

Set `ETH_RPC_URL` to a Goerli node.

```bash
$ export ETH_RPC_URL=<Goerli URL>
$ make test
```

### Deploy

Set `ETH_RPC_URL` to a Goerli node and ensure `ETH_GAS` is set to a high enough number to deploy the contract.

```bash
$ export ETH_RPC_URL=<Goerli URL>
$ export ETH_GAS=8000000
$ export ETH_GAS_PRICE=$(seth --to-wei 3 "gwei")
$ make deploy

```
