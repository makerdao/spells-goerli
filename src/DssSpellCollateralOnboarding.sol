// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Copyright (C) 2021 Dai Foundation
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
    uint256 constant ONE_PCT_RATE = 1000000000315522921573372069;

    // --- Math ---
    uint256 constant MILLION = 10 ** 6;

    // --- DEPLOYED COLLATERAL ADDRESSES ---
    // --- GUNIV3DAIUSDC2-A ---
    address constant GUNIV3DAIUSDC2                 = 0x540BBCcb890cEb6c539fA94a0d63fF7a6aA25762;
    address constant MCD_JOIN_GUNIV3DAIUSDC2_A      = 0xbd039ea6d63AC57F2cD051202dC4fB6BA6681489;
    address constant MCD_CLIP_GUNIV3DAIUSDC2_A      = 0x39aee8F2D5ea5dffE4b84529f0349743C71C07c3;
    address constant MCD_CLIP_CALC_GUNIV3DAIUSDC2_A = 0xbF87fbA8ec2190E50Da297815A9A6Ae668306aFE;
    address constant PIP_GUNIV3DAIUSDC2             = 0x6Fb18806ff87B45220C2DB0941709142f2395069;

    function onboardNewCollaterals() internal {
        // ----------------------------- Collateral onboarding -----------------------------
        //  Add GUNIV3DAIUSDC2-A as a new Vault Type
        //  https://vote.makerdao.com/polling/QmSkHE8T?network=mainnet#poll-detail
        DssExecLib.addNewCollateral(
            CollateralOpts({
                ilk:                   "GUNIV3DAIUSDC2-A",
                gem:                   GUNIV3DAIUSDC2,
                join:                  MCD_JOIN_GUNIV3DAIUSDC2_A,
                clip:                  MCD_CLIP_GUNIV3DAIUSDC2_A,
                calc:                  MCD_CLIP_CALC_GUNIV3DAIUSDC2_A,
                pip:                   PIP_GUNIV3DAIUSDC2,
                isLiquidatable:        false,
                isOSM:                 true,
                whitelistOSM:          true,
                ilkDebtCeiling:        10 * MILLION,
                minVaultAmount:        15_000,
                maxLiquidationAmount:  5 * MILLION,
                liquidationPenalty:    1300,
                ilkStabilityFee:       ONE_PCT_RATE,
                startingPriceFactor:   10500,
                breakerTolerance:      9500,
                auctionDuration:       220 minutes,
                permittedDrop:         9000,
                liquidationRatio:      10500,
                kprFlatReward:         300,
                kprPctReward:          10
            })
        );

        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_GUNIV3DAIUSDC2_A, 120 seconds, 9990);
        DssExecLib.setIlkAutoLineParameters("GUNIV3DAIUSDC2-A", 10 * MILLION, 10 * MILLION, 8 hours);

        // ChainLog Updates
        // Add the new flip and join to the Chainlog
        // address constant CHAINLOG        = 0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F;
        // ChainlogAbstract(CHAINLOG).setAddress("<join-name>", <join-address>);
        // ChainlogAbstract(CHAINLOG).setAddress("<flip-name>", <flip-address>);
        // ChainlogAbstract(CHAINLOG).setVersion("<new-version>");
    }
}