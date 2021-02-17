#!/usr/bin/env bash
set -e

[[ "$ETH_RPC_URL" && "$(seth chain)" == "kovan" ]] || { echo "Please set a kovan ETH_RPC_URL"; exit 1; }

export DAPP_LIBRARIES=' lib/dss-exec-lib/src/DssExecLib.sol:DssExecLib:0xd2406b8A710517fBe1A2218A72271D4Dc43A9D08'
export DAPP_LINK_TEST_LIBRARIES=0

if [[ -z "$1" ]]; then
  dapp --use solc:0.6.11 test --rpc-url="$ETH_RPC_URL" -v
else
  dapp --use solc:0.6.11 test --rpc-url="$ETH_RPC_URL" --match "$1" -vv
fi
