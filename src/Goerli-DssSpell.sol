// SPDX-FileCopyrightText: © 2020 Dai Foundation <www.daifoundation.org>
// SPDX-License-Identifier: AGPL-3.0-or-later
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
// Enable ABIEncoderV2 when onboarding collateral through `DssExecLib.addNewCollateral()`
pragma experimental ABIEncoderV2;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

import { DssSpellCollateralAction } from "./Goerli-DssSpellCollateral.sol";

contract DssSpellAction is DssAction, DssSpellCollateralAction {
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
    //    https://ipfs.io/ipfs/QmVp4mhhbwWGTfbh2BzwQB9eiBrQBKiqcPRZCaAxNUaar6
    //

    // --- Rates ---

    // --- Math ---
    // uint256 internal constant WAD = 10 ** 18;

    function actions() public override {
        // ---------------------------------------------------------------------
        // rETH Onboarding
        // https://vote.makerdao.com/polling/QmfMswF2#poll-detail 
        // https://vote.makerdao.com/polling/QmS7dBuQ#poll-detail 

        // Forum
        // https://forum.makerdao.com/t/reth-collateral-onboarding-risk-evaluation/15286

        // Liquidation Parameters
        // Limits
        // Incentives

        // ---------------------------------------------------------------------
        // Oracle Whitelisting
        // https://vote.makerdao.com/polling/QmZzFPFs#poll-detail
        // https://forum.makerdao.com/t/mip10c9-sp31-proposal-to-whitelist-oasis-app-on-rethusd-oracle/18195

        // ---------------------------------------------------------------------
        // Starknet Bridge Fee Upgrade
        // TBD

        // ---------------------------------------------------------------------
        // Includes changes from the DssSpellCollateralAction
        onboardCollaterals();
        // updateCollaterals();
        // offboardCollaterals();
        DssExecLib.setChangelogVersion("1.14.4");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
