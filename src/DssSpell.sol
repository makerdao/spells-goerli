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

    uint256 internal constant MILLION = 10**6;
    uint256 internal constant RAD     = 10**45;

    function actions() public override {

        uint256 Art;
        uint256 rate;
        uint256 line;
        uint256 maxLineReduction;
        uint256 totalDebt;
        VatLike vat = VatLike(DssExecLib.vat());

        // ---------------- RWA008-A Off-boarding Phase 0 ----------------
        // Forum: https://forum.makerdao.com/t/security-tokens-refinancing-mip6-application-for-ofh-tokens/10605/51

        // Set RWA008-A Debt Ceiling to 0:
        (Art, rate, , line, ) = vat.ilks("RWA008-A");
        maxLineReduction += line;
        totalDebt += Art * rate;
        DssExecLib.setIlkDebtCeiling("RWA008-A", 0);

        // -------- YFI-A, MATIC-A, LINK-A Off-boarding Phase 0 ----------
        // Forum: https://forum.makerdao.com/t/decentralized-collateral-scope-parameter-changes-1-april-2023/20302
        // Poll: https://vote.makerdao.com/polling/QmPwHhLT#poll-detail

        // Set YFI-A, MATIC-A, LINK-A Debt Ceiling to 0:
        (Art, rate, , line, ) = vat.ilks("LINK-A");
        maxLineReduction += line;
        totalDebt += Art * rate;
        DssExecLib.setIlkDebtCeiling("LINK-A", 0);

        (Art, rate, , line, ) = vat.ilks("YFI-A");
        maxLineReduction += line;
        totalDebt += Art * rate;
        DssExecLib.setIlkDebtCeiling("YFI-A", 0);

        (Art, rate, , line, ) = vat.ilks("MATIC-A");
        maxLineReduction += line;
        totalDebt += Art * rate;
        DssExecLib.setIlkDebtCeiling("MATIC-A", 0);

        // TODO: this would revert if `2 * totalDebt > maxLineReduction`
        DssExecLib.decreaseGlobalDebtCeiling((maxLineReduction - 2 * totalDebt) / RAD);

        // -------------------- Stability Fee Changes --------------------
        // Forum: https://forum.makerdao.com/t/decentralized-collateral-scope-parameter-changes-1-april-2023/20302

        // Increase WBTC-A Stability Fee from 1.75% to 4.90%:
        DssExecLib.setIlkStabilityFee("WBTC-A", FOUR_NINE_PCT_RATE, true);
        // Increase WBTC-B Stability Fee from 3.25% to 4.90%:
        DssExecLib.setIlkStabilityFee("WBTC-B", FOUR_NINE_PCT_RATE, true);
        // Increase WBTC-C Stability Fee from 1.00% to 4.90%:
        DssExecLib.setIlkStabilityFee("WBTC-C", FOUR_NINE_PCT_RATE, true);
        // Increase GNO-A Stability Fee from 2.50% to 4.90%:
        DssExecLib.setIlkStabilityFee("GNO-A",  FOUR_NINE_PCT_RATE, true);

    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
