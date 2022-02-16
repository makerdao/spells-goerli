#!/usr/bin/env bash
set -e

[[ "$ETH_RPC_URL" ]] || { echo "Please set a ETH_RPC_URL"; exit 1; }

[[ "$1" ]] || { echo "Please specify the ChainLog Key in ASCII to inspect"; exit 1; }

### Override maxFeePerGas to avoid spikes
BASE_FEE=$(seth basefee)
ethGasPriceLtBaseFee=$(echo "$ETH_GAS_PRICE < $BASE_FEE" | bc)
if [[ -n "$ETH_GAS_PRICE" && "$ethGasPriceLtBaseFee" == 1 ]]; then
        export ETH_GAS_PRICE=$(echo "$BASE_FEE * 3" | bc)
fi

CHANGELOG=0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F

if [[ "$1" =~ 0x* ]]; then
        TARGET=$1
else
        KEY=$(seth --to-bytes32 "$(seth --from-ascii "$1")")
        TARGET=$(seth call "$CHANGELOG" 'getAddress(bytes32)(address)' "$KEY")
fi

echo -e "Network: $(seth chain)"
LIST=$(seth call "$CHANGELOG" 'list()(bytes32[])')
for key in $(echo -e "$LIST" | sed "s/,/ /g")
do
        KEY=$(seth --to-ascii "$key" | sed 's/\x0/ /g')
        ADDRESS=$(seth call "$CHANGELOG" 'getAddress(bytes32)(address)' "$key")
        WARDS=$(seth call "$ADDRESS" 'wards(address)(uint256)' "$TARGET" 2>/dev/null) || continue
        [[ "$WARDS" == "1" ]] && echo "$KEY"
        SOURCE=$(seth call "$ADDRESS" 'src()(address)' 2>/dev/null) || continue
        SWARDS=$(seth call "$SOURCE" 'wards(address)(uint256)' "$TARGET" 2>/dev/null) || continue
        [[ "$SWARDS" == "1" ]] && echo "source of $KEY"
done
