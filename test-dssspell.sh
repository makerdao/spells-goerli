#!/usr/bin/env bash
set -e

[[ "$ETH_RPC_URL" && "$(seth chain)" == "goerli" ]] || { echo "Please set a Goerli ETH_RPC_URL"; exit 1; }

export DAPP_BUILD_OPTIMIZE=1
export DAPP_BUILD_OPTIMIZE_RUNS=1
export DAPP_LIBRARIES=' lib/dss-exec-lib/src/DssExecLib.sol:DssExecLib:0x0aAcC3bd8852a51538C57918b9E94952A8acE5Da'
export DAPP_LINK_TEST_LIBRARIES=0

if [[ -z "$1" ]]; then
  dapp --use solc:0.6.12 test --rpc-url="$ETH_RPC_URL" -v
else
  dapp --use solc:0.6.12 test --rpc-url="$ETH_RPC_URL" --match "$1" -vv
fi
