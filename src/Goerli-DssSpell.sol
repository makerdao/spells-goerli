// SPDX-License-Identifier: AGPL-3.0-or-later
//
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
pragma experimental ABIEncoderV2;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/287beee2bb76636b8b9e02c7e698fa639cb6b859/governance/votes/Executive%20vote%20-%20October%2022%2C%202021.md -q -O - 2>/dev/null)"
    string public constant override description = "Goerli Spell";

    uint256 constant MILLION = 10**6;

    uint256 constant ZERO_FIVE_PCT_RATE     = 1000000000158153903837946257;
    uint256 constant FIVE_PCT_RATE          = 1000000001547125957863212448;

    function actions() public override {

        // GUNIV3DAIUSDC-A Parameter Adjustments
        // https://vote.makerdao.com/polling/QmemHGSM?network=mainnet
        // https://forum.makerdao.com/t/request-to-raise-the-guniv3daiusdc1-a-dc-to-500m/11394
        DssExecLib.setIlkAutoLineDebtCeiling("GUNIV3DAIUSDC1-A", 500 * MILLION);     // Set DCIAM Max debt ceiling to 500 M
        DssExecLib.setIlkLiquidationRatio("GUNIV3DAIUSDC1-A", 10200);                // Set LR to 102 %
        DssExecLib.setIlkStabilityFee("GUNIV3DAIUSDC1-A", ZERO_FIVE_PCT_RATE, true); // Set stability fee to 0.5 %

        // bump changelog version
        DssExecLib.setChangelogVersion("1.9.10");
    }
}


contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
