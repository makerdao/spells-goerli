#!/usr/bin/env bash
set -e

[[ "$(seth chain --rpc-url="$ETH_RPC_URL")" == "goerli" ]] || { echo "Please set a Goerli ETH_RPC_URL"; exit 1; }

CHANGELOG=0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F
MCD_ADM=$(seth call "$CHANGELOG" 'getAddress(bytes32)(address)' "$(seth --to-bytes32 "$(seth --from-ascii "MCD_ADM")")")
MCD_GOV=$(seth call "$CHANGELOG" 'getAddress(bytes32)(address)' "$(seth --to-bytes32 "$(seth --from-ascii "MCD_GOV")")")
MCD_IOU=$(seth call "$CHANGELOG" 'getAddress(bytes32)(address)' "$(seth --to-bytes32 "$(seth --from-ascii "MCD_IOU")")")
TEN_THOUSAND=$(seth --to-wei 10000 ether)

if [[ -z "$1" ]]; then
    echo "Please specify the Goerli Spell Address"
else
    seth send "$MCD_GOV" 'approve(address,uint256)' "$MCD_ADM" "$TEN_THOUSAND"
    seth send "$MCD_ADM" 'lock(uint256)' "$TEN_THOUSAND"
    
    seth send "$MCD_ADM" 'vote(address[] memory)' ["$spell"]
    seth send "$MCD_ADM" 'lift(address)' "$spell"
    seth send "$spell" 'schedule()'
    
    sleep 60s

    seth send "$MCD_IOU" 'approve(address,uint256)' "$MCD_ADM" "$TEN_THOUSAND"
    seth send "$MCD_ADM" 'free(uint256)' "$TEN_THOUSAND"

    sleep 60s
    
    seth send "$spell" 'cast()'
    echo "Goerli Spell Cast: https://goerli.etherscan.io/address/$spell"
fi
