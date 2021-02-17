all    :; DAPP_LIBRARIES=' lib/dss-exec-lib/src/DssExecLib.sol:DssExecLib:0xd2406b8A710517fBe1A2218A72271D4Dc43A9D08' \
          DAPP_BUILD_OPTIMIZE=1 DAPP_BUILD_OPTIMIZE_RUNS=1 \
          dapp --use solc:0.6.11 build
clean  :; dapp clean
test   :; ./test-dssspell.sh
deploy :; make && dapp create DssSpell
