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
    // uint256 internal constant X_PCT_RATE      = ;
    uint256 internal constant FIVE_PT_TWO_FIVE_PCT_RATE    = 1000000001622535724756171269;
    uint256 internal constant FIVE_PT_SEVEN_FIVE_PCT_RATE  = 1000000001772819380639683201;
    uint256 internal constant FIVE_PCT_RATE                = 1000000001547125957863212448;
    uint256 internal constant FIVE_PT_EIGHT_THREE_PCT_RATE = 1000000001796798806711330296;
    uint256 internal constant SIX_PT_THREE_THREE_PCT_RATE  = 1000000001946260772914495212;
    uint256 internal constant FIVE_PT_FIVE_EIGHT_PCT_RATE  = 1000000001721802811203852608;

    //  ---------- Math ----------
    uint256 internal constant MILLION  = 10 ** 6;
    uint256 internal constant BILLION  = 10 ** 9;


    function actions() public override {
        // ---------- Non-Scope Defined Parameter Changes - WBTC DC-IAM Changes ----------
        // Forum: https://forum.makerdao.com/t/stability-scope-parameter-changes-6/22231
        // Poll: https://vote.makerdao.com/polling/QmNty2pa#poll-detail
        
        // Reduce the WBTC-A DC-IAM Target Available Debt from 10 million DAI to 2 million DAI.
        DssExecLib.setIlkAutoLineParameters("WBTC-A", 500 * MILLION, 2 * MILLION, 24 hours);

        // Reduce the WBTC-B DC-IAM Target Available Debt from 5 million DAI to 2 million DAI.
        DssExecLib.setIlkAutoLineParameters("WBTC-B", 250 * MILLION, 2 * MILLION, 24 hours);

        // Reduce the WBTC-C DC-IAM Target Available Debt from 10 million DAI to 2 million DAI.
        DssExecLib.setIlkAutoLineParameters("WBTC-C", 500 * MILLION, 2 * MILLION, 24 hours);


        // ---------- Stability Fee Changes ----------
        // Forum: https://forum.makerdao.com/t/stability-scope-parameter-changes-6/22231

        // Increase the ETH-A Stability Fee (SF) by 1.55%, from 3.70% to 5.25%.
        DssExecLib.setIlkStabilityFee("ETH-A", FIVE_PT_TWO_FIVE_PCT_RATE, /* doDrip = */ true);

        // Increase the ETH-B Stability Fee (SF) by 1.55%, from 4.20% to 5.75%.
        DssExecLib.setIlkStabilityFee("ETH-B", FIVE_PT_SEVEN_FIVE_PCT_RATE, /* doDrip = */ true);

        // Increase the ETH-C Stability Fee (SF) by 1.55%, from 3.45% to 5.00%.
        DssExecLib.setIlkStabilityFee("ETH-C", FIVE_PCT_RATE, /* doDrip = */ true);

        // Increase WBTC-A Stability Fee (SF) by 0.03%, from 5.8% to 5.83%
        DssExecLib.setIlkStabilityFee("WBTC-A", FIVE_PT_EIGHT_THREE_PCT_RATE, /* doDrip = */ true);

        // Increase WBTC-B Stability Fee (SF) by 0.03%, from 5.8% to 6.33%
        DssExecLib.setIlkStabilityFee("WBTC-B", SIX_PT_THREE_THREE_PCT_RATE, /* doDrip = */ true);

        // Increase WBTC-C Stability Fee (SF) by 0.03%, from 5.8% to 5.58%
        DssExecLib.setIlkStabilityFee("WBTC-C", FIVE_PT_FIVE_EIGHT_PCT_RATE, /* doDrip = */ true);


        // ---------- Initial RETH-A Offboarding  ----------
        // Forum: https://forum.makerdao.com/t/stability-scope-parameter-changes-6/22231
        
        // Set DC-IAM Line (max DC) to 0 (zero). 
        DssExecLib.setIlkAutoLineDebtCeiling("RETH-A", 0);


        // ---------- Reconfiguring Andromeda RWA015-A  ----------
        // Forum: https://forum.makerdao.com/t/poll-request-reconfiguring-rwa-allocator-vaults/22159
        // Poll: https://vote.makerdao.com/polling/QmPoLbah
        
        // Set the Maximum Debt Ceiling (line) to 3 billion DAI.
        DssExecLib.setIlkAutoLineDebtCeiling("RWA015-A", 3 * BILLION);


        // ---------- Reconfiguring Clydesdale RWA007-A  ----------
        // Forum: https://forum.makerdao.com/t/poll-request-reconfiguring-rwa-allocator-vaults/22159
        // Poll: https://vote.makerdao.com/polling/QmPoLbah
        
        // Reactivate the Debt Ceiling Instant Access Module for this vault type.
        // Set the Maximum Debt Ceiling (line) to 3 billion DAI.
        // Set the Target Available Debt (gap) to 50 million DAI.
        // Set the Ceiling Increase Cooldown (ttl) to 86400 (24 hours).
        DssExecLib.setIlkAutoLineParameters("RWA007-A", 3 * BILLION, 50 * MILLION, 24 hours);

        // ---------- Set up Governance Facilitator Streams  ----------
        // Forum: https://forum.makerdao.com/t/mip102c2-sp16-mip-amendment-subproposal/21579
        // Poll: https://vote.makerdao.com/polling/QmSovaxn
        // NOTE: Skip on goerli
        
        // JanSky | 2023-10-01 00:00:00 to 2024-09-30 23:59:59 | 504,000.00 DAI | 0xf3F868534FAD48EF5a228Fe78669cf242745a755
        // VoteWizard | 2023-10-01 00:00:00 to 2024-09-30 23:59:59 | 504,000.00 DAI | 0x9E72629dF4fcaA2c2F5813FbbDc55064345431b1
        // JanSky | 2023-10-01 00:00:00 to 2024-09-30 23:59:59 | 216.00 MKR | 0xf3F868534FAD48EF5a228Fe78669cf242745a755
        // VoteWizard | 2023-10-01 00:00:00 to 2024-09-30 23:59:59 | 216.00 MKR | 0x9E72629dF4fcaA2c2F5813FbbDc55064345431b1


        // ---------- BA Labs MKR Distribution  ----------
        // Forum: https://forum.makerdao.com/t/mip40c3-sp25-risk-core-unit-mkr-compensation-risk-001/9788
        // Poll: https://vote.makerdao.com/polling/QmUAXKm4
        // NOTE: Skip on goerli
        
        // BA Labs - 175 MKR - 0x5d67d5B1fC7EF4bfF31967bE2D2d7b9323c1521c
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}