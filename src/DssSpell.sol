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

interface RwaLiquidationLike {
    function ilks(bytes32) external view returns (string memory doc, address pip, uint48 tau, uint48 toc);
    function init(bytes32 ilk, uint256 val, string memory doc, uint48 tau) external;
    function tell(bytes32 ilk) external;
}

interface ProxyLike {
    function exec(address target, bytes calldata args) external payable returns (bytes memory out);
}

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Always keep office hours off on goerli
    function officeHours() public pure override returns (bool) {
        return false;
    }

    // ----- JAT1 DAO Resolution -----
    // Poll: N/A
    // Forum: https://forum.makerdao.com/t/clydesdale-quarterly-return-of-surplus-fund/21291

    // Approve DAO Resolution hash QmaGTVioBsCPfNoz9rbW7LU6YuzfgqHDZd92Hny5ACfL3p
    string public constant JAT1_DAO_RESOLUTION = "QmaGTVioBsCPfNoz9rbW7LU6YuzfgqHDZd92Hny5ACfL3p";

    address internal immutable MIP21_LIQUIDATION_ORACLE = DssExecLib.getChangelogAddress("MIP21_LIQUIDATION_ORACLE");

    // Spark
    address internal immutable SUBPROXY_SPARK = DssExecLib.getChangelogAddress("SUBPROXY_SPARK");
    // NOTE: goerli spell address is originated from https://github.com/marsfoundation/spark-spells/TODO
    // address internal constant SPARK_SPELL                  = address(0); // TODO

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

    // Function from https://github.com/makerdao/spells-goerli/blob/7d783931a6799fe8278e416b5ac60d4bb9c20047/archive/2022-11-14-DssSpell/Goerli-DssSpell.sol#L59
    function _updateDoc(bytes32 ilk, string memory doc) internal {
        ( , address pip, uint48 tau, ) = RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).ilks(ilk);
        require(pip != address(0), "DssSpell/unexisting-rwa-ilk");

        // Init the RwaLiquidationOracle to reset the doc
        RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).init(
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
        RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).tell("RWA004-A");

        // ----- New Silver (RWA002-A) Doc Update -----
        // Poll: https://vote.makerdao.com/polling/QmaU1eaD
        // Forum: https://forum.makerdao.com/t/rwa-002-new-silver-restructuring-risk-and-legal-assessment/21417

        // Update doc to QmTrrwZpnSZ41rbrpx267R7vfDFktseQe2W5NJ5xB7kkn1
        _updateDoc("RWA002-A", "QmTrrwZpnSZ41rbrpx267R7vfDFktseQe2W5NJ5xB7kkn1");

        // ----- AVC Member Compensation -----
        // TODO

        // ----- Launch Project Funding -----
        // TODO

        // ----- Trigger Spark Proxy Spell -----
        // Poll: https://vote.makerdao.com/polling/QmZyFH21
        // Forum: https://forum.makerdao.com/t/phoenix-labs-proposed-changes-for-spark/21422

        // ProxyLike(SUBPROXY_SPARK).exec(SPARK_SPELL, abi.encodeWithSignature("execute()"));
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
