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
import "dss-interfaces/dss/ClipAbstract.sol";
import "dss-interfaces/dss/IlkRegistryAbstract.sol";

interface Fileable {
    function file(bytes32,bytes32,address) external;
}

contract DssSpellAction is DssAction {

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/TODO -q -O - 2>/dev/null)"
    string public constant override description = "Goerli Spell";

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {
        // Use PIP_WBTC for PIP_RENBTC
        address PIP_RENBTC = DssExecLib.getChangelogAddress("PIP_WBTC");
        Fileable(DssExecLib.getChangelogAddress("MCD_SPOT")).file("RENBTC-A", "pip", PIP_RENBTC);
        IlkRegistryAbstract(DssExecLib.reg()).update("RENBTC-A");
        DssExecLib.setChangelogAddress("PIP_RENBTC", PIP_RENBTC);

        // Turn off liquidations of stables
        ClipAbstract(DssExecLib.getChangelogAddress("MCD_CLIP_USDC_A")).file("stopped", 3);
        ClipAbstract(DssExecLib.getChangelogAddress("MCD_CLIP_USDC_B")).file("stopped", 3);
        ClipAbstract(DssExecLib.getChangelogAddress("MCD_CLIP_TUSD_A")).file("stopped", 3);
        ClipAbstract(DssExecLib.getChangelogAddress("MCD_CLIP_USDT_A")).file("stopped", 3);
        ClipAbstract(DssExecLib.getChangelogAddress("MCD_CLIP_PAXUSD_A")).file("stopped", 3);
        ClipAbstract(DssExecLib.getChangelogAddress("MCD_CLIP_GUSD_A")).file("stopped", 3);

        address CLIPPER_MOM = DssExecLib.getChangelogAddress("CLIPPER_MOM");
        ClipAbstract(DssExecLib.getChangelogAddress("MCD_CLIP_USDC_A")).deny(CLIPPER_MOM);
        ClipAbstract(DssExecLib.getChangelogAddress("MCD_CLIP_USDC_B")).deny(CLIPPER_MOM);
        ClipAbstract(DssExecLib.getChangelogAddress("MCD_CLIP_TUSD_A")).deny(CLIPPER_MOM);
        ClipAbstract(DssExecLib.getChangelogAddress("MCD_CLIP_USDT_A")).deny(CLIPPER_MOM);
        ClipAbstract(DssExecLib.getChangelogAddress("MCD_CLIP_PAXUSD_A")).deny(CLIPPER_MOM);
        ClipAbstract(DssExecLib.getChangelogAddress("MCD_CLIP_GUSD_A")).deny(CLIPPER_MOM);

        // Fix DSR value
        DssExecLib.setDSR(1000000000003170820659990704, true);
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
