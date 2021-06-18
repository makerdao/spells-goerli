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

import {Fileable, Authorizable} from "dss-exec-lib/DssExecLib.sol";
import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

contract DssSpellAction is DssAction {

    string public constant description = "Kovan Spell";

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    uint256 constant WAD = 10**18;
    uint256 constant RAY = 10**27;
    uint256 constant RAD = 10**45;

    address constant MCD_FLASH = 0x5aA1323f61D679E52a90120DFDA2ed1A76E4475A;

    function actions() public override {
        // ---------------------------- Add MCD_FLASH ----------------------------
        address MCD_VAT = DssExecLib.vat();
        Fileable(MCD_FLASH).file("max", 500_000_000 * WAD);
        Fileable(MCD_FLASH).file("toll", 5 * WAD / 10000);
        DssExecLib.authorize(MCD_VAT, MCD_FLASH);
        DssExecLib.setChangelogAddress("MCD_FLASH", MCD_FLASH);

        // ---------------------------- Update Chainlog version ----------------------------
        DssExecLib.setChangelogVersion("1.9.1");
    }
}

contract DssSpell is DssExec {
    DssSpellAction internal action_ = new DssSpellAction();
    constructor() DssExec(action_.description(), block.timestamp + 30 days, address(action_)) public {}
}
