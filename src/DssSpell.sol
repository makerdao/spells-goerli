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

// Note: ignored on Goerli
// interface ProxyLike {
//     function exec(address target, bytes calldata args) external payable returns (bytes memory out);
// }

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Always keep office hours off on goerli
    function officeHours() public pure override returns (bool) {
        return false;
    }

    // ---------- Pass HVB Resolutions ----------
    // Forum: https://forum.makerdao.com/t/huntingdon-valley-bank-transaction-documents-on-permaweb/16264/19
    // Poll: https://vote.makerdao.com/polling/QmNgKzcG
    // Updated Standing Instructions to Escrow Agent - QmWVWXckY482WLTtCFv3x45DFioV1K8mfRM3FVrodqUDud
    // Approval of New Payment Instructions to Galaxy Digital Trading Cayman LLC - QmSbwqULr66CiCvNips93vwTrvoTe4i2rJVmho7QfmyqZG

    // Comma-separated list of DAO resolutions IPFS hashes.
    string public constant dao_resolutions = "QmWVWXckY482WLTtCFv3x45DFioV1K8mfRM3FVrodqUDud,QmSbwqULr66CiCvNips93vwTrvoTe4i2rJVmho7QfmyqZG";

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

    // --- MATH ---
    uint256 internal constant MILLION = 10 ** 6;

    // ---------- Spark Proxy ----------
    // Note: ignored on Goerli
    // Spark Proxy: https://github.com/marsfoundation/sparklend/blob/d42587ba36523dcff24a4c827dc29ab71cd0808b/script/output/5/primary-sce-latest.json#L2
    // address internal constant SPARK_PROXY = 0x4e847915D8a9f2Ab0cDf2FC2FD0A30428F25665d;

    // ---------- Trigger Spark Proxy Spell ----------
    // address internal constant SPARK_SPELL = address(0);

    function actions() public override {
        // ---------- Trigger Spark Proxy Spell ----------
        // Note: ignored on Goerli
        // Forum: https://forum.makerdao.com/t/proposal-to-adjust-sparklend-parameters/22542
        // Poll: https://vote.makerdao.com/polling/QmaBLbxP
        // Poll: https://vote.makerdao.com/polling/QmZwRgr5
        // Poll: https://vote.makerdao.com/polling/QmQPrHsm
        // Poll: https://vote.makerdao.com/polling/QmRG9qUp
        // Poll: https://vote.makerdao.com/polling/QmQjKpbU
        // ProxyLike(SPARK_PROXY).exec(SPARK_SPELL, abi.encodeWithSignature("execute()"));


        // ----- Spark D3M DC Increase -----
        // Forum: https://forum.makerdao.com/t/proposal-to-adjust-sparklend-parameters/22542
        // Poll: https://vote.makerdao.com/polling/QmVbrypf#poll-detail

        // Increase the DIRECT-SPARK-DAI Maximum Debt Ceiling from 400 million DAI to 800 million DAI.
        // Keep gap and ttl at current settings (20 million and  hours respectively)
        DssExecLib.setIlkAutoLineDebtCeiling("DIRECT-SPARK-DAI", 800 * MILLION);


        // ---------- Launch Project Funds Transfer ----------
        // Forum: https://forum.makerdao.com/t/utilization-of-the-launch-project-under-the-accessibility-scope/21468/6

        // Launch Project - 2200000.00 DAI - 0x3C5142F28567E6a0F172fd0BaaF1f2847f49D02F
        // Launch Project - 500.00 MKR - 0x3C5142F28567E6a0F172fd0BaaF1f2847f49D02F
        // Note: ignored on Goerli


        // ---------- Whistleblower Bounty ----------
        // VeniceTree - 27.78 MKR - 0xCDDd2A697d472d1e8a0B1B188646c756d097b058
        // Forum: https://forum.makerdao.com/t/ads-derecognition-due-to-operational-security-breach/22532
        // MIP: https://mips.makerdao.com/mips/details/MIP101#2-6-6-aligned-delegate-operational-security
        // Note: ignored on Goerli
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
