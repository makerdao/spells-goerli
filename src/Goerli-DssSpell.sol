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

pragma solidity 0.6.12;
// Enable ABIEncoderV2 when onboarding collateral through `DssExecLib.addNewCollateral()`
// pragma experimental ABIEncoderV2;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

import { DssSpellCollateralAction } from "./Goerli-DssSpellCollateral.sol";

interface RwaLiquidationLike {
    function ilks(bytes32) external returns (string memory, address, uint48, uint48);
    function init(bytes32, uint256, string calldata, uint48) external;
}

interface ChainlogLike {
    function removeAddress(bytes32) external;
}

contract DssSpellAction is DssAction, DssSpellCollateralAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Turn office hours off
    function officeHours() public override returns (bool) {
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

    // --- Math ---
    uint256 internal constant WAD = 10 ** 18;

    // Monetalis (RWA007-A) legal update doc
    string constant RWA007_DOC = "QmejL1CKKN5vCwp9QD1gebnnAM2MJSt9XbF64uy4ptkJtR";

    // SG Forge OFH (RWA008-A) legal update doc
    string constant RWA008_DOC = "QmZ4heYjptvj3ovafADJpXYMFXMyY3yQjkTXpvjFPnAKcy";

    // HVB (RWA009-A) legal update doc
    string constant RWA009_DOC = "QmeRrbDF8MVPQfNe83gWf2qV48jApVigm1WyjEtDXCZ5rT";

    function actions() public override {

        // Includes changes from the DssSpellCollateralAction
        collateralAction();

        // -------------------- Update RWA007 Legal Documents ---------------------
        // https://forum.makerdao.com/t/poll-inclusion-request-hvbank-legal-update/17547
        // https://vote.makerdao.com/polling/QmX81EhP#vote-breakdown
        //
        bytes32 RWA007_ILK = "RWA007-A";
        updateDoc(RWA007_ILK, RWA007_DOC);


        // -------------------- Update RWA008 Legal Documents ---------------------
        // https://forum.makerdao.com/t/poll-inclusion-request-hvbank-legal-update/17547
        // https://vote.makerdao.com/polling/QmX81EhP#vote-breakdown
        //
        bytes32 RWA008_ILK = "RWA008-A";
        updateDoc(RWA008_ILK, RWA008_DOC);

        // -------------------- Update RWA009 Legal Documents ---------------------
        // https://forum.makerdao.com/t/poll-inclusion-request-hvbank-legal-update/17547
        // https://vote.makerdao.com/polling/QmX81EhP#vote-breakdown
        //
        bytes32 RWA009_ILK = "RWA009-A";
        updateDoc(RWA009_ILK, RWA009_DOC);

        // -------------------- Changelog Housekeeping ---------------------
        // - Change "RWA007_A_INPUT_CONDUIT_URN" to "RWA007_A_INPUT_CONDUIT"
        // - Change "RWA007_A_INPUT_CONDUIT_JAR" to "RWA007_A_JAR_INPUT_CONDUIT"
        //
        address rwa007inUrn = DssExecLib.getChangelogAddress("RWA007_A_INPUT_CONDUIT_URN");
        address rwa007inJar = DssExecLib.getChangelogAddress("RWA007_A_INPUT_CONDUIT_JAR");

        DssExecLib.setChangelogAddress("RWA007_A_INPUT_CONDUIT", rwa007inUrn);
        DssExecLib.setChangelogAddress("RWA007_A_JAR_INPUT_CONDUIT", rwa007inJar);
        ChainlogLike(DssExecLib.LOG).removeAddress("RWA007_A_INPUT_CONDUIT_URN");
        ChainlogLike(DssExecLib.LOG).removeAddress("RWA007_A_INPUT_CONDUIT_JAR");

        DssExecLib.setChangelogVersion("1.14.5");
    }

    function updateDoc(bytes32 ilk, string memory doc) private {
        address MIP21_LIQUIDATION_ORACLE = DssExecLib.getChangelogAddress(
            "MIP21_LIQUIDATION_ORACLE"
        );

        ( , address pip, uint48 tau, ) = RwaLiquidationLike(
            MIP21_LIQUIDATION_ORACLE
        ).ilks(ilk);

        require(pip != address(0), "Abort spell execution: pip must be set");

        // Init the RwaLiquidationOracle to reset the doc
        RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).init(
            ilk, // ilk to update
            0,          // price ignored if init() has already been called
            doc, // new legal document
            tau         // old tau value
        );
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
