#!/usr/bin/env bash
set -e

#TODO check if the user has cast or seth 
[[ "$(cast chain --rpc-url="$ETH_RPC_URL")" == "goerli" ]] || { echo "Please set a Goerli ETH_RPC_URL"; exit 1; }
[[ "$ETHERSCAN_API_KEY" ]] || { echo "Please set ETHERSCAN_API_KEY"; exit 1; }
#[[ "$ETH_FROM" ]] || { echo "Please set ETH_FROM value (the address that the transaction is being sent from)"; exit 1; }
#[[ "$ETH_KEYSTORE" ]] || { echo "Please set ETH_KEYSTORE (the keystore file location for ethsign to use)"; exit 1; }
#[[ "$ETH_PASSWORD" ]] || { echo "Please set ETH_PASSWORD (the password.txt file location for ethsign to use)"; exit 1; }
#[[ "$ETH_GAS" ]] || { echo "Please set ETH_GAS (gas limit)"; exit 1; }
#[[ "$ETH_GAS_PRICE" ]] || { echo "Please set a ETH_GAS_PRICE (base gas price)"; exit 1; }
#[[ "$ETH_PRIO_FEE" ]] || { echo "Please set a ETH_PRIO_FEE (priority gas price)"; exit 1; }

make && \
  dapp create DssSpell | \
  xargs ./scripts/verify.py DssSpell
