#!/usr/bin/env bash
set -e

# This script assumes a bashrc file located at the following address:
env_config="/home/user/.bashrc"

COMMANDS=""

# This script uses the makefile to streamline the spellcrafting deploy process.
# If you have a global env config set up then just answer no to the envs you don't want to change.
echo "This script will populate environment variables for you so that you are ready to deploy spells"

#export ETH_FROM="address"
#export ETH_PASSWORD="/home/name/makerdao/pass.txt"
#export ETH_KEYSTORE="/home/name/.ethereum/keystore"
#export ETH_RPC_URL="http://127.0.0.1:8545"
#export ETHERSCAN_API_KEY=<API_KEY>

#export ETH_GAS=2000000

#export ETH_PRIO_FEE=$(seth --to-wei 2 "gwei")

# Make the script devtool agnostic
which "seth" | grep -o "seth" > /dev/null &&  tool="seth" || \
which "cast" | grep -o "cast" > /dev/null &&  tool="cast" || \
echo "Please install either DappTools or Forge"

# Check that the script is running on the correct network (GOERLI)
[[ "$ETH_RPC_URL" ]] || { echo "Please set ETH_RPC_URL to use this script"; exit 1; }
[[ "$($tool chain --rpc-url="$ETH_RPC_URL")" == "goerli" ]] || { echo "Please set a Goerli ETH_RPC_URL"; exit 1; }

if (tool=="cast") 
then
    echo "Some helper scripts in the makefile do not support cast at this time. This script will skip them."
fi

echo $tool
# GAS LIMIT
#TODO enable this line for PR [[ "$(make estimate)" ]] #TODO
deploy_gas_limit=4000000;
while true; do
    if [[ "$deploy_gas_limit" -eq 1 ]]
    then
        echo "ERROR: Error with gas limit, skipping";
        echo $deploy_gas_limit;
        break;
    fi
    [[$deploy_gas_limit -gt 10_000_000]] && echo "WARNING: The gas limit appears to be more than 10 million. Please export this value manually." && break;
    read -p "Deploy gas limit will be set to $deploy_gas_limit gas. Is this OK? " yn
    case $yn in
        [Yy]* ) COMMANDS+="export ETH_GAS=$deploy_gas_limit"; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
COMMANDS+=" && "

# BASE GAS PRICE

base_gas_price=$($tool gas-price);

# PRIORITY FEE
# TODO make this 5% of base with a ceiling

# ETH RPC URL ==> Add a fallback to the team public lighthouse

# Etherscan API key ==> Make a dummy one? Or will scrapers use this maliciously?

# Password source (prompt drag and drop AND offer skip)

# Keystore check ethsign ls AND offer prompt

# From ==> Ethsign? Or other? Allow both

# Construct prompt and spit out (or copy to clipboard)


echo $COMMANDS "inside the runtime"



#export ETH_GAS_PRICE=

