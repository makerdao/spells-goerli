all                :; DAPP_LIBRARIES=' lib/dss-exec-lib/src/DssExecLib.sol:DssExecLib:$(shell cat DssExecLib.address)' \
                       DAPP_BUILD_OPTIMIZE=0 DAPP_BUILD_OPTIMIZE_RUNS=200 \
                       dapp --use solc:0.8.16 build
clean              :; forge clean
                      # Usage example: make test match=SpellIsCast
test               :; ./scripts/test-dssspell-forge.sh match="$(match)" block="$(block)"
test-forge         :; ./scripts/test-dssspell-forge.sh match="$(match)" block="$(block)"
estimate           :; ./scripts/estimate-deploy-gas.sh
deploy             :; ./scripts/deploy.sh
deploy-info        :; ./scripts/get-deploy-info.sh tx=$(tx)
verify             :; ./scripts/verify.py DssSpell $(addr)
flatten            :; hevm flatten --source-file "src/DssSpell.sol" > out/flat.sol
cast-spell         :; ./scripts/cast-dssspell.sh $(spell)
archive-spell      :; ./scripts/archive-dssspell.sh "$(if $(date),$(date),$(shell date +'%Y-%m-%d'))"
diff-archive-spell :; ./scripts/diff-archive-dssspell.sh "$(if $(date),$(date),$(shell date +'%Y-%m-%d'))"
wards              :; ./scripts/wards.sh $(target)
time               :; ./scripts/time.sh date="$(date)" stamp="$(stamp)"
exec-hash          :; ./scripts/hash-exec-copy.sh "$(if $(date),$(date),$(shell date +'%Y-%m-%d'))"
rates              :; ./scripts/rates.sh $(pct)
