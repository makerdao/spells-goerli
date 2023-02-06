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

pragma solidity 0.8.16;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";


contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Turn office hours off
    function officeHours() public pure override returns (bool) {
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
    // uint256 internal constant X_PCT_RATE      = ;

    // uint256 internal constant MILLION = 10 ** 6;
    // uint256 internal constant RAY     = 10 ** 27;
    // uint256 internal constant WAD     = 10 ** 18;

    function actions() public override {

        // Dust Parameter Changes
        // https://vote.makerdao.com/polling/QmRfegL4#vote-breakdown

        // Reduce dust for ETH-A, WBTC-A, and WSTETH-A to 7,500 DAI.
        DssExecLib.setIlkMinVaultAmount("ETH-A", 7_500);
        DssExecLib.setIlkMinVaultAmount("WBTC-A", 7_500);
        DssExecLib.setIlkMinVaultAmount("WSTETH-A", 7_500);

        // Reduce dust for ETH-C, WBTC-C, and WSTETH-B to 3,500 DAI.
        DssExecLib.setIlkMinVaultAmount("ETH-C", 3_500);
        DssExecLib.setIlkMinVaultAmount("WBTC-C", 3_500);
        DssExecLib.setIlkMinVaultAmount("WSTETH-B", 3_500);

        // Reduce dust for ETH-B and WBTC-B to 25,000 DAI.
        DssExecLib.setIlkMinVaultAmount("ETH-B", 25_000);
        DssExecLib.setIlkMinVaultAmount("WBTC-B", 25_000);


        // Chainlink Automation Keeper Network Stream Setup
        // https://vote.makerdao.com/polling/QmXeWcrX
        // Not on Goerli

        // Recognized Delegate Compensation
        // https://mips.makerdao.com/mips/details/MIP61
        // Not on Goerli

        // Extra action to ensure prior call succeeds on Goerli cast
        DssExecLib.accumulateDSR();
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
