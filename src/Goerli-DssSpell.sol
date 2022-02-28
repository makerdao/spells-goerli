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

    uint256 public constant MILLION = 10**6;

    address public constant MCD_CLIP_CALC_TUSD_A = 0xCE7174c95555fcAA300F8018dC925Ccac08f1633;

    // Turn office hours off
    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {
        // Housekeeping: PE-872 2022-02-25 Executive Spell
        // Increase PSM-GUSD-A max debt ceiling from 10M to 60M
        DssExecLib.setIlkAutoLineDebtCeiling("PSM-GUSD-A", 60 * MILLION);

        // TUSD-A turn liquidations on and finish offboarding
        address MCD_CLIP_TUSD_A = DssExecLib.getChangelogAddress("MCD_CLIP_TUSD_A");
        DssExecLib.setContract(MCD_CLIP_TUSD_A, "calc", MCD_CLIP_CALC_TUSD_A);
        DssExecLib.setValue(MCD_CLIP_TUSD_A, "stopped", 0);
        DssExecLib.authorize(MCD_CLIP_TUSD_A, DssExecLib.getChangelogAddress("CLIPPER_MOM"));
        DssExecLib.setIlkLiquidationPenalty("TUSD-A", 0);
        DssExecLib.setIlkLiquidationRatio("TUSD-A", 150_00);
        DssExecLib.setStartingPriceMultiplicativeFactor("TUSD-A", 100_00);
        DssExecLib.setAuctionTimeBeforeReset("TUSD-A", 25 days);
        DssExecLib.setIlkMaxLiquidationAmount("TUSD-A", 30 * MILLION);
        DssExecLib.setKeeperIncentivePercent("TUSD-A", 0);
        DssExecLib.setKeeperIncentiveFlatRate("TUSD-A", 500);
        DssExecLib.setValue(MCD_CLIP_CALC_TUSD_A, "tau", 5_000 days);

        // Update Chainlog
        ChainlogAbstract(DssExecLib.LOG).removeAddress("MCD_FLIP_ETH_A");
        ChainlogAbstract(DssExecLib.LOG).removeAddress("MCD_FLIP_BAT_A");
        ChainlogAbstract(DssExecLib.LOG).removeAddress("MCD_FLIP_USDC_A");
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_TUSD_A", MCD_CLIP_CALC_TUSD_A);
        DssExecLib.setChangelogVersion("1.10.1");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
