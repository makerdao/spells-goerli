#!/usr/bin/env bash
set -e

echo "This script will populate environment variables for you so that you are ready to deploy spells"

#export ETH_FROM="address"
#export ETH_PASSWORD="/home/name/makerdao/pass.txt"
#export ETH_KEYSTORE="/home/name/.ethereum/keystore"
#export ETH_RPC_URL="http://127.0.0.1:8545"
#export ETHERSCAN_API_KEY=<API_KEY>

#export ETH_GAS=2000000

#export ETH_PRIO_FEE=$(seth --to-wei 2 "gwei")

tool="cast"

[[ "$ETH_RPC_URL" ]] || { echo "Please set ETH_RPC_URL to use this script"; exit 1; }
#TODO make this cast/seth agnostic
[[ "$($tool chain --rpc-url="$ETH_RPC_URL")" == "goerli" ]] || { echo "Please set a Goerli ETH_RPC_URL"; exit 1; }
#export ETH_GAS_PRICE=$(seth --to-wei 40 "gwei")


while true; do
    read -p "Do you wish to install this program? " yn
    case $yn in
        [Yy]* ) make install; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
