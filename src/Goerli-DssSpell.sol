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

import { DssSpellCollateralAction } from "./Goerli-DssSpellCollateral.sol";

interface StarknetBridgeLike {

}

interface StarknetGovRelayLike {
    function relay(uint256 spell) external;
    function l2GovernanceRelay() external returns (uint256);
    function starkNet() external returns (address);
}

interface EscrowLike {
    function approve(address,address,uint256) external;
}

contract DssSpellAction is DssAction, DssSpellCollateralAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Turn office hours off
    function officeHours() public override returns (bool) {
        return false;
    }

    address internal immutable STARKNET_GOV_RELAY = DssExecLib.getChangelogAddress("STARKNET_GOV_RELAY");
    address internal immutable NEW_STARKNET_GOV_RELAY = 0x8919aefA417745F22c6af5AD6550E83159a373F3;
    uint256 internal immutable L2_GOV_RELAY_SPELL = 0x04c93f9818a4f81f6f2c6f0f660cb4986b789b6b6fb1b274b879649deed74eb8;

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

        // Includes changes from the DssSpellCollateralAction
        // collateralAction();

        // ------------------ Setup Starknet Teleport Fast Withdrawals -----------------
        // https://vote.makerdao.com/polling/QmZxRgvG
        // https://forum.makerdao.com/t/request-for-poll-starknet-bridge-deposit-limit-and-starknet-teleport-fees/17187


        // Relay l2 part of the spell
        StarknetGovRelayLike(STARKNET_GOV_RELAY).relay(L2_GOV_RELAY_SPELL);

        // Configure Chainlog
        DssExecLib.setChangelogAddress("STARKNET_GOV_RELAY_LEGACY", STARKNET_GOV_RELAY);
        DssExecLib.setChangelogAddress("STARKNET_GOV_RELAY", NEW_STARKNET_GOV_RELAY);

        DssExecLib.setChangelogVersion("1.14.6");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
