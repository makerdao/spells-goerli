#!/usr/bin/env bash
set -e

if [[ -z "$1" ]]; then
  echo "You must provide a date (YYYY-MM-DD) option to diff the directory"
else
  diff "./src/Goerli-DssSpell.sol" "./archive/$1-DssSpell/"
  diff "./src/Goerli-DssSpellCollateralOnboarding.sol" "./archive/$1-DssSpell/"
  diff "./src/Goerli-DssSpell.t.sol" "./archive/$1-DssSpell/"
  diff "./src/Goerli-DssSpell.t.base.sol" "./archive/$1-DssSpell/"
  diff -r "./src/test" "./archive/$1-DssSpell/test"
  echo "Spell, tests and base match the archive directory $1-DssSpell"
fi
