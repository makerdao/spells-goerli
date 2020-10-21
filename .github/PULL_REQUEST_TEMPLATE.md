# Description

Spell Description:

COB Team Name or Author(s):

# Contribution Checklist

- [ ] First commit title starts with COB Team Name and Collateral type (e.g. `___-TOKEN-X`)
- [ ] Code approved
- [ ] Tests approved
- [ ] CI Tests pass

# Checklist

- [ ] Every contract variable/method declared as public/external private/internal
- [ ] Verify expiration (`4 days + 2 hours` monthly and `30 days` for the rest)
- [ ] Verify hash in the description matches [here](https://emn178.github.io/online-tools/keccak_256.html)
- [ ] Validate all addresses used are in Kovan changelog
- [ ] Deploy spell to kovan `SOLC_FLAGS="--optimize --optimize-runs=1" dapp --use solc:0.5.12 --network kovan build --extract && dapp create DssSpell --verify --network kovan --gas=XXX --gas-price="$(seth --to-wei YYY "gwei")"`
- [ ] Ensure contract is verified on `kovan` etherscan
- [ ] Change test to use kovan spell address and deploy timestamp
- [ ] Keep `Kovan-DssSpell.sol` and `Kovan-DssSpell.t.sol` the same, but make a copy in `archive`
- [ ] `squash and merge` this PR
