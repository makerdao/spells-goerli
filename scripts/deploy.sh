#!/usr/bin/env bash
set -e

[[ "$(cast chain --rpc-url="$ETH_RPC_URL")" == "goerli" ]] || { echo "Please set a Goerli ETH_RPC_URL"; exit 1; }
[[ "$ETHERSCAN_API_KEY" ]] || { echo "Please set ETHERSCAN_API_KEY"; exit 1; }

SOURCE="src/test/config.sol"
KEY_SPELL="deployed_spell"
KEY_TIMESTAMP="deployed_spell_created"
KEY_BLOCK="deployed_spell_block"

# Colors
YELLOW="\033[0;33m"
PURPLE="\033[0;35m"
NC="\033[0m"

make && spell_address=$(dapp create DssSpell)

./scripts/verify.py DssSpell "$spell_address"

# stash any changes in the staging area
(set -x; git stash)

# edit config.sol to add the deployed spell address
sed -Ei "s/($KEY_SPELL: *address\()(0x[[:xdigit:]]{40}|0x0|0)\)/\1$spell_address)/" "$SOURCE"

# get tx hash from contract address, created using an internal transaction
TXHASH=$(curl "https://api-goerli.etherscan.io/api?module=account&action=txlistinternal&address=$spell_address&startblock=0&endblock=99999999&sort=asc&apikey=$ETHERSCAN_API_KEY" | jq -r ".result[0].hash")

# get deployed contract timestamp and block number info
timestamp=$(cast block "$(cast tx "${TXHASH}"|grep blockNumber|awk '{print $2}')"|grep timestamp|awk '{print $2}')
block=$(cast tx "${TXHASH}"|grep blockNumber|awk '{print $2}')

# edit config.sol to add the deployed spell timestamp and block number
sed -i "s/\($KEY_TIMESTAMP *: *\)[0-9]\+/\1$timestamp/" "$SOURCE"
sed -i "s/\($KEY_BLOCK *: *\)[0-9]\+/\1$block/" "$SOURCE"

echo -e "${YELLOW}Network: $(cast chain)${NC}"
echo -e "${YELLOW}config.sol updated with ${PURPLE}deployed spell:${NC} $spell_address, ${PURPLE}timestamp:${NC} $timestamp and ${PURPLE}block:${NC} $block ${NC}"

# commit edit change to config.sol
if [[ $(git status --porcelain src/test/config.sol) ]]; then
    (set -x; git add src/test/config.sol)
    (set -x; git commit -m "add deployed spell info")
else
    echo -e "${PURPLE}Ensure config.sol was edited correctly${NC}"
    exit 1
fi

# reload the staging area with stashed changes
(set -x; git stash apply)
