#!/usr/bin/env bash
set -e

[[ "$(seth chain --rpc-url="$ETH_RPC_URL")" == "goerli" ]] || { echo "Please set a Goerli ETH_RPC_URL"; exit 1; }

for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)

    case "$KEY" in
            match)      MATCH="$VALUE" ;;
            block)      BLOCK="$VALUE" ;;
            *)
    esac
done

DSS_EXEC_LIB='src/DssSpell.sol:DssExecLib:0x4aad139a88d2dd5e7410b408593208523a3a891d'

if [[ -z "$MATCH" && -z "$BLOCK" ]]; then
    forge test --fork-url "$ETH_RPC_URL" --libraries $DSS_EXEC_LIB -vvv --force
elif [[ -z "$BLOCK" ]]; then
    forge test --fork-url "$ETH_RPC_URL" --libraries $DSS_EXEC_LIB --match "$MATCH" -vvv --force
elif [[ -z "$MATCH" ]]; then
    forge test --fork-url "$ETH_RPC_URL" --libraries $DSS_EXEC_LIB --fork-block-number "$BLOCK" -vvv --force
else
    forge test --fork-url "$ETH_RPC_URL" --libraries $DSS_EXEC_LIB --match "$MATCH" --fork-block-number "$BLOCK" -vvv --force
fi
