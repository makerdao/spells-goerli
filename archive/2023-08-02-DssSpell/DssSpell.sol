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

interface RwaLiquidationOracleLike {
    function ilks(bytes32 ilk) external view returns (string memory doc, address pip, uint48 tau, uint48 toc);
    function init(bytes32 ilk, uint256 val, string memory doc, uint48 tau) external;
    function tell(bytes32 ilk) external;
}

interface ProxyLike {
    function exec(address target, bytes calldata args) external payable returns (bytes memory out);
}

interface ChainlogLike {
    function removeAddress(bytes32 _key) external;
}

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Always keep office hours off on goerli
    function officeHours() public pure override returns (bool) {
        return false;
    }

    // ----- JAT1 DAO Resolution -----
    // Forum: https://forum.makerdao.com/t/clydesdale-quarterly-return-of-surplus-fund/21291
    // Poll: N/A
    // Approve DAO Resolution hash QmaGTVioBsCPfNoz9rbW7LU6YuzfgqHDZd92Hny5ACfL3p

    // Comma-separated list of DAO resolutions IPFS hashes.
    string public constant dao_resolutions = "QmaGTVioBsCPfNoz9rbW7LU6YuzfgqHDZd92Hny5ACfL3p";

    address internal immutable MIP21_LIQUIDATION_ORACLE = DssExecLib.getChangelogAddress("MIP21_LIQUIDATION_ORACLE");

    // Spark
    address internal immutable SUBPROXY_SPARK = DssExecLib.getChangelogAddress("SUBPROXY_SPARK");
    // NOTE: goerli spell address is originated from https://github.com/marsfoundation/spark-spells/blob/d41d58ccc974f8358b0df962ad1fb931fedb7e62/src/proposals/20230802/SparkGoerli_20230802.t.sol#L80
    address internal constant SPARK_SPELL     = 0xEd3BF79737d3A469A29a7114cA1084e8340a2f20;

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
    uint256 internal constant EIGHT_PCT_RATE = 1000000002440418608258400030;

    // --- MATH ---
    uint256 internal constant MILLION = 10 ** 6;

    function _updateDoc(bytes32 ilk, string memory doc) internal {
        ( , address pip, uint48 tau, ) = RwaLiquidationOracleLike(MIP21_LIQUIDATION_ORACLE).ilks(ilk);
        require(pip != address(0), "DssSpell/unexisting-rwa-ilk");

        // Init the RwaLiquidationOracle to reset the doc
        RwaLiquidationOracleLike(MIP21_LIQUIDATION_ORACLE).init(
            ilk, // ilk to update
            0,   // price ignored if init() has already been called
            doc, // new legal document
            tau  // old tau value
        );
    }

    function actions() public override {
        // ----- Enhanced DSR Activation -----
        // Poll: https://vote.makerdao.com/polling/QmcTRPLx
        // Forum: https://forum.makerdao.com/t/request-for-gov12-1-2-edit-to-the-stability-scope-to-quickly-implement-enhanced-dsr/21405

        // Increase the DSR by 4.81% from 3.19% to 8%
        DssExecLib.setDSR(EIGHT_PCT_RATE, /* doDrip = */ true);

        // ----- Spark D3M DC Increase -----
        // Poll: https://vote.makerdao.com/polling/QmSLj3HS
        // Forum: https://forum.makerdao.com/t/phoenix-labs-proposed-changes-for-spark/21422

        // Increase the DIRECT-SPARK-DAI Maximum Debt Ceiling by 180 million DAI from 20 million DAI to 200 million DAI
        // Keep gap and ttl at current settings (20 million and 8 hours respectively)
        DssExecLib.setIlkAutoLineDebtCeiling("DIRECT-SPARK-DAI", 200 * MILLION);

        // ----- HTC-DROP (RWA004-A) Changes -----
        // Poll: https://vote.makerdao.com/polling/QmR8cYb1
        // Forum: https://forum.makerdao.com/t/request-to-poll-decrease-debt-ceiling-for-harbor-trade-credit-htc-drop-to-0/21373

        // Set DC to 0
        // Note: it was agreed with GovAlpha that there will be no global DC reduction this time.
        DssExecLib.setIlkDebtCeiling("RWA004-A", 0);
        // Call tell() on RWALiquidationOracle
        RwaLiquidationOracleLike(MIP21_LIQUIDATION_ORACLE).tell("RWA004-A");

        // ----- New Silver (RWA002-A) Doc Update -----
        // Poll: https://vote.makerdao.com/polling/QmaU1eaD
        // Forum: https://forum.makerdao.com/t/rwa-002-new-silver-restructuring-risk-and-legal-assessment/21417

        // Update doc to QmTrrwZpnSZ41rbrpx267R7vfDFktseQe2W5NJ5xB7kkn1
        _updateDoc("RWA002-A", "QmTrrwZpnSZ41rbrpx267R7vfDFktseQe2W5NJ5xB7kkn1");

        // ----- AVC Member Compensation -----
        // Forum: https://forum.makerdao.com/t/avc-member-participation-rewards-q2-2023/21459
        // NOTE: ignore on Goerli

        // IamMeeoh - 14.90 MKR - 0x47f7A5d8D27f259582097E1eE59a07a816982AE9
        // ACRE DAOs - 14.90 MKR - 0xBF9226345F601150F64Ea4fEaAE7E40530763cbd
        // Space Xponential - 11.92 MKR - 0xFF8eEB643C5bfDf6A925f2a5F9aDC9198AF07b78
        // Res - 14.90 MKR - 0x8c5c8d76372954922400e4654AF7694e158AB784
        // LDF - 11.92 MKR - 0xC322E8Ec33e9b0a34c7cD185C616087D9842ad50
        // opensky - 14.90 MKR - 0x8e67ee3bbeb1743dc63093af493f67c3c23c6f04
        // David Phelps - 8.94 MKR - 0xd56e3E325133EFEd6B1687C88571b8a91e517ab0
        // seedlatam.eth - 11.92 MKR - 0x0087a081a9b430fd8f688c6ac5dd24421bfb060d
        // StableLab - 14.9 MKR - 0xbDE65cf2352ed1Dde959f290E973d0fC5cEDFD08
        // flipsidegov - 14.9 MKR - 0x300901243d6CB2E74c10f8aB4cc89a39cC222a29

        // ----- Launch Project Funding -----
        // Forum: https://forum.makerdao.com/t/utilization-of-the-launch-project-under-the-accessibility-scope/21468
        // NOTE: ignore on Goerli

        // Launch Project - 2,000,000 DAI - 0x3C5142F28567E6a0F172fd0BaaF1f2847f49D02F

        // ----- Trigger Spark Proxy Spell -----
        // Poll: https://vote.makerdao.com/polling/QmZyFH21
        // Forum: https://forum.makerdao.com/t/phoenix-labs-proposed-changes-for-spark/21422

        // Trigger Spark Proxy Spell at 0xEd3BF79737d3A469A29a7114cA1084e8340a2f20 (goerli)
        ProxyLike(SUBPROXY_SPARK).exec(SPARK_SPELL, abi.encodeWithSignature("execute()"));

        // ----- Housekeeping -----

        // Remove SUBPROXY_SPARK from the chainlog on Goerli.
        // Github Discussion: https://github.com/makerdao/spells-mainnet/pull/346#issuecomment-1591198793
        // Since this was added by mistake, we should not bump the version in the Chainlog.
        ChainlogLike(DssExecLib.LOG).removeAddress("SUBPROXY_SPARK");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
