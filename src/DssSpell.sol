// SPDX-FileCopyrightText: © 2020 Dai Foundation <www.daifoundation.org>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity 0.8.16;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

import { DssInstance, MCD } from "dss-test/MCD.sol";
import { D3MInit, D3MCommonConfig, D3MAavePoolConfig, D3MAaveBufferPlanConfig } from "src/dependencies/dss-direct-deposit/D3MInit.sol";
import { D3MCoreInstance } from "src/dependencies/dss-direct-deposit/D3MCoreInstance.sol";
import { D3MInstance } from "src/dependencies/dss-direct-deposit/D3MInstance.sol";

interface PoolConfiguratorLike {
    function setReserveFreeze(address asset, bool freeze) external;
    function setReserveInterestRateStrategyAddress(address asset, address newRateStrategyAddress) external;
    function setReserveFactor(address asset, uint256 newReserveFactor) external;
}

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Turn office hours off
    function officeHours() public pure override returns (bool) {
        return false;
    }

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmVp4mhhbwWGTfbh2BzwQB9eiBrQBKiqcPRZCaAxNUaar6
    //
    // uint256 internal constant X_PCT_RATE      = ;

    address internal constant D3M_HUB                   = 0x79Dcb858D6af6FeD7A5AC9B189ea14bC94076dfb;
    address internal constant D3M_MOM                   = 0x8aBafFe006205e306F4307EE7b839846CD1ff471;

    address internal constant SPARK_D3M_PLAN            = 0x1fB2cF94D896bB50A17dD1Abd901172F088dF309;
    address internal constant SPARK_D3M_POOL            = 0x8b6Ae79852bcae012CBc2244e4ef85c61BAeCE35;
    address internal constant SPARK_D3M_ORACLE          = 0xa07C4eDB18E4B3cfB9B94D9CD348BbF6d5a7f4c2;

    address internal constant SPARK_ADAI                = 0x4480b29AB7a1b0761e6d0d480325de28B7266d73;
    address internal constant SPARK_DAI_STABLE_DEBT     = 0xD72630D78157E1a2feD7A329873Bfd496704403D;
    address internal constant SPARK_DAI_VARIABLE_DEBT   = 0xa99d874d26BdfD94d474Aa04f4f7861DCD55Cbf4;
    address internal constant SPARK_POOL_CONFIGURATOR   = 0xe0C7ec61cC47e7c02b9B24F03f75C7BC406CCA98;

    address internal constant WBTC                      = 0x91277b74a9d1Cc30fA0ff4927C287fe55E307D78;  // Please note this is not the same WBTC as in Maker
    address internal constant INTEREST_RATE_STRATEGY    = 0x491acea4126E48e9A354b64869AE16b2f27BE333;

    uint256 constant MILLION = 10 ** 6;
    uint256 constant WAD = 10 ** 18;
    uint256 constant RAD = 10 ** 45;

    function actions() public override {

        // ---- Spark D3M ----
        // https://mips.makerdao.com/mips/details/MIP106
        // https://mips.makerdao.com/mips/details/MIP104
        // dss-direct-deposit @ 665afffea10c71561bd234a88caf6586bf46ada2

        DssInstance memory dss = MCD.loadFromChainlog(DssExecLib.LOG);
        D3MCoreInstance memory d3mCore = D3MCoreInstance({
            hub: D3M_HUB,
            mom: D3M_MOM
        });
        D3MInstance memory d3m = D3MInstance({
            plan:   SPARK_D3M_PLAN,
            pool:   SPARK_D3M_POOL,
            oracle: SPARK_D3M_ORACLE
        });
        D3MCommonConfig memory cfg = D3MCommonConfig({
            hub:         D3M_HUB,
            mom:         D3M_MOM,
            ilk:         "DIRECT-SPARK-DAI",
            existingIlk: false,
            maxLine:     5 * MILLION * RAD, // Set line to 5 million DAI
            gap:         5 * MILLION * RAD, // Set gap to 5 million DAI
            ttl:         8 hours,           // Set ttl to 8 hours
            tau:         7 days             // Set tau to 7 days
        });
        D3MAavePoolConfig memory poolCfg = D3MAavePoolConfig({
            king:         DssExecLib.getChangelogAddress("MCD_PAUSE_PROXY"),
            adai:         SPARK_ADAI,
            stableDebt:   SPARK_DAI_STABLE_DEBT,
            variableDebt: SPARK_DAI_VARIABLE_DEBT
        });
        D3MAaveBufferPlanConfig memory planCfg = D3MAaveBufferPlanConfig({
            buffer:       30 * MILLION * WAD,
            adai:         SPARK_ADAI
        });

        D3MInit.initCore({
            dss: dss,
            d3mCore: d3mCore
        });
        D3MInit.initCommon({
            dss:     dss,
            d3m:     d3m,
            cfg:     cfg
        });
        D3MInit.initAavePool({
            dss:     dss,
            d3m:     d3m,
            cfg:     cfg,
            aaveCfg: poolCfg
        });
        D3MInit.initAaveBufferPlan({
            d3m:     d3m,
            aaveCfg: planCfg
        });

        // ---- Spark Lend Parameter Adjustments ----
        PoolConfiguratorLike(SPARK_POOL_CONFIGURATOR).setReserveFreeze(WBTC, true);
        PoolConfiguratorLike(SPARK_POOL_CONFIGURATOR).setReserveInterestRateStrategyAddress(address(dss.dai), INTEREST_RATE_STRATEGY);
        PoolConfiguratorLike(SPARK_POOL_CONFIGURATOR).setReserveFactor(address(dss.dai), 0);

        // Bump the chainlog
        DssExecLib.setChangelogVersion("1.14.11");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
