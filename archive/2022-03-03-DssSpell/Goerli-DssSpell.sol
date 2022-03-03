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
import "dss-interfaces/dss/ChainlogAbstract.sol";

import { DssSpellCollateralOnboardingAction } from "./Goerli-DssSpellCollateralOnboarding.sol";

contract DssSpellAction is DssAction, DssSpellCollateralOnboardingAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    uint256 constant MILLION = 10**6;

    // Turn office hours off
    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {
        // Housekeeping: PE-872 2022-02-25 Executive Spell
        // Increase PSM-GUSD-A max debt ceiling from 10M to 60M
        DssExecLib.setIlkAutoLineDebtCeiling("PSM-GUSD-A", 60 * MILLION);
        // Update Chainlog
        ChainlogAbstract(DssExecLib.LOG).removeAddress("MCD_FLIP_ETH_A");
        ChainlogAbstract(DssExecLib.LOG).removeAddress("MCD_FLIP_BAT_A");
        ChainlogAbstract(DssExecLib.LOG).removeAddress("MCD_FLIP_USDC_A");

        // --- Open Market Committee Proposal ---
        // https://vote.makerdao.com/polling/QmPhbQ3B
        //
        // Increase WSTETH-A AutoLine (line) from 200 million DAI to 300 million DAI
        // Increase WSTETH-A Autoline (gap) from 20 million DAI to 30 million DAI.
        DssExecLib.setIlkAutoLineParameters("WSTETH-A", 300 * MILLION, 30 * MILLION, 6 hours);

        // Increase DIRECT-AAVEV2-DAI AutoLine (line) from 220 million DAI to 300 million DAI.
        // Increase DIRECT-AAVEV2-DAI AutoLine (gap) from 50 million DAI to 65 million DAI.
        // DssExecLib.setIlkAutoLineParameters("DIRECT-AAVEV2-DAI", 300 * MILLION, 65 * MILLION, 12 hours);

        // Decrease DIRECT-AAVEV2-DAI Target Borrow Rate (bar) from 3.5% to 2.85%.
        // DssExecLib.setD3MTargetInterestRate(DssExecLib.getChangelogAddress("MCD_JOIN_DIRECT_AAVEV2_DAI"), 285); // 2.85%
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
