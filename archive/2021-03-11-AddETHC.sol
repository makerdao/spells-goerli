// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2021 Maker Ecosystem Growth Holdings, INC.
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
pragma solidity 0.6.11;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

contract DssSpellAction is DssAction {

    string public constant description = "Kovan Spell";

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.01)/(60 * 60 * 24 * 365) )'
    //
    uint256 constant THREE_PT_FIVE_PCT = 1000000001090862085746321732;

    uint256 constant WAD        = 10**18;
    uint256 constant RAD        = 10**45;
    uint256 constant MILLION    = 10**6;

    // ETH-C
    address constant MCD_JOIN_ETH_C = 0xD166b57355BaCE25e5dEa5995009E68584f60767;
    address constant MCD_FLIP_ETH_C = 0x6EB1922EbfC357bAe88B4aa5aB377A8C4DFfB4e9;

    function actions() public override {
        // Onboarding ETH-C
        CollateralOpts memory ETH_C = CollateralOpts({
            ilk: "ETH-C",
            gem: DssExecLib.getChangelogAddress("ETH"),
            join: MCD_JOIN_ETH_C,
            flip: MCD_FLIP_ETH_C,
            pip: DssExecLib.getChangelogAddress("PIP_ETH"),
            isLiquidatable: true,
            isOSM: true,
            whitelistOSM: false,
            ilkDebtCeiling: 100 * MILLION,
            minVaultAmount: 100,
            maxLiquidationAmount: 500,
            liquidationPenalty: 1300,
            ilkStabilityFee: THREE_PT_FIVE_PCT,
            bidIncrease: 300,
            bidDuration: 1 hours,
            auctionDuration: 1 hours,
            liquidationRatio: 17500
        });
        addNewCollateral(ETH_C);
        DssExecLib.setIlkAutoLineParameters("ETH-C", 2000 * MILLION, 100 * MILLION, 12 hours);

        DssExecLib.setChangelogAddress("MCD_JOIN_ETH_C", MCD_JOIN_ETH_C);
        DssExecLib.setChangelogAddress("MCD_FLIP_ETH_C", MCD_FLIP_ETH_C);

        // bump changelog version
        DssExecLib.setChangelogVersion("1.2.10");
    }

}

contract DssSpell is DssExec {
    DssSpellAction internal action_ = new DssSpellAction();
    constructor() DssExec(action_.description(), block.timestamp + 30 days, address(action_)) public {}
}
