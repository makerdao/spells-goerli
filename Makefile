all                :; DAPP_LIBRARIES=' lib/dss-exec-lib/src/DssExecLib.sol:DssExecLib:$(shell cat DssExecLib.address)' \
                       DAPP_BUILD_OPTIMIZE=0 DAPP_BUILD_OPTIMIZE_RUNS=200 \
                       dapp --use solc:0.6.12 build
clean              :; dapp clean
                      # Usage example: make test match=SpellIsCast
test               :; ./scripts/test-dssspell.sh match="$(match)" optimizer="$(optimizer)" optimizer-runs="$(optimizer-runs)" block="$(block)"
test-dev           :; ./scripts/test-dssspell.sh match="$(match)" optimizer="1" optimizer-runs="$(optimizer-runs)" block="$(block)"
test-forge         :; ./scripts/test-dssspell-forge.sh match="$(match)" block="$(block)"
estimate           :; ./scripts/estimate-deploy-gas.sh
deploy             :; make && dapp create DssSpell | xargs ./scripts/verify.py DssSpell
deploy-stamp       :; ./scripts/get-created-timestamp.sh tx=$(tx)
flatten            :; hevm flatten --source-file "src/Goerli-DssSpell.sol" > out/flat.sol
cast-spell         :; ./scripts/cast-dssspell.sh $(spell)
archive-spell      :; ./scripts/archive-dssspell.sh "$(if $(date),$(date),$(shell date +'%Y-%m-%d'))"
diff-archive-spell :; ./scripts/diff-archive-dssspell.sh "$(if $(date),$(date),$(shell date +'%Y-%m-%d'))"
wards              :; ./scripts/wards.sh $(target)
time               :; ./scripts/time.sh date="$(date)" stamp="$(stamp)"
