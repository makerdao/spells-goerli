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
pragma experimental ABIEncoderV2;

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

    // --- Rates ---
    uint256 constant ZERO_FIVE_PCT_RATE      = 1000000000158153903837946257;
    uint256 constant TWO_FIVE_PCT_RATE       = 1000000000782997609082909351;
    uint256 constant THREE_PCT_RATE          = 1000000000937303470807876289;

    // Math
    uint256 constant MILLION = 10**6;

    function actions() public override {


        // ------- Changes corresponding to the 2022-01-21 mainnet spell -------
        // ---------------------------------------------------------------------

        // ---------------------------------------------------------------------
        // Includes changes from the DssSpellCollateralOnboardingAction
        // onboardNewCollaterals();


        // --------------------------- Rates updates ---------------------------
        // https://vote.makerdao.com/polling/QmVyyjPF?network=mainnet#poll-detail
        // Decrease the ETH-A Stability Fee from 2.75% to 2.5%
        DssExecLib.setIlkStabilityFee("ETH-A", TWO_FIVE_PCT_RATE, true);

        // Decrease the WSTETH-A Stability Fee from 4.0% to 3.0%
        DssExecLib.setIlkStabilityFee("WSTETH-A", THREE_PCT_RATE, true);

        // Decrease the GUNIV3DAIUSDC2-A Stability Fee from 1% to 0.5%
        DssExecLib.setIlkStabilityFee("GUNIV3DAIUSDC2-A", ZERO_FIVE_PCT_RATE, true);


        // ------------------------ Debt Ceiling updates -----------------------
        // https://vote.makerdao.com/polling/QmVyyjPF?network=mainnet#poll-detail
        // Decrease the LINK-A Maximum Debt Ceiling from 140 million DAI to 100 million DAI.
        DssExecLib.setIlkAutoLineDebtCeiling("LINK-A", 100 * MILLION);

        // Decrease the YFI-A Maximum Debt Ceiling (line) from 130 million DAI to 50 million DAI
        DssExecLib.setIlkAutoLineDebtCeiling("YFI-A", 50 * MILLION);

        // Decrease the UNI-A Maximum Debt Ceiling (line) from 50 million DAI to 25 million DAI
        DssExecLib.setIlkAutoLineDebtCeiling("UNI-A", 25 * MILLION);

        // Decrease the UNIV2UNIETH-A Maximum Debt Ceiling (line) from 20 million DAI to 5 million DAI
        DssExecLib.setIlkAutoLineDebtCeiling("UNIV2UNIETH-A", 5 * MILLION);

        // Decrease the GUSD-A Debt Ceiling from 5 million DAI to zero DAI
        DssExecLib.decreaseIlkDebtCeiling("GUSD-A", 5 * MILLION, true);

        // Increase the GUNIV3DAIUSDC2-A Maximum Debt Ceiling (line) from 10 million DAI to 500 million DAI
        DssExecLib.setIlkAutoLineDebtCeiling("GUNIV3DAIUSDC2-A", 500 * MILLION);


        // ------------------ Liquiduation Ratio updates -----------------------
        // https://vote.makerdao.com/polling/QmbFqWGK?network=mainnet#poll-detail
        // Decrease the GUNIV3DAIUSDC2-A Liquidation Ratio from 105% to 102%
        DssExecLib.setIlkLiquidationRatio("GUNIV3DAIUSDC2-A", 10200);

        // NOTE: none of the AAVE D3M changes will be applied in goerli
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
