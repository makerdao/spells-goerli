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

    // --- Math ---
    uint256 constant MILLION = 10**6;
    uint256 constant ZERO_SEVEN_FIVE_PCT_RATE     = 1000000000236936036262880196;

    // --- DEPLOYED COLLATERAL ADDRESSES ---
    //address constant STETH                    = 0x1643E812aE58766192Cf7D2Cf9567dF2C37e9B7F;
    address constant WSTETH                   = 0x6320cD32aA674d2898A68ec82e869385Fc5f7E2f;
    address constant PIP_WSTETH               = 0x323eac5246d5BcB33d66e260E882fC9bF4B6bf41;
    address constant MCD_JOIN_WSTETH_B        = 0x4a2dfbdFb0ea68823265FaB4dE55E22f751eD12C;
    address constant MCD_CLIP_WSTETH_B        = 0x11D962d87EB3718C8012b0A71627d60c923d36a8;
    address constant MCD_CLIP_CALC_WSTETH_B   = 0xF4ffD00E0821C28aE673B4134D142FD8e479b061;

    function onboardNewCollaterals() internal {
        // ----------------------------- Collateral onboarding -----------------------------
        //  Add WSTETH-B as a new Vault Type
        //  Poll Link: TBD

        DssExecLib.addNewCollateral(CollateralOpts({
            ilk:                   "WSTETH-B",
            gem:                   WSTETH,
            join:                  MCD_JOIN_WSTETH_B,
            clip:                  MCD_CLIP_WSTETH_B,
            calc:                  MCD_CLIP_CALC_WSTETH_B,
            pip:                   PIP_WSTETH,
            isLiquidatable:        true,
            isOSM:                 true,
            whitelistOSM:          false,
            ilkDebtCeiling:        0,
            minVaultAmount:        5000,
            maxLiquidationAmount:  10 * MILLION,
            liquidationPenalty:    1300,        // 13% penalty fee
            ilkStabilityFee:       ZERO_SEVEN_FIVE_PCT_RATE, //0.75% stability fee
            startingPriceFactor:   12000,       // Auction price begins at 120% of oracle
            breakerTolerance:      5000,        // Allows for a 50% hourly price drop before disabling liquidations
            auctionDuration:       140 minutes, 
            permittedDrop:         4000,        // 40% price drop before reset
            liquidationRatio:      18500,       // 185% collateralization
            kprFlatReward:         300,         // 300 Dai
            kprPctReward:          10           // chip 0.1%
        }));

        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_WSTETH_B, 90 seconds, 9900);
        DssExecLib.setIlkAutoLineParameters("WSTETH-B", 150 * MILLION, 15 * MILLION, 8 hours);

        // ChainLog Updates
        // Add the new join, clip, and abacus to the Chainlog
        DssExecLib.setChangelogAddress("MCD_JOIN_WSTETH_B", MCD_JOIN_WSTETH_B);
        DssExecLib.setChangelogAddress("MCD_CLIP_WSTETH_B", MCD_CLIP_WSTETH_B);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_WSTETH_B", MCD_CLIP_CALC_WSTETH_B);
        DssExecLib.setChangelogVersion("1.11.2");
    }
}
