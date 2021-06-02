#!/usr/bin/env bash

BIN=$(jq -r '.contracts|.["src/Kovan-DssSpell.sol"]|.DssSpell|.evm|.bytecode|.object' ./out/dapp.sol.json)
seth estimate --create "${BIN}" "DssSpell()"
