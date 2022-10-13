#!/usr/bin/env bash
set -e

[[ "$(cast chain --rpc-url="$ETH_RPC_URL")" == "goerli" ]] || { echo "Please set a Goerli ETH_RPC_URL"; exit 1; }
[[ "$ETHERSCAN_API_KEY" ]] || { echo "Please set a ETHERSCAN_API_KEY"; exit 1; }

make && \
  dapp create DssSpell | \
  xargs ./scripts/verify.py DssSpell
