#!/usr/bin/env bash

set -e

# Define colors
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m' # No Color

function success_check() {
  echo -e "[${GREEN}✔${NC}] ${GREEN}$1${NC}"
}

function error_check() {
  echo -e "[${RED}✖${NC}] ${RED}$1${NC}"
}

[[ "$(cast chain --rpc-url="$ETH_RPC_URL")" == "goerli" ]] || { echo -e "Please set a Goerli ETH_RPC_URL"; exit 1; }
[[ "$ETHERSCAN_API_KEY" ]] || { echo -e "Please set ETHERSCAN_API_KEY"; exit 1; }

# Etherscan API endpoint
ETHERSCAN_API="https://api-goerli.etherscan.io/api"

# Path to config.sol file
CONFIG_PATH="src/test/config.sol"

# Read contract address, block number, and timestamp from Solidity source code
deployed_spell_address=$(grep -oE 'deployed_spell:\s+address\((0x[a-fA-F0-9]+)\)' $CONFIG_PATH | sed -E 's/^.*\((.*)\)/\1/')
deployed_spell_block=$(grep -oE 'deployed_spell_block\s*:\s*[0-9]+' $CONFIG_PATH | sed -E 's/.*:\s*//')
deployed_spell_timestamp=$(grep -oE 'deployed_spell_created\s*:\s*[0-9]+' $CONFIG_PATH | sed -E 's/.*:\s*//')

# Check if contract address, block number, and timestamp are zero
if [[ "$deployed_spell_address" =~ ^(address\(0\)|0)$ ]] || [[ "$deployed_spell_block" = "0" ]] || [[ "$deployed_spell_timestamp" = "0" ]]; then
  error_check "DssSpell address, block number, or timestamp is not set in config file."
else
  success_check "DssSpell address, block number, and timestamp are set in config file."
fi

# Get contract verification information
verified_spell_info=$(curl -s "$ETHERSCAN_API?module=contract&action=getsourcecode&address=$deployed_spell_address" | jq -r .result[0])

# Check contract source code
local_dss_spell=$(awk '/contract DssSpell\s*\{/,/\}/' "src/DssSpell.sol")
verified_spell_source="${verified_spell_info}.sourceCode"
verified_dss_spell=$(echo "$verified_spell_source" | awk '/contract DssSpell\s*\{/,/\}/')

if [ "$local_dss_spell" != "$verified_dss_spell" ]; then
  error_check "DssSpell verified source does not match local source."
else
  success_check "DssSpell verified source matches local source."
fi

# Check contract verification status
verified="${verified_spell_info}.verified"
if ! [ "$verified" ]; then
  error_check "DssSpell not verified."
else
  success_check "DssSpell is verified."
fi

# Check contract optimizations
optimized=$(echo "$verified_spell_info" | jq -r '.OptimizationUsed == "1"')
if [ "$optimized" = "true" ]; then
  error_check "DssSpell was compiled with optimizations."
else
  success_check "DssSpell was not compiled with optimizations."
fi

# Check contract library
library_address=$(echo "$verified_spell_info" | jq -r '.Library | split(":") | .[1]')
checksum_library_address=$(cast --to-checksum-address "$library_address")
if [ "$checksum_library_address" != "$(cat DssExecLib.address)" ]; then
  error_check "DssSpell library does not match hardcoded address."
else
  success_check "DssSpell library matches hardcoded address in DssExecLib.address."
fi

# Retrieve transaction hash
tx_hash=$(curl -s "https://api-goerli.etherscan.io/api?module=account&action=txlistinternal&address=$deployed_spell_address&startblock=0&endblock=99999999&sort=asc&apikey=$ETHERSCAN_API_KEY" | jq -r ".result[0].hash")

# Retrieve deployed contract timestamp and block number info
timestamp=$(cast block "$(cast tx "${tx_hash}"|grep blockNumber|awk '{print $2}')"|grep timestamp|awk '{print $2}')
block=$(cast tx "${tx_hash}"|grep blockNumber|awk '{print $2}')

# Check contract timestamp and block number
if [ "$timestamp" != "$deployed_spell_timestamp" ]; then
  error_check "DssSpell deployment timestamp does not match."
else
  success_check "DssSpell deployment timestamp matches."
fi

if [ "$block" != "$deployed_spell_block" ]; then
  error_check "DssSpell deployment block number does not match."
else
  success_check "DssSpell deployment block number matches."
fi

success_check "DssSpell deployment checks successful."
