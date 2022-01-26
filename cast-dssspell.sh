#!/usr/bin/env bash
set -e

[[ "$(seth chain --rpc-url="$ETH_RPC_URL")" == "goerli" ]] || { echo "Please set a Goerli ETH_RPC_URL"; exit 1; }

CHANGELOG=0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F
MCD_ADM=$(seth call "$CHANGELOG" 'getAddress(bytes32)(address)' "$(seth --to-bytes32 "$(seth --from-ascii "MCD_ADM")")")
MCD_GOV=$(seth call "$CHANGELOG" 'getAddress(bytes32)(address)' "$(seth --to-bytes32 "$(seth --from-ascii "MCD_GOV")")")
MCD_IOU=$(seth call "$CHANGELOG" 'getAddress(bytes32)(address)' "$(seth --to-bytes32 "$(seth --from-ascii "MCD_IOU")")")
BALANCE=$(seth call "$MCD_GOV" 'balanceOf(address)(uint256)' "$ETH_FROM")
HAT=$(seth call "$MCD_ADM" 'hat()(address)')
APPROVALS=$(seth call "$MCD_ADM" 'approvals(address)(uint256)' "$HAT")
DEPOSITS=$(seth call "$MCD_ADM" 'deposits(address)(uint256)' "$ETH_FROM")
HAT_THRESHOLD=$(seth --to-wei 100000 ETH)
CONTI=1

if [[ -z "$1" ]];
then
    echo "Please specify the Goerli Spell Address"
else
    if [[ "$APPROVALS" -ge "$DEPOSITS" ]] || [[ "$APPROVALS" -lt "$HAT_THRESHOLD" ]];
    then
    GAP=$((HAT_THRESHOLD - APPROVALS))
    DELTA=$((APPROVALS - DEPOSITS + GAP))
    LOCK_AMOUNT=$((DELTA + CONTI))

    [[ "$BALANCE" -ge "$LOCK_AMOUNT" ]] || { echo "$ETH_FROM: Insufficient MKR Balance"; exit 1; }

    seth send "$MCD_GOV" 'approve(address,uint256)' "$MCD_ADM" "$LOCK_AMOUNT"
    seth send "$MCD_ADM" 'lock(uint256)' "$LOCK_AMOUNT"

    DEPOSITS=$(seth call "$MCD_ADM" 'deposits(address)(uint256)' "$ETH_FROM")
    fi

    seth send "$MCD_ADM" 'vote(address[] memory)' ["$1"]
    seth send "$MCD_ADM" 'lift(address)' "$1"

    seth send "$1" 'schedule()'

    sleep 120s

    seth send "$1" 'cast()'

    FREE_AMOUNT=$((DEPOSITS - HAT_THRESHOLD))

    seth send "$MCD_IOU" 'approve(address,uint256)' "$MCD_ADM" "$FREE_AMOUNT"
    seth send "$MCD_ADM" 'free(uint256)' "$FREE_AMOUNT"

    echo "Goerli Spell Cast: https://goerli.etherscan.io/address/$1"
fi
