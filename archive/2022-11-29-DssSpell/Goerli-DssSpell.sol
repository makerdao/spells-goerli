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
// pragma experimental ABIEncoderV2;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

interface StarknetGovRelayLike {
    function relay(uint256 spell) external;
}

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Turn office hours off
    function officeHours() public override returns (bool) {
        return false;
    }

    address immutable internal STARKNET_GOV_RELAY = DssExecLib.getChangelogAddress("STARKNET_GOV_RELAY_LEGACY");
    uint256 constant internal L2_GOV_RELAY_SPELL = 0x05a958b692c498791a215f0624a105393f5b33cfdc3fb51bdf17e629b766119a;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmVp4mhhbwWGTfbh2BzwQB9eiBrQBKiqcPRZCaAxNUaar6
    //

    function actions() public override {
        // ------------------ Setup new Starknet Governance Relay -----------------
        // Forum: https://forum.makerdao.com/t/starknet-changes-for-executive-spell-on-the-week-of-2022-11-29/18818
        // Relay l2 part of the spell
        // L2 Spell:
        // https://goerli.voyager.online/contract/0x05a958b692c498791a215f0624a105393f5b33cfdc3fb51bdf17e629b766119a#code
        // it is a fix of 2022-11-28 l2 spell:
        // https://goerli.voyager.online/contract/0x04c93f9818a4f81f6f2c6f0f660cb4986b789b6b6fb1b274b879649deed74eb8#code
        // that did not executed correctly due to the incorrect bridge_legacy address:
        // https://goerli.voyager.online/tx/0x6057a9ac5d03e09da99c9f07f725af5170eec6d4364f3a7f8dbc03362706698

        StarknetGovRelayLike(STARKNET_GOV_RELAY).relay(L2_GOV_RELAY_SPELL);
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
