#!/usr/bin/env bash
set -e

[[ "$(cast chain --rpc-url="$ETH_RPC_URL")" == "goerli" ]] || { echo "Please set a Goerli ETH_RPC_URL"; exit 1; }

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)

    case "$KEY" in
            match)      MATCH="$VALUE" ;;
            block)      BLOCK="$VALUE" ;;
            *)
    esac
done

DSS_EXEC_LIB=$(< DssExecLib.address)
echo "Using DssExecLib at: $DSS_EXEC_LIB"
export DAPP_LIBRARIES="src/DssSpell.sol:DssExecLib:$DSS_EXEC_LIB"
export DAPP_BUILD_OPTIMIZE=0   # forge turns on optimizer by default
export ROOT_BLOCK=0
export OPT_BLOCK=0
export ARB_BLOCK=0

if [[ -z "$MATCH" && -z "$BLOCK" ]]; then
    forge test --force
elif [[ -z "$BLOCK" ]]; then
    forge test --match "$MATCH" -vvv --force
elif [[ -z "$MATCH" ]]; then
    export ROOT_BLOCK=$BLOCK
    forge test -vvv --force
else
    export ROOT_BLOCK=$BLOCK
    forge test --match "$MATCH" -vvv --force
fi
