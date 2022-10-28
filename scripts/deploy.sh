#!/usr/bin/env bash
#set -e # prod
set -x # testing

[[ "$(cast chain --rpc-url="$ETH_RPC_URL")" == "goerli" ]] || { echo "Please set a Goerli ETH_RPC_URL"; exit 1; }
[[ "$ETHERSCAN_API_KEY" ]] || { echo "Please set ETHERSCAN_API_KEY"; exit 1; }

# TODO Test ETH_FROM is set
ETH_FROM_TRIMMED="${ETH_FROM:2}"
ETH_KEYFILE="$(find $ETH_KEYSTORE | grep ${ETH_FROM_TRIMMED,,})"

make && \
  forge create DssSpell \
    --keystore "$ETH_KEYFILE" \     # forge currently requires full path to keyfile
    --password "$(cat $ETH_PASSWORD)" \
    --libraries "lib/dss-exec-lib/src/DssExecLib.sol:DssExecLib:$(cat DssExecLib.address)" | \
  # xargs ./scripts/verify.py DssSpell
  xargs python3 -m trace -t ./scripts/verify.py DssSpell
