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

// Enable ABIEncoderV2 when managing collateral through `DssExecLib.addNewCollateral()`
// pragma experimental ABIEncoderV2;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";
import "dss-interfaces/dapp/DSTokenAbstract.sol";

import { DssSpellCollateralAction } from "./Goerli-DssSpellCollateral.sol";

interface RwaUrnLike {
    function hope(address) external;
    function lock(uint256) external;
    function draw(uint256) external;
}

contract DssSpellAction is DssAction, DssSpellCollateralAction {

    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    uint256 constant RWA009_DRAW_AMOUNT = 25 * MILLION * WAD;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmX2QMoM1SZq2XMoTbMak8pZP86Y2icpgPAKDjQg4r4YHn
    //

    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {
        // ---------------------------------------------------------------------
        // Includes changes from the DssSpellCollateralAction
        onboardNewCollaterals();
        drawFromRWA009Urn();

        DssExecLib.setChangelogVersion("1.13.3");
    }

    function drawFromRWA009Urn() internal {
        // DSS_PAUSE_PROXY permission on URN
        RwaUrnLike(RWA009_A_URN).hope(address(this));

        // lock RWA009 Token in the URN
        DSTokenAbstract(RWA009).approve(RWA009_A_URN, 1 * WAD);
        RwaUrnLike(RWA009_A_URN).lock(1 * WAD);

        // draw DAI to genesis address
        RwaUrnLike(RWA009_A_URN).draw(RWA009_DRAW_AMOUNT);

    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
