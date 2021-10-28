// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2021 Dai Foundation
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

contract DssSpellAction is DssAction {

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/TODO -q -O - 2>/dev/null)"
    string public constant override description = "Goerli Spell";

    address constant JOIN_FAB = 0x0aaA1E0f026c194E0F951a7763F9edc796c6eDeE;
    address constant LERP_FAB = 0xE7988B75a19D8690272D65882Ab0D07D492f7002;

    function actions() public override {

        // Add Join factory to ChainLog
        DssExecLib.setChangelogAddress("JOIN_FAB", JOIN_FAB);

        // Update Lerp factory in ChainLog
        DssExecLib.setChangelogAddress("LERP_FAB", LERP_FAB);

        DssExecLib.setChangelogVersion("1.9.9");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
