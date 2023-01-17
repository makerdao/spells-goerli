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

interface VatLike {
    function Line() external view returns (uint256);
    function file(bytes32, uint256) external;
    function ilks(bytes32) external returns (uint256 Art, uint256 rate, uint256 spot, uint256 line, uint256 dust);
}

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

    address internal immutable MCD_PSM_GUSD_A = DssExecLib.getChangelogAddress("MCD_PSM_GUSD_A");

    function actions() public override {
        // PSM_GUSD_A changes
        // Poll: https://vote.makerdao.com/polling/QmZs1EMK#poll-detail
        // Forum: 

        uint256 lineReduction;
        VatLike vat = VatLike(DssExecLib.vat());

        // Reduce the PSM-GUSD-A line from 500 million DAI to 0 DAI
        // This requires removal from dss-autoline and a global line reduction
        (,,,lineReduction,) = vat.ilks("PSM-GUSD-A");
        DssExecLib.removeIlkFromAutoLine("PSM-GUSD-A");
        DssExecLib.setIlkDebtCeiling("PSM-GUSD-A", 0);
        vat.file("Line", vat.Line() - lineReduction);


        // PSM tout decrease
        // Reduce PSM-GUSD-A tout from 0.1% to 0%
        DssExecLib.setValue(MCD_PSM_GUSD_A, "tout", 0);
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
