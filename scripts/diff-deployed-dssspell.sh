#!/usr/bin/env bash

set -e

[[ "$1" =~  ^0x[0-9a-fA-F]{40}$ ]] || { echo "Please specify the deploy spell address to diff (e.g. spell=0x<deployed_spell>)"; exit 1; }

make all && make flatten

spell_source="out/flat.sol"

# Download the deployed spell source code from Etherscan API
spell_etherscan=$(curl -s "https://api-goerli.etherscan.io/api?module=contract&action=getsourcecode&address=$1" | jq -r '.result[0].SourceCode')

# Compare the downloaded source code with the local spell
diff --color -u <(echo "$spell_etherscan") "$spell_source"

make clean
