#!/usr/bin/env bash
set -e

[[ "$(seth chain --rpc-url="$ETH_RPC_URL")" == "goerli" ]] || { echo "Please set a Goerli ETH_RPC_URL"; exit 1; }

### ChainLog
CHANGELOG=0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F
MCD_ADM=$(seth call "$CHANGELOG" 'getAddress(bytes32)(address)' "$(seth --to-bytes32 "$(seth --from-ascii "MCD_ADM")")")
MCD_GOV=$(seth call "$CHANGELOG" 'getAddress(bytes32)(address)' "$(seth --to-bytes32 "$(seth --from-ascii "MCD_GOV")")")
MCD_IOU=$(seth call "$CHANGELOG" 'getAddress(bytes32)(address)' "$(seth --to-bytes32 "$(seth --from-ascii "MCD_IOU")")")

### Data
DESIRED_HAT_APPROVALS=$(seth --to-wei 100000 ETH)
hat=$(seth call "$MCD_ADM" 'hat()(address)')
approvals=$(seth call "$MCD_ADM" 'approvals(address)(uint256)' "$hat")
deposits=$(seth call "$MCD_ADM" 'deposits(address)(uint256)' "$ETH_FROM")

ETH_NONCE=$(seth nonce "$ETH_FROM")

sethSend() {
    set -e
    echo "seth send $*"
    ETH_NONCE="$ETH_NONCE" ETH_GAS=$(seth estimate "$@") seth send "$@"
    ETH_NONCE=$((ETH_NONCE + 1))
    echo ""
}

if [[ -z "$1" ]];
then
    echo "Please specify the Goerli Spell Address"
else
    target=$DESIRED_HAT_APPROVALS
    if [[ "$(echo "$approvals + 1 >= $target" | bc)" == 1 ]]; then
        target=$(echo "$approvals + 1" | bc)
    fi

    if [[ "$(echo "$deposits < $target" | bc)" == 1 ]]; then
        lockAmt=$(echo "$target - $deposits" | bc)
        [[ "$(echo "$(seth call "$MCD_GOV" 'balanceOf(address)(uint256)' "$ETH_FROM") >= $lockAmt" | bc)" == 1 ]] || { echo "$ETH_FROM: Insufficient MKR Balance"; exit 1; }

        sethSend "$MCD_GOV" 'approve(address,uint256)' "$MCD_ADM" "$lockAmt"
        sethSend "$MCD_ADM" 'lock(uint256)' "$lockAmt"

        deposits=$(seth call "$MCD_ADM" 'deposits(address)(uint256)' "$ETH_FROM")
    fi

    sethSend "$MCD_ADM" 'vote(address[] memory)' ["$1"]
    sethSend "$MCD_ADM" 'lift(address)' "$1"

    sethSend "$1" 'schedule()'

    echo "waiting for two minutes before casting…"
    sleep 120

    sethSend "$1" 'cast()'

    if [[ "$(echo "$deposits > $DESIRED_HAT_APPROVALS" | bc)" == 1 ]]; then
        freeAmt=$(echo "$deposits - $DESIRED_HAT_APPROVALS" | bc)
        [[ "$(echo "$(seth call "$MCD_IOU" 'balanceOf(address)(uint256)' "$ETH_FROM") >= $freeAmt" | bc)" == 1 ]] || { echo "$ETH_FROM: Insufficient IOU Balance"; exit 1; }
        sethSend "$MCD_IOU" 'approve(address,uint256)' "$MCD_ADM" "$freeAmt"
        sethSend "$MCD_ADM" 'free(uint256)' "$freeAmt"
    fi

    echo "Goerli Spell Cast: https://goerli.etherscan.io/address/$1"
fi
