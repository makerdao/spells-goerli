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
// Enable ABIEncoderV2 when onboarding collateral
//pragma experimental ABIEncoderV2;
import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

import { DssSpellCollateralOnboardingAction } from "./Goerli-DssSpellCollateralOnboarding.sol";


contract DssSpellAction is DssAction, DssSpellCollateralOnboardingAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Math
    uint256 constant internal MILLION  = 10 ** 6;
    uint256 constant internal BILLION  = 10 ** 9;

    address constant internal MCD_CLIP_CALC_TUSD_A = 0xD4443E7CcB1Cf40DbE4E27C60Aef82054c7d27B3;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmefQMseb3AiTapiAKKexdKHig8wroKuZbmLtPLv4u2YwW
    //

    // --- Rates ---
    // uint256 constant FOUR_FIVE_PCT_RATE      = 1000000001395766281313196627;

    // Turn office hours off
    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {
        // ---------------------------------------------------------------------
        // Includes changes from the DssSpellCollateralOnboardingAction
        // onboardNewCollaterals();

        // ----------------- Offboard TUSD-A -----------------
        // https://vote.makerdao.com/polling/QmVkRdjg#poll-detail
        bytes32 _ilk  = bytes32("TUSD-A");
        address _clip = DssExecLib.getChangelogAddress("MCD_CLIP_TUSD_A");
        //
        // Enable liquidations for TUSD-A
        DssExecLib.authorize(_clip, DssExecLib.clipperMom());
        DssExecLib.setValue(_clip, "stopped", 0);
        // Use Abacus/LinearDecrease
        DssExecLib.setContract(_clip, "calc", MCD_CLIP_CALC_TUSD_A);
        // Set Liquidation Penalty to 0
        DssExecLib.setIlkLiquidationPenalty(_ilk, 0);
        // Set Liquidation Ratio to 150%
        DssExecLib.setIlkLiquidationRatio(_ilk, 15000);
        // Set Auction Price Multiplier (buf) to 1
        DssExecLib.setStartingPriceMultiplicativeFactor(_ilk, 10000);
        // Set Local Liquidation Limit (ilk.hole) to 5 million DAI
        DssExecLib.setIlkMaxLiquidationAmount(_ilk, 5 * MILLION);
        // Set tau for Abacus/LinearDecrease to 21,600,000 second (estimated 10bps drop per 6 hours = 250 days till 0)
        DssExecLib.setLinearDecrease(MCD_CLIP_CALC_TUSD_A, 21_600_000);
        // Set Max Auction Duration (tail) to 432,000 seconds (5 days, implies minimum price of 0.98)
        DssExecLib.setAuctionTimeBeforeReset(_ilk, 432_000);
        DssExecLib.setAuctionPermittedDrop(_ilk, 9800);
        // Set Proportional Kick Incentive (chip) to 0
        DssExecLib.setKeeperIncentivePercent(_ilk, 0);
        // Set Flat Kick Incentive (tip) to 500
        DssExecLib.setKeeperIncentiveFlatRate(_ilk, 500);

        // Update calc in changelog
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_TUSD_A", MCD_CLIP_CALC_TUSD_A);
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
