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

    uint256 internal constant FOUR_NINE_PCT_RATE = 1000000001516911765932351183;

    uint256 internal constant RAD = 10 ** 45;

    VatLike internal immutable vat = VatLike(DssExecLib.vat());

    function actions() public override {

        uint256 lineReduction;
        uint256 line;

        // ---------- RWA008-A Offboarding ----------
        // Poll: N/A
        // Forum: https://forum.makerdao.com/t/security-tokens-refinancing-mip6-application-for-ofh-tokens/10605/51

        // Set RWA008-A Debt Ceiling to 0
        (,,,line,) = vat.ilks("RWA008-A");
        lineReduction += line;
        DssExecLib.setIlkDebtCeiling("RWA008-A", 0);

        // ---------- First Stage of Offboarding ----------
        // Poll: https://vote.makerdao.com/polling/QmPwHhLT
        // Forum: https://forum.makerdao.com/t/decentralized-collateral-scope-parameter-changes-1-april-2023/20302

        // Set YFI-A line to 0
        (,,,line,) = vat.ilks("YFI-A");
        lineReduction += line;
        DssExecLib.removeIlkFromAutoLine("YFI-A");
        DssExecLib.setIlkDebtCeiling("YFI-A", 0);

        // Set MATIC-A line to 0
        (,,,line,) = vat.ilks("MATIC-A");
        lineReduction += line;
        DssExecLib.removeIlkFromAutoLine("MATIC-A");
        DssExecLib.setIlkDebtCeiling("MATIC-A", 0);

        // Set LINK-A line to 0
        (,,,line,) = vat.ilks("LINK-A");
        lineReduction += line;
        DssExecLib.removeIlkFromAutoLine("LINK-A");
        DssExecLib.setIlkDebtCeiling("LINK-A", 0);

        // Decrease Global Debt Ceiling in accordance with Offboarded Ilks
        vat.file("Line", vat.Line() - lineReduction);

        // ---------- Stability Fee Changes ----------
        // Poll: N/A
        // Forum: https://forum.makerdao.com/t/decentralized-collateral-scope-parameter-changes-1-april-2023/20302

        // Increase the WBTC-A Stability Fee from 1.75% to 4.90%
        DssExecLib.setIlkStabilityFee("WBTC-A", FOUR_NINE_PCT_RATE, /* doDrip = */ true);

        // Increase the WBTC-B Stability Fee from 3.25% to 4.90%
        DssExecLib.setIlkStabilityFee("WBTC-B", FOUR_NINE_PCT_RATE, /* doDrip = */ true);

        // Increase the WBTC-C Stability Fee from 1.00% to 4.90%
        DssExecLib.setIlkStabilityFee("WBTC-C", FOUR_NINE_PCT_RATE, /* doDrip = */ true);

        // Increase the GNO-A Stability Fee from 2.50% to 4.90%
        DssExecLib.setIlkStabilityFee("GNO-A", FOUR_NINE_PCT_RATE, /* doDrip = */ true);

    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
