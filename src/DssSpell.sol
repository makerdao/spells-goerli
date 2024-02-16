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

pragma solidity 0.8.16;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Always keep office hours off on goerli
    function officeHours() public pure override returns (bool) {
        return false;
    }

    // ---------- Rates ----------
    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmVp4mhhbwWGTfbh2BzwQB9eiBrQBKiqcPRZCaAxNUaar6
    //
    // uint256 internal constant X_PCT_RATE = ;

    function actions() public override {
        // ----- Auction Parameter Updates -----
        // Forum: https://forum.makerdao.com/t/stability-scope-parameter-changes-9/23688

        // Decrease the ETH-A Stability Fee (SF) by 0.33 percentage points, from 6.74% to 6.41%.

        // Decrease the ETH-B Stability Fee (SF) by 0.33 percentage points, from 7.24% to 6.91%.

        // Decrease the ETH-C Stability Fee (SF) by 0.33 percentage points, from 6.49% to 6.16%.

        // Decrease the WSTETH-A Stability Fee (SF) by 0.51 percentage points, from 7.16% to 6.65%.

        // Decrease the WSTETH-B Stability Fee (SF) by 0.51 percentage points, from 6.91% to 6.40%.

        // Decrease the WBTC-A Stability Fee (SF) by 0.02 percentage points, from 6.70% to 6.68%.

        // Decrease the WBTC-B Stability Fee (SF) by 0.02 percentage points, from 7.20% to 7.18%.

        // Decrease the WBTC-C Stability Fee (SF) by 0.02 percentage points, from 6.45% to 6.43%.

        // ----- Spark Protocol DC-IAM Parameter Changes (main spell) -----
        // Forum: https://forum.makerdao.com/t/feb-9-2024-proposed-changes-to-sparklend-for-upcoming-spell/23656
        // Vote: https://vote.makerdao.com/polling/QmS8ch8r

        // Increase the DIRECT-SPARK-DAI Maximum Debt Ceiling (line) by 300 million DAI from 1.2 billion DAI to 1.5 billion DAI.

        // Increase the DIRECT-SPARK-DAI Target Available Debt (gap) by 20 million DAI from 20 million DAI to 40 million DAI.

        // Increase the DIRECT-SPARK-DAI Ceiling Increase Cooldown (ttl) by 12 hours from 12 hours to 24 hours.

        // Increase the DIRECT-SPARK-DAI buffer by 20 million DAI from 30 million DAI to 50 million DAI.

        // ----- Push USDP out of input conduit -----

        // Raise PSM-PAX-A DC to 1,000,000 DAI

        // Call push() on MCD_PSM_PAX_A_INPUT_CONDUIT_JAR (use push(uint256 amt)) to push 527,109.44 USDP

        // Call void() on MCD_PSM_PAX_A_JAR

        // Set PSM-PAX-A DC to 0 DAI

        // ----- yank vest streams -----

        // yank BA Labs DAI stream 20
        // Note: payments are skipped on goerli

        // yank BA Labs DAI stream 21
        // Note: payments are skipped on goerli

        // yank BA Labs MKR stream 35
        // Note: payments are skipped on goerli

        // ----- Trigger Spark Proxy Spell -----
        // Forum: https://forum.makerdao.com/t/feb-14-2024-proposed-changes-to-sparklend-for-upcoming-spell/23684

        // Activate Spark Proxy Spell - TBD
        // NOTE: skipped on goerli as spark spell is only deployed to mainnet
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
