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
    function bump(bytes32 ilk, uint256 val) external;
}

interface RwaOutputConduitLike {
    function hope(address usr) external;
    function mate(address usr) external;
    function kiss(address who) external;
    function file(bytes32 what, address data) external;
}

interface RwaUrnLike {
    function file(bytes32 what, address data) external;
}

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    address internal immutable MIP21_LIQUIDATION_ORACLE = DssExecLib.getChangelogAddress("MIP21_LIQUIDATION_ORACLE");
    address internal immutable MCD_PSM_GUSD_A           = DssExecLib.getChangelogAddress("MCD_PSM_GUSD_A");
    address internal immutable RWA015_A_URN             = DssExecLib.getChangelogAddress("RWA015_A_URN");
    address internal immutable MCD_ESM                  = DssExecLib.esm();

    // Always keep office hours off on goerli
    function officeHours() public pure override returns (bool) {
        return false;
    }

    uint256 internal constant MILLION           = 10 ** 6;
    uint256 internal constant WAD               = 10 ** 18;

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

    // Operator address
    address internal constant RWA015_A_OPERATOR          = 0x23a10f09Fac6CCDbfb6d9f0215C795F9591D7476;
    // Custody address
    address internal constant RWA015_A_CUSTODY           = 0x65729807485F6f7695AF863d97D62140B7d69d83;

    address internal constant RWA015_A_OUTPUT_CONDUIT    = 0xe3B3EAB84039D486b06980aed70607d394DF3827;


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

        // --- Activate Andromeda Autoline ---
        // Forum: https://forum.makerdao.com/t/consolidated-action-items-for-2023-06-28-executive/21187
        // Forum: https://forum.makerdao.com/t/rwa015-project-andromeda-technical-assessment/20974

        // Activate autoline with line 1.28 billion DAI, gap 50 million DAI, ttl 86400
        DssExecLib.setIlkAutoLineParameters("RWA015-A", 1_280 * MILLION, 50 * MILLION, 24 hours);

        // Bump Oracle Price to 1.28 billion DAI
        // Debt ceiling * [ (1 + RWA stability fee ) ^ (minimum deal duration in years) ] * liquidation ratio
        // As we have SF 0 for this deal, this should be equeal to ilk DC
        RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).bump(
                "RWA015-A",
                 1_280 * MILLION * WAD
        );
        DssExecLib.updateCollateralPrice("RWA015-A");


        // --- Initialize New Andromeda OutputConduit ---
        // Poll: https://forum.makerdao.com/t/consolidated-action-items-for-2023-06-28-executive/21187

        // OPERATOR permission on RWA015_A_OUTPUT_CONDUIT
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT).hope(RWA015_A_OPERATOR);
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT).mate(RWA015_A_OPERATOR);
        // Custody whitelist for output conduit destination address
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT).kiss(address(RWA015_A_CUSTODY));
        // Set "quitTo" address for RWA015_A_OUTPUT_CONDUIT
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT).file("quitTo", RWA015_A_URN);
        // Route URN to new conduit
        RwaUrnLike(RWA015_A_URN).file("outputConduit", RWA015_A_OUTPUT_CONDUIT);

        // ----- Additional ESM authorization -----
        DssExecLib.authorize(RWA015_A_OUTPUT_CONDUIT, MCD_ESM);

        DssExecLib.setChangelogAddress("RWA015_A_OUTPUT_CONDUIT", RWA015_A_OUTPUT_CONDUIT);

        // --- RWA007 doc parameter update ---
        // Forum: https://forum.makerdao.com/t/consolidated-action-items-for-2023-06-28-executive/21187

        _updateDoc("RWA007-A", "QmY185L4tuxFkpSQ33cPHUHSNpwy8V6TMXbXvtVraxXtb5");

        // --- GUSD PSM Parameter Changes ---
        // Poll: https://vote.makerdao.com/polling/QmaXg3JT#vote-breakdown

        // Reduce the line by 390 million DAI from 500 million DAI to 110 million DAI.
        DssExecLib.setIlkAutoLineParameters("PSM-GUSD-A", 110 * MILLION, 50 * MILLION, 24 hours);
        // Reduce the tout by 0.01% from 0.01% to 0%.
        DssExecLib.setValue(MCD_PSM_GUSD_A, "tout", 0);

        // Skip for Goerli
        // --- Add Chainlink Keeper Network Treasury Address ---
        // Forum: https://forum.makerdao.com/t/poll-notice-keeper-network-follow-up-updates/21056
        // Forum: https://forum.makerdao.com/t/consolidated-action-items-for-2023-06-28-executive/21187
        // Poll: https://vote.makerdao.com/polling/QmZZJcCj#vote-breakdown

        // Skip for Goerli
        // --- CU MKR Vesting Transfers ---
        // Forum: https://mips.makerdao.com/mips/details/MIP40c3SP75#mkr-vesting
        // ORA-001 - 297.3 MKR - 0x2d09B7b95f3F312ba6dDfB77bA6971786c5b50Cf

        // Skip for Goerli
        // --- CU MKR Vesting Transfers ---
        // Forum: https://mips.makerdao.com/mips/details/MIP40c3SP25#mkr-vesting-schedule
        // RISK-001 - 175 MKR - 0x5d67d5B1fC7EF4bfF31967bE2D2d7b9323c1521c

        // Skip for Goerli
        // --- CU MKR Vesting Transfers ---
        // Forum: https://mips.makerdao.com/mips/details/MIP40c3SP17
        // SES-001 - 10.3 MKR - 0x87AcDD9208f73bFc9207e1f6F0fDE906bcA95cc6

        // Skip for Goerli
        // --- Delegate Compensation for May (including offboarded Delegates) ---
        // Forum: TBD

        // Skip for Goerli
        // --- BlockTower Legal Expenses DAI Transfer ---
        // Forum: https://forum.makerdao.com/t/project-andromeda-legal-expenses/20984
        // MIP: https://mips.makerdao.com/mips/details/MIP104#5-2-legal-recourse-asset-budget

        DssExecLib.setChangelogVersion("1.14.14");
    }
}


contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
