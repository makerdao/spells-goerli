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
pragma experimental ABIEncoderV2;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

interface FaucetLike {
    function setAmt(address,uint256) external;
}

contract DssSpellAction is DssAction {

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/TODO -q -O - 2>/dev/null)"
    string public constant override description = "Goerli Spell";

    address constant PAX                     = 0x4547863912Fe2d17D3827704138957a8317E8dCD;
    address constant PIP_PAX                 = 0xdF8474337c9D3f66C0b71d31C7D3596E4F517457;
    address constant MCD_JOIN_PSM_PAX_A      = 0xF27E1F580D5e82510b47C7B2A588A8A533787d38;
    address constant MCD_CLIP_PSM_PAX_A      = 0xfe0b736a8bDc01869c94a0799CDD10683404D78f;
    address constant MCD_CLIP_CALC_PSM_PAX_A = 0x1e14F8ED0f1a6A908cACabb290Ef71a69cDe1abf;
    address constant MCD_PSM_PAX_A           = 0x934dAaa0778ee137993d2867340440d70a74A44e;

    address constant FLIP_FAB                = 0x333Ec4d92b546d6107Dc931156139A76dFAfD938;
    address constant CLIP_FAB                = 0xcfAab43101A01548A95F0f7dBB0CeF6f6490A389;
    address constant CALC_FAB                = 0x579f007Fb7151162e3095606232ef9029E090366;

    uint256 constant ZERO_PCT_RATE  = 1000000000000000000000000000;

    uint256 constant MILLION  = 10 ** 6;
    uint256 constant WAD      = 10 ** 18;

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {
        // PAX PSM
        DssExecLib.authorize(MCD_JOIN_PSM_PAX_A, MCD_PSM_PAX_A);

        DssExecLib.addNewCollateral(CollateralOpts({
            ilk:                   "PSM-PAX-A",
            gem:                   PAX,
            join:                  MCD_JOIN_PSM_PAX_A,
            clip:                  MCD_CLIP_PSM_PAX_A,
            calc:                  MCD_CLIP_CALC_PSM_PAX_A,
            pip:                   PIP_PAX,
            isLiquidatable:        false,
            isOSM:                 false,
            whitelistOSM:          false,
            ilkDebtCeiling:        50 * MILLION,
            minVaultAmount:        0,
            maxLiquidationAmount:  0,
            liquidationPenalty:    1300,
            ilkStabilityFee:       ZERO_PCT_RATE,
            startingPriceFactor:   10500,
            breakerTolerance:      9500, // Allows for a 5% hourly price drop before disabling liquidations
            auctionDuration:       220 minutes,
            permittedDrop:         9000,
            liquidationRatio:      10000,
            kprFlatReward:         300,
            kprPctReward:          10 // 0.1%
        }));
        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_PSM_PAX_A, 120 seconds, 9990);

        DssExecLib.setValue(MCD_PSM_PAX_A, "tin", 1 * WAD / 1000);
        DssExecLib.setValue(MCD_PSM_PAX_A, "tout", 0);

        DssExecLib.setChangelogAddress("PAX", PAX);
        DssExecLib.setChangelogAddress("PIP_PAX", PIP_PAX);
        DssExecLib.setChangelogAddress("MCD_JOIN_PSM_PAX_A", MCD_JOIN_PSM_PAX_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_PSM_PAX_A", MCD_CLIP_PSM_PAX_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_PSM_PAX_A", MCD_CLIP_CALC_PSM_PAX_A);
        DssExecLib.setChangelogAddress("MCD_PSM_PAX_A", MCD_PSM_PAX_A);

        // Set USDC tin value to 0.2%
        DssExecLib.setValue(DssExecLib.getChangelogAddress("MCD_PSM_USDC_A"), "tin", 2 * WAD / 1000);

        // Adding missing keys to the Chainlog
        DssExecLib.setChangelogAddress("FLIP_FAB", FLIP_FAB);
        DssExecLib.setChangelogAddress("CLIP_FAB", CLIP_FAB);
        DssExecLib.setChangelogAddress("CALC_FAB", CALC_FAB);
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
