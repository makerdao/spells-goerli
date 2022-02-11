#!/usr/bin/env bash
set -e

[[ "$(seth chain --rpc-url="$ETH_RPC_URL")" == "goerli" ]] || { echo "Please set a Goerli ETH_RPC_URL"; exit 1; }

### ChainLog
CHANGELOG=0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F
MCD_ADM=$(seth call "$CHANGELOG" 'getAddress(bytes32)(address)' "$(seth --to-bytes32 "$(seth --from-ascii "MCD_ADM")")")
MCD_GOV=$(seth call "$CHANGELOG" 'getAddress(bytes32)(address)' "$(seth --to-bytes32 "$(seth --from-ascii "MCD_GOV")")")
MCD_IOU=$(seth call "$CHANGELOG" 'getAddress(bytes32)(address)' "$(seth --to-bytes32 "$(seth --from-ascii "MCD_IOU")")")

### Data
HAT_THRESHOLD=$(seth --to-wei 100000 ETH)
CONTI=1
balanceGOV=$(seth call "$MCD_GOV" 'balanceOf(address)(uint256)' "$ETH_FROM")
balanceIOU=$(seth call "$MCD_IOU" 'balanceOf(address)(uint256)' "$ETH_FROM")
hat=$(seth call "$MCD_ADM" 'hat()(address)')
approvals=$(seth call "$MCD_ADM" 'approvals(address)(uint256)' "$hat")
deposits=$(seth call "$MCD_ADM" 'deposits(address)(uint256)' "$ETH_FROM")

if [[ -z "$1" ]];
then
    echo "Please specify the Goerli Spell Address"
else
    ### Check Approvals and Deposits to Lock MKR
    approvalsGeDeposits=$(echo "$approvals >= $deposits" | bc)
    approvalsLtHatThreshold=$(echo "$approvals < $HAT_THRESHOLD" | bc)
    if [[ "$approvalsGeDeposits" == 1  ||  "$approvalsLtHatThreshold" == 1 ]]; then
        gap=$(echo "$HAT_THRESHOLD - $approvals" | bc)
        delta=$(echo "$approvals - $deposits + $gap" | bc)
        lockAmt=$(echo "$delta + $CONTI" | bc)

        ### Check MKR Balance
        balanceGOVGeLockAmt=$(echo "$balanceGOV >= $lockAmt" | bc)
        [[ "$balanceGOVGeLockAmt" == 1 ]] || { echo "$ETH_FROM: Insufficient MKR Balance"; exit 1; }

        seth send "$MCD_GOV" 'approve(address,uint256)' "$MCD_ADM" "$lockAmt"
        seth send "$MCD_ADM" 'lock(uint256)' "$lockAmt"

        deposits=$(seth call "$MCD_ADM" 'deposits(address)(uint256)' "$ETH_FROM")
        balanceIOU=$(seth call "$MCD_IOU" 'balanceOf(address)(uint256)' "$ETH_FROM")
    fi

    seth send "$MCD_ADM" 'vote(address[] memory)' ["$1"]
    seth send "$MCD_ADM" 'lift(address)' "$1"

    seth send "$1" 'schedule()'

    sleep 120s

    seth send "$1" 'cast()'

    freeAmt=$(echo "$deposits - $HAT_THRESHOLD" | bc)

    ### Check IOU Balance
    balanceIOUGeFreeAmt=$(echo "$balanceIOU >= $freeAmt" | bc)
    [[ "$balanceIOUGeFreeAmt" == 1 ]] || { echo "$ETH_FROM: Insufficient IOU Balance"; exit 1; }

    seth send "$MCD_IOU" 'approve(address,uint256)' "$MCD_ADM" "$freeAmt"
    seth send "$MCD_ADM" 'free(uint256)' "$freeAmt"

    echo "Goerli Spell Cast: https://goerli.etherscan.io/address/$1"
fi
