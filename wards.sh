#!/usr/bin/env bash
set -e

[[ "$ETH_RPC_URL" ]] || { echo "Please set a ETH_RPC_URL"; exit 1; }

[[ "$1" ]] || { echo "Please specify the ChainLog Key in ASCII to inspect"; exit 1; }

### Override maxFeePerGas to avoid spikes
BASE_FEE=$(seth basefee)
if [ -n "$ETH_GAS_PRICE" ] && [ "$ETH_GAS_PRICE" -lt "$BASE_FEE" ]; then
        ETH_GAS_PRICE=$((BASE_FEE * 3))
fi

CHANGELOG=0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F
KEY=$(seth --to-bytes32 "$(seth --from-ascii "$1")")
TARGET=$(seth call "$CHANGELOG" 'getAddress(bytes32)(address)' "$KEY")

echo -e "Network: $(seth chain)"
LIST=$(seth call "$CHANGELOG" 'list()(bytes32[])')
for key in $(echo -e "$LIST" | sed "s/,/ /g")
do
        ADDRESS=$(seth call "$CHANGELOG" 'getAddress(bytes32)(address)' "$key")
        WARDS=$(seth call "$ADDRESS" 'wards(address)(uint256)' "$TARGET" 2>/dev/null) || continue
        [[ "$WARDS" == "1" ]] && seth --to-ascii "$key"
done
