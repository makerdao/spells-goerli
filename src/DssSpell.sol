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

    function actions() public override {
        // --- BlockTower Vault Debt Ceiling Adjustments ---
        // Poll: https://vote.makerdao.com/polling/QmPMrvfV#poll-detail
        // Forum: https://forum.makerdao.com/t/blocktower-credit-rwa-vaults-parameters-shift/20707

        // --- MKR Vesting Transfers ---
        // Sidestream - 348.28 MKR - 0xb1f950a51516a697E103aaa69E152d839182f6Fe
        // Poll: N/A
        // MIP: https://mips.makerdao.com/mips/details/MIP40c3SP44#estimated-mkr-expenditure

        // Skip for goerli

        // DUX - 225.12 MKR - 0x5A994D8428CCEbCC153863CCdA9D2Be6352f89ad
        // Poll: N/A
        // MIP: https://mips.makerdao.com/mips/details/MIP40c3SP27

        // Skip for goerli

        // --- Stability Scope Defined Parameter Adjustments ---
        // Poll: https://vote.makerdao.com/polling/QmaoGpAQ#poll-detail
        // Forum: https://forum.makerdao.com/t/stability-scope-parameter-changes-2-non-scope-defined-parameter-changes-may-2023/20981#stability-scope-parameter-changes-proposal-6

        // --- Spark Protocol Parameter Changes ---
        // Poll: https://vote.makerdao.com/polling/QmWatYqy#poll-detail
        // Forum: https://forum.makerdao.com/t/2023-05-24-spark-protocol-updates/20958

        // --- Spark Protocol Proxy Changes ---
        // Poll: https://vote.makerdao.com/polling/Qmc9fd3j#poll-detail
        // Forum: https://forum.makerdao.com/t/2023-05-24-spark-protocol-updates/20958

        // --- Non-Scope Defined Parameter Adjustments ---
        // Poll: https://vote.makerdao.com/polling/QmQXhS3Z#poll-detail
        // Forum: https://forum.makerdao.com/t/stability-scope-parameter-changes-2-non-scope-defined-parameter-changes-may-2023/20981

        // --- RWA015 (BlockTower Andromeda) ---
        // Poll: https://vote.makerdao.com/polling/QmbudkVR#poll-detail
        // Forum links:
        //   - https://forum.makerdao.com/t/mip90-liquid-aaa-structured-credit-money-market-fund/18428
        //   - https://forum.makerdao.com/t/project-andromeda-risk-legal-assessment/20969
        //   - https://forum.makerdao.com/t/rwa015-project-andromeda-technical-assessment/20974

        // --- USDP PSM Debt Ceiling ---
        // Poll: https://vote.makerdao.com/polling/QmQYSLHH#poll-detail
        // Forum: https://forum.makerdao.com/t/reducing-psm-usdp-a-debt-ceiling/20980

    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
