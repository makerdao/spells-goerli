all             :; DAPP_LIBRARIES=' lib/dss-exec-lib/src/DssExecLib.sol:DssExecLib:0x4aad139a88d2dd5e7410b408593208523a3a891d' \
		    DAPP_BUILD_OPTIMIZE=0 DAPP_BUILD_OPTIMIZE_RUNS=200 \
		    dapp --use solc:0.6.12 build
clean           :; dapp clean
test            :; ./test-dssspell.sh match="$(match)" optimizer="$(optimizer)"
test-dev        :; ./test-dssspell.sh match="$(match)" optimizer="0"
test-forge      :; ./test-dssspell-forge.sh match="$(match)" block="$(block)"
deploy          :; make && dapp create DssSpell | xargs ./verify.py DssSpell
flatten         :; hevm flatten --source-file "src/Goerli-DssSpell.sol" > out/flat.sol
archive-spell   :; ./archive-dssspell.sh "$(if $(date),$(date),$(shell date +'%Y-%m-%d'))"
