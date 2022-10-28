#!/usr/bin/env bash
set -e

[[ "$(cast chain --rpc-url="$ETH_RPC_URL")" == "goerli" ]] || { echo "Please set a Goerli ETH_RPC_URL"; exit 1; }
[[ "$ETHERSCAN_API_KEY" ]] || { echo "Please set ETHERSCAN_API_KEY"; exit 1; }

make && \
  forge create DssSpell --libraries "lib/dss-exec-lib/src/DssExecLib.sol:DssExecLib:$(cat DssExecLib.address)" | \
  xargs ./scripts/verify.py DssSpell
