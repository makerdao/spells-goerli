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

interface DssVestLike {
    function create(address, uint256, uint256, uint256, uint256, address) external returns (uint256);
    function restrict(uint256) external;
}

contract DssSpellAction is DssAction {

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/TODO -q -O - 2>/dev/null)"
    string public constant override description = "Goerli Spell";

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return true;
    }

    function actions() public override {
        address MCD_CLIP_USDT_A = DssExecLib.getChangelogAddress("MCD_CLIP_USDT_A");

        // Offboard USDT-A
        // https://vote.makerdao.com/polling/QmRNwrTy?network=mainnet#vote-breakdown

        // 1 thousand DAI maximum liquidation amount
        DssExecLib.setIlkMaxLiquidationAmount("USDT-A", 1_000);

        // flip breaker to enable liquidations
        DssExecLib.setValue(MCD_CLIP_USDT_A, "stopped", 0);

        // authorize breaker
        DssExecLib.authorize(MCD_CLIP_USDT_A, DssExecLib.clipperMom());

        // breaker at a 5% drop
        DssExecLib.setLiquidationBreakerPriceTolerance(MCD_CLIP_USDT_A, 9500);

        // set liquidation ratio to 300%
        DssExecLib.setIlkLiquidationRatio("USDT-A", 30000);

        // remove liquidation penalty
        DssExecLib.setIlkLiquidationPenalty("USDT-A", 0);
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
