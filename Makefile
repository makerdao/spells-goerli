all    :; DAPP_LIBRARIES=' lib/dss-exec-lib/src/DssExecLib.sol:DssExecLib:0xe13b71Add2B152a113305D0A7b49ec7fCfb3b1f2' \
          DAPP_BUILD_OPTIMIZE=1 DAPP_BUILD_OPTIMIZE_RUNS=1 \
          dapp --use solc:0.6.12 build
clean  :; dapp clean
test   :; ./test-dssspell.sh $(match)
deploy :; make && dapp create DssSpell
flatten :; hevm flatten --source-file "src/Kovan-DssSpell.sol" > out/flat.sol
