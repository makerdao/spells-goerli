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

    uint256 constant ZERO_FIVE_PCT_RATE         = 1000000000158153903837946257;
    uint256 constant ONE_SEVENTY_FIVE_PCT_RATE  = 1000000000550121712943459312;
    uint256 constant THREE_TWENTY_FIVE_PCT_RATE = 1000000001014175731521720677;

    uint256 internal constant MILLION = 10 ** 6;
    // uint256 internal constant RAY     = 10 ** 27;
    // uint256 internal constant WAD     = 10 ** 18;

    function actions() public override {

        // ---- New Aave v2 D3M ----
        // https://vote.makerdao.com/polling/QmUMyywc#poll-detail
        // Note: only on mainnet

        // ---- MOMC Parameter Changes ----
        // https://vote.makerdao.com/polling/QmUMyywc#poll-detail

        // Stability Fee Changes

        //Increase WSTETH-B Stability Fee to 0.5%
        DssExecLib.setIlkStabilityFee("WSTETH-B", ZERO_FIVE_PCT_RATE, true);

        // Reduce RETH-A Stability Fee to 0.5%
        DssExecLib.setIlkStabilityFee("RETH-A", ZERO_FIVE_PCT_RATE, true);

        // Reduce WBTC-A Stability Fee to 1.75%
        DssExecLib.setIlkStabilityFee("WBTC-A", ONE_SEVENTY_FIVE_PCT_RATE, true);

        // Reduce WBTC-B Stability Fee to 3.25%
        DssExecLib.setIlkStabilityFee("WBTC-B", THREE_TWENTY_FIVE_PCT_RATE, true);

        // line changes

        // Increase CRVV1ETHSTETH-A line to 100 million DAI
        // Note: only on mainnet

        // Increase RETH-A line to 10 million DAI
        DssExecLib.setIlkAutoLineDebtCeiling("RETH-A", 10 * MILLION);

        // Increase MATIC-A line to 15 million DAI
        DssExecLib.setIlkAutoLineDebtCeiling("MATIC-A", 15 * MILLION);

        // Increase DIRECT-COMPV2-DAI line to 30 million DAI
        // Note: only on mainnet

        // ---- SF-001 Contributor Vesting ----
        // Note: only on mainnet

        // Bump changelog
        DssExecLib.setChangelogVersion("1.14.9");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
