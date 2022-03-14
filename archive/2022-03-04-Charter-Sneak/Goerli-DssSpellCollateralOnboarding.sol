// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Copyright (C) 2021-2022 Dai Foundation
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

pragma solidity 0.6.12;

import "dss-exec-lib/DssExecLib.sol";

contract DssSpellCollateralOnboardingAction {

    // --- Rates ---
    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmTRiQ3GqjCiRhh1ojzKzgScmSsiwQPLyjhgYSxZASQekj
    //

    uint256 constant ONE_POINT_FIVE_PCT = 1000000000472114805215157978;

    // --- Math ---

    uint256 constant WAD = 10 ** 18;
    uint256 constant RAY = 10 ** 27;
    uint256 constant RAD = 10 ** 45;

    uint256 constant THOUSAND   = 10 ** 3;
    uint256 constant MILLION    = 10 ** 6;

    // --- DEPLOYED COLLATERAL ADDRESSES ---

    address constant MCD_CHARTER               = 0x7ea0d7ea31C544a472b55D19112e016Ba6708288;

    address constant MCD_JOIN_INST_ETH_A       = 0x99507A436aC9E8eB5A89001a2dFc80E343D82122;
    address constant MCD_CLIP_INST_ETH_A       = 0x6ECc35a9237a73022697976891Def7bAd87Be408;
    address constant MCD_CLIP_CALC_INST_ETH_A  = 0xea999A6381e78311Ff176751e00F46360F1562e9;

    address constant MCD_JOIN_INST_WBTC_A      = 0xbd5978308C9BbF6d8d1D26cD1df9AA3EA83F782a;
    address constant MCD_CLIP_INST_WBTC_A      = 0x81Bf27c821F24b6FC9Bcc0F7d4D7cc2651712E3c;
    address constant MCD_CLIP_CALC_INST_WBTC_A = 0x32ff6F008eB4aA5780efF2e0436b7adCDECb213a;

    function onboardNewCollaterals() internal {
        // ----------------------------- Collateral onboarding -----------------------------
        //  Add INST-ETH-A as a new Vault Type
        //  Poll Link: https://vote.makerdao.com/polling/QmU41X9v?network=mainnet#poll-detail

        // Note: All the values are for post migration stage (as in Goerli there is no mingration)
        DssExecLib.addNewCollateral(
         CollateralOpts({
             ilk:                   "INST-ETH-A",
             gem:                   DssExecLib.getChangelogAddress("ETH"),
             join:                  MCD_JOIN_INST_ETH_A,
             clip:                  MCD_CLIP_INST_ETH_A,
             calc:                  MCD_CLIP_CALC_INST_ETH_A,
             pip:                   DssExecLib.getChangelogAddress("PIP_ETH"),
             isLiquidatable:        true,
             isOSM:                 true,
             whitelistOSM:          false,
             ilkDebtCeiling:        50 * MILLION,
             minVaultAmount:        10 * THOUSAND,
             maxLiquidationAmount:  50 * MILLION,
             liquidationPenalty:    2000,
             ilkStabilityFee:       ONE_POINT_FIVE_PCT,
             startingPriceFactor:   12000,
             breakerTolerance:      5000,
             auctionDuration:       140 minutes,
             permittedDrop:         4000,
             liquidationRatio:      12000,
             kprFlatReward:         300,
             kprPctReward:          10
         })
        );

        DssExecLib.setStairstepExponentialDecrease(
            MCD_CLIP_CALC_INST_ETH_A,
            90 seconds,
            9900
        );

        DssExecLib.setIlkAutoLineParameters(
            "INST-ETH-A",
            900 * MILLION,
            50 * MILLION,
            8 hours
        );

        DssExecLib.authorize(MCD_JOIN_INST_ETH_A, MCD_CHARTER);

        // ----------------------------- Collateral onboarding -----------------------------
        //  Add INST-WBTC-A as a new Vault Type
        //  Poll Link: https://vote.makerdao.com/polling/QmU41X9v?network=mainnet#poll-detail

        DssExecLib.addNewCollateral(
         CollateralOpts({
            ilk:                   "INST-WBTC-A",
            gem:                   DssExecLib.getChangelogAddress("WBTC"),
            join:                  MCD_JOIN_INST_WBTC_A,
            clip:                  MCD_CLIP_INST_WBTC_A,
            calc:                  MCD_CLIP_CALC_INST_WBTC_A,
            pip:                   DssExecLib.getChangelogAddress("PIP_WBTC"),
            isLiquidatable:        true,
            isOSM:                 true,
            whitelistOSM:          false,
            ilkDebtCeiling:        50 * MILLION,
            minVaultAmount:        10 * THOUSAND,
            maxLiquidationAmount:  30 * MILLION,
            liquidationPenalty:    2000,
            ilkStabilityFee:       ONE_POINT_FIVE_PCT,
            startingPriceFactor:   12000,
            breakerTolerance:      5000,
            auctionDuration:       140 minutes,
            permittedDrop:         4000,
            liquidationRatio:      12000,
            kprFlatReward:         300,
            kprPctReward:          10
         })
        );

        DssExecLib.setStairstepExponentialDecrease(
            MCD_CLIP_CALC_INST_WBTC_A,
            90 seconds,
            9900
        );

        DssExecLib.setIlkAutoLineParameters(
            "INST-WBTC-A",
            600 * MILLION,
            50 * MILLION,
            8 hours
        );

        DssExecLib.authorize(MCD_JOIN_INST_WBTC_A, MCD_CHARTER);

        // Note - as this is a sneaky deployment we do not update the changelog

        // ChainLog Updates
        // Add the new flip and join to the Chainlog
        // address constant CHAINLOG        = DssExecLib.LOG();
        // ChainlogAbstract(CHAINLOG).setAddress("<join-name>", <join-address>);
        // ChainlogAbstract(CHAINLOG).setAddress("<clip-name>", <clip-address>);
        // ChainlogAbstract(CHAINLOG).setVersion("<new-version>");
    }
}
