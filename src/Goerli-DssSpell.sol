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

    uint256 constant MILLION = 10 ** 6;
    uint256 constant WAD     = 10 ** 18;
    uint256 constant RAY     = 10 ** 27;

    address constant LERP_FAB = 0xbBD821c291c492c40Db2577D9b6E5B1bdAEBD207;

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {

        // Add LerpFactory to ChainLog
        DssExecLib.setChangelogAddress("LERP_FAB", LERP_FAB);

        // Offboard KNC Legacy Token
        // https://vote.makerdao.com/polling/QmQ4Jotm?network=mainnet#poll-detail
        DssExecLib.setIlkLiquidationPenalty("KNC-A", 0);
        DssExecLib.linearInterpolation({
            _name: "KNC Offboarding",
            _target: DssExecLib.spotter(),
            _ilk: "KNC-A",
            _what: "mat",
            _startTime: block.timestamp,
            _start: 175 * RAY / 100,
            _end: 5000 * RAY / 100,
            _duration: 60 days
        });

        // Adopt the Debt Ceiling Instant Access Module (DC-IAM) for PSM-PAX-A
    }

}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
