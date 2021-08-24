all    :; DAPP_LIBRARIES=' lib/dss-exec-lib/src/DssExecLib.sol:DssExecLib:0x0aAcC3bd8852a51538C57918b9E94952A8acE5Da' \
          DAPP_BUILD_OPTIMIZE=1 DAPP_BUILD_OPTIMIZE_RUNS=1 \
          dapp --use solc:0.6.12 build
clean  :; dapp clean
test   :; ./test-dssspell.sh $(match)
deploy :; make && dapp create DssSpell | xargs ./verify.py DssSpell
flatten :; hevm flatten --source-file "src/Goerli-DssSpell.sol" > out/flat.sol
