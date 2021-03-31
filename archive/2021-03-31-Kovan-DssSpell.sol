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

import "dss-interfaces/dss/FaucetAbstract.sol";

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
    uint256 constant FOUR_PCT = 1000000001243680656318820312;

    uint256 constant WAD        = 10**18;
    uint256 constant RAD        = 10**45;
    uint256 constant MILLION    = 10**6;

    // PAXG-A
    address constant PAXG = 0x52403FCEfcf3A810e58868fF19c34725B426473A;
    address constant MCD_JOIN_PAXG_A = 0x822248F31bd899DE327A760a78B6C84889aF180D;
    address constant MCD_FLIP_PAXG_A = 0x0b2e32151041641Fa37a1F54D7eD526989eF9B73;
    address constant PIP_PAXG = 0x31CceDBc45179f17CfD34967680C6560b6509C1A;

    address constant PROXY_ACTIONS = 0xD8b9702755E91Aa792656966aE6bAF32F4C394Ba;

    function actions() public override {
        CollateralOpts memory PAXG_A = CollateralOpts({
            ilk: "PAXG-A",
            gem: PAXG,
            join: MCD_JOIN_PAXG_A,
            flip: MCD_FLIP_PAXG_A,
            pip: PIP_PAXG,
            isLiquidatable: true,
            isOSM: true,
            whitelistOSM: true,
            ilkDebtCeiling: 5 * MILLION,
            minVaultAmount: 100,
            maxLiquidationAmount: 500,
            liquidationPenalty: 1300,
            ilkStabilityFee: FOUR_PCT,
            bidIncrease: 300,
            bidDuration: 1 hours,
            auctionDuration: 1 hours,
            liquidationRatio: 12500
        });
        addNewCollateral(PAXG_A);

        DssExecLib.setChangelogAddress("PAXG", PAXG);
        DssExecLib.setChangelogAddress("MCD_JOIN_PAXG_A", MCD_JOIN_PAXG_A);
        DssExecLib.setChangelogAddress("MCD_FLIP_PAXG_A", MCD_FLIP_PAXG_A);
        DssExecLib.setChangelogAddress("PIP_PAXG", PIP_PAXG);

        DssExecLib.setChangelogAddress("PROXY_ACTIONS", PROXY_ACTIONS);

        // Turn on Faucet
        FaucetAbstract(DssExecLib.getChangelogAddress("FAUCET")).setAmt(PAXG, WAD);
    }

}

contract DssSpell is DssExec {
    DssSpellAction internal action_ = new DssSpellAction();
    constructor() DssExec(action_.description(), block.timestamp + 30 days, address(action_)) public {}
}
