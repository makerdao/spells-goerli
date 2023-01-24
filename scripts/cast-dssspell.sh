#!/usr/bin/env bash
set -e

[[ "$(cast chain --rpc-url="$ETH_RPC_URL")" == "goerli" ]] || { echo "Please set a Goerli ETH_RPC_URL"; exit 1; }

### ChainLog
CHANGELOG=0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F
MCD_ADM=$(cast call "$CHANGELOG" 'getAddress(bytes32)(address)' "$(cast --to-bytes32 "$(cast --from-ascii "MCD_ADM")")")
MCD_GOV=$(cast call "$CHANGELOG" 'getAddress(bytes32)(address)' "$(cast --to-bytes32 "$(cast --from-ascii "MCD_GOV")")")
MCD_IOU=$(cast call "$CHANGELOG" 'getAddress(bytes32)(address)' "$(cast --to-bytes32 "$(cast --from-ascii "MCD_IOU")")")

### Data
DESIRED_HAT_APPROVALS=$(cast --to-wei 100000 ETH)
hat=$(cast call "$MCD_ADM" 'hat()(address)')
approvals=$(cast call "$MCD_ADM" 'approvals(address)(uint256)' "$hat")
deposits=$(cast call "$MCD_ADM" 'deposits(address)(uint256)' "$ETH_FROM")

ETH_NONCE=$(cast nonce "$ETH_FROM")

castSend() {
    set -e
    echo "cast send $*"
    ETH_GAS=$(cast estimate "$@")
    ETH_GAS=$((ETH_GAS * 2))
    echo "Sending with $ETH_GAS gas."
    ETH_NONCE="$ETH_NONCE" ETH_GAS="$ETH_GAS" cast send "$@"
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
        [[ "$(echo "$(cast call "$MCD_GOV" 'balanceOf(address)(uint256)' "$ETH_FROM") >= $lockAmt" | bc)" == 1 ]] || { echo "$ETH_FROM: Insufficient MKR Balance"; exit 1; }

        castSend "$MCD_GOV" 'approve(address,uint256)' "$MCD_ADM" "$lockAmt"
        castSend "$MCD_ADM" 'lock(uint256)' "$lockAmt"

        deposits=$(cast call "$MCD_ADM" 'deposits(address)(uint256)' "$ETH_FROM")
    fi

    castSend "$MCD_ADM" 'vote(address[] memory)' ["$1"]
    castSend "$MCD_ADM" 'lift(address)' "$1"

    castSend "$1" 'schedule()'

    echo "waiting for two minutes before casting…"
    sleep 120

    castSend "$1" 'cast()'

    if [[ "$(echo "$deposits > $DESIRED_HAT_APPROVALS" | bc)" == 1 ]]; then
        freeAmt=$(echo "$deposits - $DESIRED_HAT_APPROVALS" | bc)
        [[ "$(echo "$(cast call "$MCD_IOU" 'balanceOf(address)(uint256)' "$ETH_FROM") >= $freeAmt" | bc)" == 1 ]] || { echo "$ETH_FROM: Insufficient IOU Balance"; exit 1; }
        castSend "$MCD_IOU" 'approve(address,uint256)' "$MCD_ADM" "$freeAmt"
        castSend "$MCD_ADM" 'free(uint256)' "$freeAmt"
    fi

    echo "Goerli Spell Cast: https://goerli.etherscan.io/address/$1"
fi
