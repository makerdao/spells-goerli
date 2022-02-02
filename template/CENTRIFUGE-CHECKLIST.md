# Centrifuge Asset Checklist

A few notes about scope.

In scope:
- The URN
- The RWA token
- The Manager
- The Join Adapter (AuthGemJoin)
- The Liquidation Manager (usually reused)

Out of scope (unless you really want to):
- Anything beyond the manager (centrifuge/tinlake code)

## checklist

### per-collateral checklist

- [ ] validate CentrifugeCollateralValues
    - [ ] validate addresses
        - [ ] validate `MCD_JOIN` (join adapter) 
            - [ ] make sure the contract is verified
                - [ ] diff the new code against `MCD_JOIN_RWA002_A` [link](https://etherscan.io/address/0xe72C7e90bc26c11d45dBeE736F0acf57fC5B7152)
                - [ ] ensure same compiler version was used
                - [ ] ensure same optimizer settings were used
            - [ ] make sure all constructor args are correct
                - [ ] `vat` address matches changelog
                - [ ] `ilk` is the `bytes32` representation of "RWANNN-A"
                    - can use `seth --to-bytes32 $(seth --from-ascii "RWANNN")` to get correct value for comparison
                - [ ] `gem` matches the `GEM` value from the Centrifuge config
            - [ ] validate `wards`
                - [ ] deployer has been `denied`
                - [ ] the `URN` address from this config has been `relied`
                - [ ] the MCD pause proxy has been `relied`
                - [ ] no other addresses have been `relied` (check internal transactions)
        - [ ] validate `GEM` (dummy token used as collateral in adapter)
            - [ ] make sure the contract is verified
                - [ ] diff the new code against `RWA002` [link](https://etherscan.io/address/0xAAA760c2027817169D7C8DB0DC61A2fb4c19AC23#code) TODO(after this batch, we should probably compare to `RWA003` since they changed the code a bit)
                - [ ] ensure same compiler version was used
                - [ ] ensure same optimizer settings were used
            - [ ] make sure all constructor args are correct
                - [ ] `name` is in `RWA-NNN` format
                - [ ] `symbol` is in `RWANNN` format
                - [ ] `totalSupply` is `1000000000000000000` (10^18)
            - [ ] ensure a transfer transaction moved the `totalSupply` over to the manager (`OPERATOR` address below)
        - [ ] validate `OPERATOR` (aka "manager" and same as both conduits)
            - [ ] Make sure the contract is verified
                - [ ] diff the new code against `RWA002_A_INPUT_CONDUIT` [link](https://etherscan.io/address/0x2474F297214E5d96Ba4C81986A9F0e5C260f445D#code)
                - [ ] ensure same compiler version was used
                - [ ] ensure same optimizer settings were used
            - [ ] make sure all constructor args are correct by checking the values of the public fields that store them
                - [ ] `dai` address matches changelog (`MCD_DAI`) address
                - [ ] `daiJoin` address matches changelog (`MCD_JOIN_DAI`) address
                - [ ] `end` address matches changelog (`MCD_END`) address
                - [ ] `gem` address matches (`DROP`) from the test values
                - [ ] `liq` address matches changelog (`MIP21_LIQUIDATION_ORACLE`) address
                - [ ] `urn` address is zero (if spell is for `mainnet`) OR  matches `URN` from this config (if spell is for a testnet)
                - [ ] `vat` address matches changelog (`MCD_VAT`) address
                - [ ] `vow` address matches changelog (`MCD_VOW`) address
            - [ ] validate `wards`
                - [ ] ensure `rely()` has been called with `ROOT` from the test values
                - [ ] ensure `rely()` has been called on the `clerk`
                - [ ] ensure `deny()` has been called on the contract's deployer address
        - [ ] `INPUT_CONDUIT` is the same address as `OPERATOR`
        - [ ] `OUTPUT_CONDUIT` is the same address as `OPERATOR`
        - [ ] validate `URN`
            - [ ] make sure contract is verified
                - [ ] diff against `RWA002_A_URN` [link](https://etherscan.io/address/0xa3342059BcDcFA57a13b12a35eD4BBE59B873005#code)
                - [ ] ensure same compiler version was used
                - [ ] ensure same optimizer settings were used
            - [ ] validate constructor args via public fields
                - [ ] `daiJoin` address matches changelog (`MCD_DAI`) address
                - [ ] `gemJoin` address matches `MCD_JOIN` from this config
                - [ ] `jug` address matches changelog (`MCD_JUG`) address
                - [ ] `outputConduit` address matches `OUTPUT_CONDUIT` from this config
                - [ ] `vat` address matches changelog (`MCD_VAT`) address
            - [ ] validate `wards`
                - [ ] the pause proxy (`MCD_PAUSE_PROXY`) has been `relied`
                - [ ] the deployer address has been `denied`
                - [ ] no other `wards` have been added (check internal txes)
    - [ ] validate IDs
        - [ ] `gemID` is formatted as `RWANNN`
        - [ ] `joinID` is formatted as `MCD_JOIN_RWANNN_A`
        - [ ] `urnID` is formatted as `RWANNN_A_URN`
        - [ ] `inputConduitID` is formatted as `RWANNN_A_INPUT_CONDUIT`
        - [ ] `outputConduitID` is formatted as `RWANNN_A_OUTPUT_CONDUIT`
        - [ ] `pipID` is formatted as `PIP_RWANNN`
    - [ ] validate other constants
        - [ ] `ilk` is formatted as `RWANNN-A`
        - [ ] `ilk_string` is formatted as `RWANNN-A`
        - [ ] `ilkRegistryName` is formatted as `RWANNN-A: Centrifuge: <entity>`
        - [ ] there is a link to a MakerDAO on-chain governance poll where the correct values are defined
        - [ ] `RATE` matches the intended value when converted to a yearly APY and matches the value in the poll
        - [ ] `CEIL` matches the debt ceiling value specified in the poll
        - [ ] `PRICE` is [(`CEIL` + 2 years of fees) * `MAT` * 10^14] (e.g. 2 * 10^6 * 1.06^2 * 1.05)
        - [ ] `MAT` corresponds to the collateralization ratio specified in the poll
        - [ ] `TAU` is usually 0, but can be used as a grace period to remediate and cure()
        - [ ] `DOC` is the IPFS hash of the correct DROP token subscription agreement

### spell-wide checklist

- [ ] validate the spell logic
    - [ ] validate Maker changelog address
    - [ ] make sure there are no contract-scoped storage variables
    - [ ] spell should have (correct) description and hash
    - [ ] spell should use `MIP21_LIQUIDATION_ORACLE`  from changelog
    - [ ] spell should sanity check the join adapter
        - [ ] vat address matches that from the changelog or exec lib
        - [ ] ilk matches that defined in the config
        - [ ] gem matches `GEM` from the config
        - [ ] join decimals match `GEM` decimals
    - [ ] spell calls `init()` on the liqudation oracle
    - [ ] spell files the `pip` from `init()` in the `Spotter`
    - [ ] spell calls `vat.init()` on the `ilk`
    - [ ] spell calls `jug.init()` on the `ilk`
    - [ ] spell auths the new adapter on the `vat`
    - [ ] spell sets the debt ceiling for the `ilk.line` and the global `vat.Line`
    - [ ] spell sets the stability fee
    - [ ] spell sets the collateralization ratio
    - [ ] spell pokes `MCD_SPOT` for `ilk`
    - [ ] the spell `hopes` the `OPERATOR` on the `URN`
    - [ ] spell adds the collateral to the ilk registry
    - [ ] spell stores the following addresses in the `CHANGELOG`
        - [ ] `GEM` stored under `gemID`
        - [ ] `MCD_JOIN` stored under `joinID`
        - [ ] `URN` stored under `urnID`
        - [ ] `INPUT_CONDUIT` stored under `inputConduitID`
        - [ ] `OUTPUT_CONDUIT` stored under `outputConduitID`
        - [ ] `pip` stored under `pipID`
    - [ ] spell bumps the changelog version
