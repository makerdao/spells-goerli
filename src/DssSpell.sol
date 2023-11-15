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
        // ---------- Spark Proxy-Spell ----------
        // Forum: https://forum.makerdao.com/t/proposal-to-adjust-sparklend-parameters/22542
        // Poll: https://vote.makerdao.com/polling/QmaBLbxP
        // Poll: https://vote.makerdao.com/polling/QmZwRgr5
        // Poll: https://vote.makerdao.com/polling/QmQPrHsm
        // Poll: https://vote.makerdao.com/polling/QmRG9qUp
        // Poll: https://vote.makerdao.com/polling/QmQjKpbU
        // Note: ignored on Goerli

        // Gnosis Chain - Increase wstETH Supply Cap to 10,000 wstETH
        // Ethereum - Set DAI Market Maximum Loan-to-Value to Zero Percent
        // Ethereum - Reactivate WBTC and Optimize Parameters for Current Market Conditions
        // Ethereum - Increase rETH & wstETH Supply Caps
        // Ethereum & Gnosis Chain - Adjust ETH Market Interest Rate Models
        // ProxyLike(SPARK_PROXY).exec(SPARK_SPELL, abi.encodeWithSignature("execute()"));


        // ----- Adjust Spark Protocol D3M Maximum Debt Ceiling -----
        // Forum: https://forum.makerdao.com/t/proposal-to-adjust-sparklend-parameters/22542
        // Poll: https://vote.makerdao.com/polling/QmVbrypf#poll-detail

        // Increase the DIRECT-SPARK-DAI Maximum Debt Ceiling from 400 million DAI to 800 million DAI.
        // Keep gap and ttl at current settings (20 million and  hours respectively)
        DssExecLib.setIlkAutoLineDebtCeiling("DIRECT-SPARK-DAI", 800 * MILLION);


        // ---------- Launch Project Funds Transfer ----------
        // Forum: https://forum.makerdao.com/t/utilization-of-the-launch-project-under-the-accessibility-scope/21468/6
        // Note: ignored on Goerli

        // Launch Project - 2200000.00 DAI - 0x3C5142F28567E6a0F172fd0BaaF1f2847f49D02F
        // Launch Project - 500.00 MKR - 0x3C5142F28567E6a0F172fd0BaaF1f2847f49D02F


        // ---------- Whistleblower Bounty ----------
        // Forum: https://forum.makerdao.com/t/ads-derecognition-due-to-operational-security-breach/22532
        // MIP: https://mips.makerdao.com/mips/details/MIP101#2-6-6-aligned-delegate-operational-security
        // Note: ignored on Goerli

        // VeniceTree - 27.78 MKR - 0xCDDd2A697d472d1e8a0B1B188646c756d097b058


        // ---------- October Delegate Compensation  ----------
        // Forum: https://forum.makerdao.com/t/october-2023-aligned-delegate-compensation/22732
        // Note: ignored on Goerli

        // 0xDefensor - 41.67 MKR - 0x9542b441d65B6BF4dDdd3d4D2a66D8dCB9EE07a9
        // TRUE NAME - 41.67 MKR - 0x612F7924c367575a0Edf21333D96b15F1B345A5d
        // BONAPUBLICA - 41.67 MKR - 0x167c1a762B08D7e78dbF8f24e5C3f1Ab415021D3
        // Cloaky - 41.67 MKR - 0x869b6d5d8FA7f4FFdaCA4D23FFE0735c5eD1F818
        // Navigator - 40.33 MKR - 0x11406a9CC2e37425F15f920F494A51133ac93072
        // vigilant - 13.89 MKR - 0x2474937cB55500601BCCE9f4cb0A0A72Dc226F61
        // UPMaker - 13.89 MKR - 0xbB819DF169670DC71A16F58F55956FE642cc6BcD
        // PBG - 13.89 MKR - 0x8D4df847dB7FfE0B46AF084fE031F7691C6478c2
        // PALC - 13.44 MKR - 0x78Deac4F87BD8007b9cb56B8d53889ed5374e83A
        // BLUE - 12.97 MKR - 0xb6C09680D822F162449cdFB8248a7D3FC26Ec9Bf
        // JAG - 4.45 MKR - 0x58D1ec57E4294E4fe650D1CB12b96AE34349556f
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
