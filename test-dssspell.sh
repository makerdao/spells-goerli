#!/usr/bin/env bash
set -e

[[ "$ETH_RPC_URL" && "$(seth chain)" == "kovan" ]] || { echo "Please set a kovan ETH_RPC_URL"; exit 1; }

export DAPP_BUILD_OPTIMIZE=1
export DAPP_BUILD_OPTIMIZE_RUNS=1
export DAPP_LIBRARIES=' lib/dss-exec-lib/src/DssExecLib.sol:DssExecLib:0xe13b71Add2B152a113305D0A7b49ec7fCfb3b1f2'
export DAPP_LINK_TEST_LIBRARIES=0

if [[ -z "$1" ]]; then
  dapp --use solc:0.6.12 test --rpc-url="$ETH_RPC_URL" -v
else
  dapp --use solc:0.6.12 test --rpc-url="$ETH_RPC_URL" --match "$1" -vv
fi
