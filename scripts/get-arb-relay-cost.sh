#!/usr/bin/env bash
set -e

[[ "$(cast chain --rpc-url="$ETH_RPC_URL")" == "goerli" ]] || { echo "Please set a Goerli ETH_RPC_URL"; exit 1; }

ARBITRUM_GOERLI_RPC_URL='https://goerli-rollup.arbitrum.io/rpc'

L2_SPELL='0x11dc6ed4c08da38b36709a6c8dbaac0eaedd48ca'

INBOX='0x6BEbC4925716945D46F0Ec336D5C2564F419682C'
L1_GOV_RELAY='0x10E6593CDda8c58a1d0f14C5164B376352a55f2F'
L2_GOV_RELAY='0x10E6593CDda8c58a1d0f14C5164B376352a55f2F'

NODE_INTERFACE='0x00000000000000000000000000000000000000C8'

ARB_GAS_PRICE_BID=$(cast gas-price --rpc-url $ARBITRUM_GOERLI_RPC_URL)
RELAY_CALLDATA=$(
    cast calldata "relay(address,bytes)" $L2_SPELL $(cast calldata "execute()")
)
ARB_MAX_GAS=$(
    cast estimate --rpc-url $ARBITRUM_GOERLI_RPC_URL \
    $NODE_INTERFACE \
    "estimateRetryableTicket(address,uint256,address,uint256,address,address,bytes)" \
    $L1_GOV_RELAY \
    1000000000000000000 \
    $L2_GOV_RELAY \
    0 \
    $L2_GOV_RELAY \
    $L2_GOV_RELAY \
    $RELAY_CALLDATA
)
RELAY_CALLDATA_LEN=$(( $(echo -n $RELAY_CALLDATA | wc -c) / 2 - 1 ))
SUBMISSION_FEE=$(
    cast call $INBOX \
    "calculateRetryableSubmissionFee(uint256,uint256)(uint256)" \
    $RELAY_CALLDATA_LEN \
    0
)
ARB_MAX_SUBMISSION_COST=$(($SUBMISSION_FEE * 4))
ARB_L1_CALL_VALUE=$(($ARB_MAX_GAS * $ARB_GAS_PRICE_BID + $ARB_MAX_SUBMISSION_COST))

echo "ARB_MAX_GAS             = $ARB_MAX_GAS"
echo "ARB_GAS_PRICE_BID       = $ARB_GAS_PRICE_BID"
echo "ARB_MAX_SUBMISSION_COST = $ARB_MAX_SUBMISSION_COST"
echo "ARB_L1_CALL_VALUE       = $ARB_L1_CALL_VALUE"
