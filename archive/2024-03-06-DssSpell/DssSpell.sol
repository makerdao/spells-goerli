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

    //  ---------- Math ----------
    uint256 internal constant MILLION   = 10 ** 6;

    // ---------- SBE parameter changes ----------
    address internal immutable MCD_FLAP = DssExecLib.flap();

    function actions() public override {
        // ---------- Delegate Compensation for February 2024 ----------
        // Forum: https://forum.makerdao.com/t/february-2024-aligned-delegate-compensation/23766
        // Note: payments are skipped on goerli

        // BLUE - 41.67 MKR - 0xb6C09680D822F162449cdFB8248a7D3FC26Ec9Bf
        // BONAPUBLICA - 41.67 MKR - 0x167c1a762B08D7e78dbF8f24e5C3f1Ab415021D3
        // Cloaky - 41.67 MKR - 0x869b6d5d8FA7f4FFdaCA4D23FFE0735c5eD1F818
        // TRUE NAME - 41.67 MKR - 0x612F7924c367575a0Edf21333D96b15F1B345A5d
        // 0xDefensor - 23.71 MKR - 0x9542b441d65B6BF4dDdd3d4D2a66D8dCB9EE07a9
        // JAG - 13.89 MKR - 0x58D1ec57E4294E4fe650D1CB12b96AE34349556f
        // UPMaker - 13.89 MKR - 0xbB819DF169670DC71A16F58F55956FE642cc6BcD
        // vigilant - 13.89 MKR - 0x2474937cB55500601BCCE9f4cb0A0A72Dc226F61
        // PBG - 13.44 MKR - 0x8D4df847dB7FfE0B46AF084fE031F7691C6478c2
        // Pipkin - 5.82 MKR - 0x0E661eFE390aE39f90a58b04CF891044e56DEDB7
        // QGov - 4.48 MKR - 0xB0524D8707F76c681901b782372EbeD2d4bA28a6
        // WBC - 4.03 MKR - 0xeBcE83e491947aDB1396Ee7E55d3c81414fB0D47


        // ---------- Smart Burn Engine `hop` Update ----------
        // Forum: https://forum.makerdao.com/t/smart-burn-engine-the-rate-of-mkr-accumulation-reconfiguration-and-transaction-analysis-parameter-reconfiguration-update-5/23737
        // Poll: https://vote.makerdao.com/polling/Qmat6oFs

        // Decrease the hop by 6,570 seconds from 26,280 seconds to 19,710 seconds.
        DssExecLib.setValue(MCD_FLAP, "hop", 19_710);


        // ---------- Launch Project Funding ----------
        // Forum: https://forum.makerdao.com/t/utilization-of-the-launch-project-under-the-accessibility-scope/21468/12
        // MIP: https://mips.makerdao.com/mips/details/MIP108#9-launch-project
        // Note: payments are skipped on goerli

        // Transfer 3,000,000 DAI to the Launch Project at 0x3C5142F28567E6a0F172fd0BaaF1f2847f49D02F
        // Transfer 500 MKR to the Launch Project at 0x3C5142F28567E6a0F172fd0BaaF1f2847f49D02F


        // ---------- Whistleblower Bounty Payment ----------
        // Forum: https://forum.makerdao.com/t/ad-derecognition-due-to-operational-security-breach-02-02-2024/23619/10
        // Note: payments are skipped on goerli

        // Transfer 20.84 MKR to whistleblower at 0xCDDd2A697d472d1e8a0B1B188646c756d097b058


        // ---------- WBTC vault gap Changes ----------
        // Forum: https://forum.makerdao.com/t/stability-scope-parameter-changes-10-wbtc-a-c-dc-iam-gap/23765

        // Increase the WBTC-A gap by 2 million DAI from 2 million DAI to 4 million DAI
        DssExecLib.setIlkAutoLineParameters("WBTC-A", /* line = */ 500 * MILLION, /* gap = */ 4 * MILLION, /* ttl = */ 24 hours);

        // Increase the WBTC-C gap by 6 million DAI from 2 million DAI to 8 million DAI
        DssExecLib.setIlkAutoLineParameters("WBTC-C", /* line = */ 500 * MILLION, /* gap = */ 8 * MILLION, /* ttl = */ 24 hours);


        // ---------- Spark Proxy Spell ----------
        // Forum: https://forum.makerdao.com/t/feb-22-2024-proposed-changes-to-sparklend-for-upcoming-spell/23739
        // Poll: https://vote.makerdao.com/polling/QmUE5xr8
        // Poll: https://vote.makerdao.com/polling/QmRU6mmi
        // Note: skipped on goerli as spark spell is only deployed to mainnet
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
