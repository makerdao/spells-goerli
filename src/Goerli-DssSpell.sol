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

interface RwaUrnLike {
    function draw(uint256) external;
}

contract DssSpellAction is DssAction, DssSpellCollateralAction {

    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    uint256 constant internal MILLION  = 10 **  6;
    uint256 constant internal BILLION  = 10 **  9;
    uint256 constant internal WAD      = 10 ** 18;

    uint256 constant RWA009_DRAW_AMOUNT = 25_000_000 * WAD;
    address constant RWA009_A_URN = 0xd334bbA9172a6F615Be93d194d1322148fb5222e;


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
    uint256 constant ZERO_PCT_RATE             = 1000000000000000000000000000;
    uint256 constant ZERO_ZERO_TWO_PCT_RATE    = 1000000000006341324285480111;
    uint256 constant ZERO_ZERO_SIX_PCT_RATE    = 1000000000019020169709960675;
    uint256 constant TWO_TWO_FIVE_PCT_RATE     = 1000000000705562181084137268;
    uint256 constant THREE_SEVEN_FIVE_PCT_RATE = 1000000001167363430498603315;

    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {
        // ---------------------------------------------------------------------
        // Includes changes from the DssSpellCollateralAction
        // onboardNewCollaterals();

        // ----------------------------- RWA Draws -----------------------------
        // https://vote.makerdao.com/polling/QmQMDasC#poll-detail
        // Weekly Draw for HVB
        // Draw once to catch up to mainnet
        RwaUrnLike(RWA009_A_URN).draw(RWA009_DRAW_AMOUNT);
        // Draw again for Aug 10 Exec Draw
        RwaUrnLike(RWA009_A_URN).draw(RWA009_DRAW_AMOUNT);

        // --------------------------- Rates updates ---------------------------
        // https://vote.makerdao.com/polling/QmfMRfE4#poll-detail

        // Reduce Stability Fee for    ETH-B   from 4% to 3.75%
        DssExecLib.setIlkStabilityFee("ETH-B", THREE_SEVEN_FIVE_PCT_RATE, true);

        // Reduce Stability Fee for    WSTETH-A   from 2.50% to 2.25%
        DssExecLib.setIlkStabilityFee("WSTETH-A", TWO_TWO_FIVE_PCT_RATE, true);

        // Reduce Stability Fee for    WSTETH-B   from 0.75% to 0%
        DssExecLib.setIlkStabilityFee("WSTETH-B", ZERO_PCT_RATE, true);

        // Reduce Stability Fee for    WBTC-B   from 4.00% to 3.75%
        DssExecLib.setIlkStabilityFee("WBTC-B", THREE_SEVEN_FIVE_PCT_RATE, true);

        // Increase Stability Fee for  GUNIV3DAIUSDC1-A   from 0.01% to 0.02%
        DssExecLib.setIlkStabilityFee("GUNIV3DAIUSDC1-A", ZERO_ZERO_TWO_PCT_RATE, true);

        // Increase Stability Fee for  GUNIV3DAIUSDC2-A   from 0.05% to 0.06%
        DssExecLib.setIlkStabilityFee("GUNIV3DAIUSDC2-A", ZERO_ZERO_SIX_PCT_RATE, true);

        // Increase Stability Fee for  UNIV2DAIUSDC-A   from 0.01% to 0.02%
        DssExecLib.setIlkStabilityFee("UNIV2DAIUSDC-A", ZERO_ZERO_TWO_PCT_RATE, true);

        // ------------------------ Debt Ceiling updates -----------------------
        // https://vote.makerdao.com/polling/QmfMRfE4#poll-detail

        // Increase the line for              GUNIV3DAIUSDC2-A from   1 billion to 1.25 billion DAI
        DssExecLib.setIlkAutoLineDebtCeiling("GUNIV3DAIUSDC2-A",                   1250 * MILLION);
        // Increase the line for              GUINV3DAIUSDC1-A from 750 million to 1 billion DAI
        DssExecLib.setIlkAutoLineDebtCeiling("GUNIV3DAIUSDC1-A",                   1 * BILLION);
        // Increase the line for              MANA-A           from  15 million to 17 million DAI
        DssExecLib.setIlkAutoLineDebtCeiling("MANA-A",                             17 * MILLION);

    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
