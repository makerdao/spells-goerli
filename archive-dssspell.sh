#!/usr/bin/env bash
set -e

if [[ -z "$1" ]]; then
  echo "You must provide a name option to name the directory"
else
  mkdir "./archive/$1-DssSpell"
  mkdir "./archive/$1-DssSpell/test"
  cp "./src/Goerli-DssSpell.sol" "./archive/$1-DssSpell"
  cp "./src/Goerli-DssSpellCollateralOnboarding.sol" "./archive/$1-DssSpell"
  cp "./src/Goerli-DssSpell.t.sol" "./archive/$1-DssSpell"
  cp "./src/Goerli-DssSpell.t.base.sol" "./archive/$1-DssSpell"
  cp ./src/test/* "./archive/$1-DssSpell/test"
  echo "Spell, tests and base copied to archive directory $1-DssSpell"
fi
