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

    // Turn office hours off
    function officeHours() public override returns (bool) {
        return false;
    }

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmefQMseb3AiTapiAKKexdKHig8wroKuZbmLtPLv4u2YwW
    //
    uint256 constant ZERO_PCT_RATE                = 1000000000000000000000000000;
    uint256 constant ZERO_PT_TWO_FIVE_PCT_RATE    = 1000000000079175551708715274;
    uint256 constant ZERO_PT_SEVEN_FIVE_PCT_RATE  = 1000000000236936036262880196;
    uint256 constant ONE_PCT_RATE                 = 1000000000315522921573372069;
    uint256 constant ONE_PT_FIVE_PCT_RATE         = 1000000000472114805215157978;
    uint256 constant TWO_PCT_RATE                 = 1000000000627937192491029810;
    uint256 constant TWO_PT_TWO_FIVE_PCT_RATE     = 1000000000705562181084137268;
    uint256 constant TWO_PT_FIVE_PCT_RATE         = 1000000000782997609082909351;
    uint256 constant THREE_PT_FIVE_PCT_RATE       = 1000000001090862085746321732;
    uint256 constant THREE_PT_SEVEN_FIVE_PCT_RATE = 1000000001167363430498603315;
    uint256 constant FOUR_PCT_RATE                = 1000000001243680656318820312;
    uint256 constant FIVE_PCT_RATE                = 1000000001547125957863212448;


    // Math
    uint256 constant MILLION = 10**6;

    function actions() public override {

        // ---------------------------------------------------------------------
        // Includes changes from the DssSpellCollateralOnboardingAction
        // onboardNewCollaterals();

        // Update rates to mainnet
        // PPG - Open Market Committee Proposal - January 31, 2022
        //  https://vote.makerdao.com/polling/QmWReBMh?network=mainnet#poll-detail

        /// Stability Fee Decreases

        // Decrease the ETH-A Stability Fee from 2.5% to 2.25%.
        DssExecLib.setIlkStabilityFee("ETH-A", TWO_PT_TWO_FIVE_PCT_RATE, true);

        // Decrease the ETH-B Stability Fee from 6.5% to 4%.
        DssExecLib.setIlkStabilityFee("ETH-B", FOUR_PCT_RATE, true);

        // Decrease the WSTETH-A Stability Fee from 3% to 2.5%.
        DssExecLib.setIlkStabilityFee("WSTETH-A", TWO_PT_FIVE_PCT_RATE, true);

        // Decrease the WBTC-A Stability Fee from 4% to 3.75%.
        DssExecLib.setIlkStabilityFee("WBTC-A", THREE_PT_SEVEN_FIVE_PCT_RATE, true);

        // Decrease the WBTC-B Stability Fee from 7% to 5%.
        DssExecLib.setIlkStabilityFee("WBTC-B", FIVE_PCT_RATE, true);

        // Decrease the WBTC-C Stability Fee from 1.5% to 0.75%.
        DssExecLib.setIlkStabilityFee("WBTC-C", ZERO_PT_SEVEN_FIVE_PCT_RATE, true);

        // Decrease the UNIV2DAIETH-A Stability Fee from 2% to 1%.
        DssExecLib.setIlkStabilityFee("UNIV2DAIETH-A", ONE_PCT_RATE, true);

        // Decrease the UNIV2WBTCETH-A Stability Fee from 3% to 2%.
        DssExecLib.setIlkStabilityFee("UNIV2WBTCETH-A", TWO_PCT_RATE, true);

        // Decrease the UNIV2USDCETH-A Stability Fee from 2.5% to 1.5%.
        DssExecLib.setIlkStabilityFee("UNIV2USDCETH-A", ONE_PT_FIVE_PCT_RATE, true);

        // Decrease the GUNIV3DAIUSDC2-A Stability Fee from 0.5% to 0.25%.
        DssExecLib.setIlkStabilityFee("GUNIV3DAIUSDC2-A", ZERO_PT_TWO_FIVE_PCT_RATE, true);

        // Decrease the TUSD-A Stability Fee from 1% to 0%.
        DssExecLib.setIlkStabilityFee("TUSD-A", ZERO_PCT_RATE, true);


        /// DIRECT-AAVEV2-DAI (Aave D3M) Target Borrow Rate Decrease

        // Decrease the DIRECT-AAVEV2-DAI Target Borrow Rate from 3.75% to 3.5%.
        //   NOT AVAILABLE ON GOERLI

        /// Maximum Debt Ceiling Changes

        // Decrease the GUNIV3DAIUSDC1-A Maximum Debt Ceiling from 500 million DAI to 100 million DAI.
        DssExecLib.setIlkAutoLineDebtCeiling("GUNIV3DAIUSDC1-A", 100 * MILLION);

        // Increase the GUNIV3DAIUSDC2-A Maximum Debt Ceiling from 500 million DAI to 750 million DAI.
        // Increase the GUNIV3DAIUSDC2-A Target Available Debt (gap) from 10 million DAI to 50 million DAI.
        DssExecLib.setIlkAutoLineParameters("GUNIV3DAIUSDC2-A", 750 * MILLION, 50 * MILLION, 8 hours);

    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
