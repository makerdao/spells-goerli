#!/usr/bin/env bash
set -e

NETWORK="goerli"
VALUE="1ether"

[[ "$(cast chain --rpc-url="$ETH_RPC_URL")" == "${NETWORK}" ]] || \
  { echo "Please set a Goerli ETH_RPC_URL"; exit 1; }

MCD_PAUSE_PROXY=$(curl -s https://chainlog.makerdao.com/api/${NETWORK}/active.json | \
  grep MCD_PAUSE_PROXY | \
  awk -F"\"" '{print $4}')

echo "Pause Proxy ETH balance (wei) before Bombshell: $(cast balance "${MCD_PAUSE_PROXY}")"

echo "Deploying Bombshell with ${VALUE}..."
BOMBSHELL=$(forge create \
  --json \
  --value ${VALUE} \
  ./src/util/Bombshell.sol:Bombshell \
  --constructor-args "${MCD_PAUSE_PROXY}" | \
  jq -r '.deployedTo')

echo "Detonating Bombshell..."
cast send ${BOMBSHELL} 'boom()' > /dev/null 2>&1

echo "Pause Proxy ETH balance (wei) after Bombshell: $(cast balance "${MCD_PAUSE_PROXY}")"
