// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2021 Maker Ecosystem Growth Holdings, INC.
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

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";
import "dss-interfaces/dss/LPOsmAbstract.sol";

contract DssSpellAction is DssAction {

    string public constant description = "Kovan Spell";

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    // TODO: It's a temporary address for testing the spell, needs to be replaced
    // by the definitive one
    address constant PIP_UNIV2DAIETH = 0xED9201cd545F1d2457D2D48981E7832C754959e9;

    function replaceOracle(
        bytes32 ilk,
        bytes32 pipKey,
        address newOracle,
        address spotter,
        address end,
        address mom,
        bool orb0Med,
        bool orb1Med
    ) internal {
        address oldOracle = DssExecLib.getChangelogAddress(pipKey);
        address orb0 = LPOsmAbstract(newOracle).orb0();
        address orb1 = LPOsmAbstract(newOracle).orb1();
        require(LPOsmAbstract(newOracle).wat() == LPOsmAbstract(oldOracle).wat(), "DssSpell/not-matching-wat");
        require(LPOsmAbstract(newOracle).src() == LPOsmAbstract(oldOracle).src(), "DssSpell/not-matching-src");
        require(orb0 == LPOsmAbstract(oldOracle).orb0(), "DssSpell/not-matching-orb0");
        require(orb1 == LPOsmAbstract(oldOracle).orb1(), "DssSpell/not-matching-orb1");
        DssExecLib.setContract(spotter, ilk, "pip", newOracle);
        DssExecLib.authorize(newOracle, mom);
        DssExecLib.addReaderToOSMWhitelist(newOracle, spotter);
        DssExecLib.addReaderToOSMWhitelist(newOracle, end);
        if (orb0Med) {
            DssExecLib.addReaderToMedianWhitelist(orb0, newOracle);
            DssExecLib.removeReaderFromMedianWhitelist(orb0, oldOracle);
        }
        if (orb1Med) {
            DssExecLib.addReaderToMedianWhitelist(orb1, newOracle);
            DssExecLib.removeReaderFromMedianWhitelist(orb1, oldOracle);
        }
        DssExecLib.allowOSMFreeze(newOracle, ilk);
        DssExecLib.setChangelogAddress(pipKey, newOracle);
    }

    function actions() public override {
        address MCD_SPOT = DssExecLib.spotter();
        address MCD_END  = DssExecLib.end();
        address OSM_MOM  = DssExecLib.osmMom();

        // --------------------------------- UNIV2DAIETH-A ---------------------------------
        replaceOracle(
            "UNIV2DAIETH-A",
            "PIP_UNIV2DAIETH",
            PIP_UNIV2DAIETH,
            MCD_SPOT,
            MCD_END,
            OSM_MOM,
            false,
            true
        );

        // ---------------------------- Update Chainlog version ----------------------------
        DssExecLib.setChangelogVersion("1.7.0");
    }
}

contract DssSpell is DssExec {
    DssSpellAction internal action_ = new DssSpellAction();
    constructor() DssExec(action_.description(), block.timestamp + 30 days, address(action_)) public {}
}
