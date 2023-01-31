#!/usr/bin/env bash
set -e

OPTIMISM_GOERLI_RPC_URL='https://goerli.optimism.io'

L2_SPELL='0xC077Eb64285b40C86B40769e99Eb1E61d682a6B4'

L1_GOV_RELAY='0xD9b2835A5bFC8bD5f54DB49707CF48101C66793a'
L2_GOV_RELAY='0x10E6593CDda8c58a1d0f14C5164B376352a55f2F'

L2_MESSENGER='0x4200000000000000000000000000000000000007'
X_DOMAIN_MSG_SENDER_SLOT=204

anvil -f $OPTIMISM_GOERLI_RPC_URL > /dev/null 2>&1 &
pid=$!
sleep 10
cast rpc anvil_setStorageAt $L2_MESSENGER \
    $(printf 0x"%064X\n" $X_DOMAIN_MSG_SENDER_SLOT) \
    $(printf 0x"%064s\n" ${L1_GOV_RELAY:2} | tr ' ' 0) > /dev/null

OPT_GAS=$(
    cast estimate  --from $L2_MESSENGER \
    $L2_GOV_RELAY \
    "relay(address,bytes)" \
    $L2_SPELL \
    $(cast calldata "execute()")
)
kill $pid

echo "OPT_GAS = $OPT_GAS"
