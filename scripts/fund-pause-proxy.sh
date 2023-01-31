#!/usr/bin/env bash
set -e

CHANGELOG="0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F"
NETWORK="goerli"
VALUE="1ether"

[[ "$(cast chain --rpc-url="$ETH_RPC_URL")" == "${NETWORK}" ]] || \
  { echo "Please set a Goerli ETH_RPC_URL"; exit 1; }

MCD_PAUSE_PROXY=$(cast call "${CHANGELOG}" \
  'getAddress(bytes32)(address)' \
  "$(cast --to-bytes32 "$(cast --from-ascii "MCD_PAUSE_PROXY")")")

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
