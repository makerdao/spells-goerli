all    :; DAPP_LIBRARIES=' lib/dss-exec-lib/src/DssExecLib.sol:DssExecLib:0x40E718b252c65a4abF2C9897d63b086eb0e139b1' \
          DAPP_BUILD_OPTIMIZE=1 DAPP_BUILD_OPTIMIZE_RUNS=1 \
          dapp --use solc:0.6.11 build
clean  :; dapp clean
test   :; ./test-dssspell.sh
deploy :; make && dapp create DssSpell
flatten :; hevm flatten --source-file "src/Kovan-DssSpell.sol" > out/flat.sol
