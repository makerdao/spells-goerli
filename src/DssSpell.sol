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

    // ---------- SBE parameter changes ----------
    address internal immutable MCD_FLAP = DssExecLib.flap();

    function actions() public override {
        // ---------- Delegate Compensation for February 2024 ----------
        // Note: skipped on goerli as spark spell is only deployed to mainnet

        // ---------- Smart Burn Engine `hop` Update ----------
        // Forum: https://forum.makerdao.com/t/smart-burn-engine-the-rate-of-mkr-accumulation-reconfiguration-and-transaction-analysis-parameter-reconfiguration-update-5/23737
        // Poll: https://vote.makerdao.com/polling/Qmat6oFs

        // Decrease the hop by 6,570 seconds from 26,280 seconds to 19,710 seconds.
        DssExecLib.setValue(MCD_FLAP, "hop", 19_710);

        // ---------- Launch Project Funding ----------
        // Forum: http://forum.makerdao.com/t/utilization-of-the-launch-project-under-the-accessibility-scope/21468/12
        // MIP: https://mips.makerdao.com/mips/details/MIP108#9-launch-project
        // Note: skipped on goerli as spark spell is only deployed to mainnet

        // Transfer 3,000,000 DAI to the Launch Project at 0x3C5142F28567E6a0F172fd0BaaF1f2847f49D02F
        // Transfer 500 MKR to the Launch Project at 0x3C5142F28567E6a0F172fd0BaaF1f2847f49D02F

        // ---------- Whistleblower Bounty Payment ----------
        // Forum: http://forum.makerdao.com/t/ad-derecognition-due-to-operational-security-breach-02-02-2024/23619/10
        // Note: skipped on goerli as spark spell is only deployed to mainnet

        // Transfer 20.835 MKR to whistelblower at 0xCDDd2A697d472d1e8a0B1B188646c756d097b058

        // ---------- Trigger Spark Proxy Spell ----------
        // Forum: TODO
        // Note: skipped on goerli as spark spell is only deployed to mainnet
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
