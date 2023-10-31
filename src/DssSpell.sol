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

    // ---------- HV Bank (RWA009-A) - Approve DAO Resolution ----------
    // Forum: https://forum.makerdao.com/t/huntingdon-valley-bank-transaction-documents-on-permaweb/16264/17
    // Poll: https://vote.makerdao.com/executive/template-executive-vote-stability-scope-parameter-changes-spark-protocol-d3m-parameter-changes-set-fortunafi-debt-ceiling-to-zero-dai-dao-resolution-for-hv-bank-delegate-compensation-and-other-actions-september-13-2023
    // Approve DAO Resolution hash QmbrCPtpKsCaQ2pKc8qLnkL8TywRYcKHYaX6LEzhhKQqAw

    // Comma-separated list of DAO resolutions IPFS hashes.
    string public constant dao_resolutions = "QmbrCPtpKsCaQ2pKc8qLnkL8TywRYcKHYaX6LEzhhKQqAw";

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

    function actions() public override {

        // ---------- Spark - AAVE Revenue Share Payment ----------
        // Forum: https://forum.makerdao.com/t/spark-aave-revenue-share-calculation-payment-1-q3-2023/22486
        // MIP: https://mips.makerdao.com/mips/details/MIP106#9-4-1-spark-protocol-aave-revenue-share

        // Send 2889 DAI from Surplus Buffer to 0x464C71f6c2F760DdA6093dCB91C24c39e5d6e18c
        // Skip on goerli

        // ---------- Immunefi CU MKR Vesting Transfer ----------
        // Immunefi CU - 6.34 MKR - 0xd1F2eEf8576736C1EbA36920B957cd2aF07280F4
        // Forum: https://forum.makerdao.com/t/mip39c3-sp13-removing-is-001/22392
        // MIP: https://mips.makerdao.com/mips/details/MIP40c3SP41#sentence-summary
        // Skip on goerli

        // ---------- Housekeeping - GUSD & USDP - Add Jar & Conduit Contracts to Chainlog ----------
        // Forum: https://forum.makerdao.com/t/proposed-housekeeping-items-upcoming-executive-spell-2023-11-01/22477

        // Add `RwaJar` at 0xf2E7a5B83525c3017383dEEd19Bb05Fe34a62C27 as MCD_PSM_GUSD_A_JAR
        // Skip on goerli

        // Add `RwaSwapInputOutputConduit2` at 0x6934218d8B3E9ffCABEE8cd80F4c1C4167Afa638 as MCD_PSM_GUSD_A_INPUT_CONDUIT_JAR
        // Skip on goerli

        // Add `RwaJar` at 0x8bF8b5C58bb57Ee9C97D0FEA773eeE042B10a787 as MCD_PSM_PAX_A_JAR
        // Skip on goerli

        // Add `RwaSwapInputConduit2` at 0xDa276Ab5F1505965e0B6cD1B6da2A18CcBB29515 as MCD_PSM_PAX_A_INPUT_CONDUIT_JAR
        // Skip on goerli

        // Call `<conduit>.rely(MCD_ESM)` to allow ESM module to `deny` the pause proxy in SwapInputConduit contracts
        // Skip on goerli

        // Bump chainlog version for consistency, as it will be modified on mainnet
        DssExecLib.setChangelogVersion("1.17.1");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
