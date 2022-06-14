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
    uint256 constant MILLION  = 10 ** 6;
    uint256 constant THOUSAND = 10 ** 3;

    uint256 constant TWO_TWO_FIVE_PCT_RATE    = 1000000000705562181084137268;

    // --- DEPLOYED COLLATERAL ADDRESSES ---
    address constant RETH                     = 0x178E141a0E3b34152f73Ff610437A7bf9B83267A;
    // TODO: Update these once oracles and clip and calc fabs finalized
    // address constant PIP_RETH                 = 0x25b49A09f41725972249989Ebc7C78AA7A2d3426;
    address constant PIP_RETH                 = 0x7CA0b14534D3dA1D77dcbc083caA9980a157C2c5;
    address constant MCD_JOIN_RETH_A          = 0xBA59579287e146384C7dBcb29b7cfd8FDe86d0aD;
    address constant MCD_CLIP_RETH_A          = 0x35846FDa6Add5C34ECe9F7d13d3711865A39e155;
    address constant MCD_CLIP_CALC_RETH_A     = 0xC3A95477616c9Db6C772179e74a9A717E8B148a7;


    function onboardNewCollaterals() internal {
        // ----------------------------- Collateral onboarding -----------------------------
        //  Add RETH-A as a new Vault Type
        //  Poll Link: https://vote.makerdao.com/polling/QmfMswF2

        DssExecLib.addNewCollateral(
            CollateralOpts({
                ilk:                   "RETH-A",
                gem:                   RETH,
                join:                  MCD_JOIN_RETH_A,
                clip:                  MCD_CLIP_RETH_A,
                calc:                  MCD_CLIP_CALC_RETH_A,
                pip:                   PIP_RETH,
                isLiquidatable:        true,
                isOSM:                 true,
                whitelistOSM:          true,
                ilkDebtCeiling:        5 * MILLION,
                minVaultAmount:        15 * THOUSAND,                // debt floor - dust in DAI
                maxLiquidationAmount:  2 * MILLION,
                liquidationPenalty:    1300,                         // 13% penalty on liquidation
                ilkStabilityFee:       TWO_TWO_FIVE_PCT_RATE,        // 2.25% stability fee
                startingPriceFactor:   12000,                        // Auction price begins at 120% of oracle price
                breakerTolerance:      5000,                         // Allows for a 50% hourly price drop before disabling liquidation
                auctionDuration:       140 minutes,
                permittedDrop:         4000,                         // 40% price drop before reset
                liquidationRatio:      17000,                        // 170% collateralization
                kprFlatReward:         300,                          // 300 DAI tip - flat fee per kpr
                kprPctReward:          1000                          // 10% chip - per kpr
            })
        );

        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_RETH_A, 90 seconds, 9900);
        DssExecLib.setIlkAutoLineParameters("RETH-A", 5 * MILLION, 3 * MILLION, 8 hours);

        // ChainLog Updates
        // Add the new join, clip, and abacus to the Chainlog
        DssExecLib.setChangelogAddress("RETH",                 RETH);
        DssExecLib.setChangelogAddress("PIP_RETH",             PIP_RETH);
        DssExecLib.setChangelogAddress("MCD_JOIN_RETH_A",      MCD_JOIN_RETH_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_RETH_A",      MCD_CLIP_RETH_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_RETH_A", MCD_CLIP_CALC_RETH_A);

          // Rely Median to Oracles team

        // DssExecLib.authorize(OsmAbstract(PIP_RETH).src(),  0x1f42e41A34B71606FcC60b4e624243b365D99745);
    }
}
