#!/usr/bin/env bash
set -e

[[ "$(cast chain --rpc-url="$ETH_RPC_URL")" == "goerli" ]] || { echo "Please set a Goerli ETH_RPC_URL"; exit 1; }
[[ "$ETHERSCAN_API_KEY" ]] || { echo "Please set ETHERSCAN_API_KEY"; exit 1; }

SOURCE="src/test/config.sol"
KEY="deployed_spell"

make && spell_address=$(dapp create DssSpell)

./scripts/verify.py DssSpell "$spell_address"

sed -Ei "s/($KEY: *address\()(0x[0-9a-fA-F]{40}\))/\1$spell_address)/" "$SOURCE"
