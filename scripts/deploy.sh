#!/usr/bin/env bash
set -e

[[ "$(cast chain --rpc-url="$ETH_RPC_URL")" == "goerli" ]] || { echo "Please set a Goerli ETH_RPC_URL"; exit 1; }
[[ "$ETHERSCAN_API_KEY" ]] || { echo "Please set ETHERSCAN_API_KEY"; exit 1; }

SOURCE="src/test/config.sol"
KEY_TIMESTAMP="deployed_spell_created"
KEY_BLOCK="deployed_spell_block"

make && spell_address=$(dapp create DssSpell)

./scripts/verify.py DssSpell "$spell_address"

# edit config.sol to add the deployed spell address
sed -Ei "s/($KEY: *address\()(0x[[:xdigit:]]{40}|0)\)/\1$spell_address)/" "$SOURCE"

# get tx hash from contract address, created using an internal transaction
TXHASH=$(curl "https://api.etherscan.io/api?module=account&action=txlistinternal&address=$spell_address&startblock=0&endblock=99999999&sort=asc&apikey=$ETHERSCAN_API_KEY" | jq ".result[0].hash")

# get deployed contract timestamp and block number info
timestamp=$(cast block "$(cast tx "${TXHASH}"|grep blockNumber|awk '{print $2}')"|grep timestamp|awk '{print $2}')
block=$(cast tx "${TXHASH}"|grep blockNumber|awk '{print $2}')

# edit config.sol to add the deployed spell timestamp and block number
sed -i "s/\($KEY_TIMESTAMP *: *\)[0-9]\+/\1$timestamp/" "$SOURCE"
sed -i "s/\($KEY_BLOCK *: *\)[0-9]\+/\1$block/" "$SOURCE"

echo -e "Network: $(cast chain)"
echo "config.sol updated with deployed spell address, timestamp and block"
