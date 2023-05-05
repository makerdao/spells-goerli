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

interface StarknetLike {
    function setCeiling(uint256 _ceiling) external;
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

    uint256 internal constant ZERO_PT_SEVEN_FIVE_PCT_RATE    = 1000000000236936036262880196;
    uint256 internal constant ONE_PCT_RATE                   = 1000000000315522921573372069;
    uint256 internal constant ONE_PT_SEVEN_FIVE_PCT_RATE     = 1000000000550121712943459312;
    uint256 internal constant THREE_PT_TWO_FIVE_PCT_RATE     = 1000000001014175731521720677;

    uint256 internal constant WAD                            = 10 ** 18;
    uint256 internal constant MILLION                        = 10 ** 6;

    address internal immutable STARKNET_DAI_BRIDGE           = DssExecLib.getChangelogAddress("STARKNET_DAI_BRIDGE");

    function actions() public override {
        // ---------- Starknet ----------
        // Increase L1 Starknet Bridge Limit from 1,000,000 DAI to 5,000,000 DAI
        // Forum: https://forum.makerdao.com/t/april-26th-2023-spell-starknet-bridge-limit/20589
        StarknetLike(STARKNET_DAI_BRIDGE).setCeiling(5 * MILLION * WAD);

        // ---------- Risk Parameters Changes (Stability Fee & DC-IAM) ----------
        // Poll: https://vote.makerdao.com/polling/QmYFfRuR#poll-detail
        // Forum: https://forum.makerdao.com/t/out-of-scope-proposed-risk-parameters-changes-stability-fee-dc-iam/20564

        // Increase ETH-A Stability Fee by 0.25% from 1.5% to 1.75%.
        DssExecLib.setIlkStabilityFee("ETH-A", ONE_PT_SEVEN_FIVE_PCT_RATE, true);

        // Increase ETH-B Stability Fee by 0.25% from 3% to 3.25%.
        DssExecLib.setIlkStabilityFee("ETH-B", THREE_PT_TWO_FIVE_PCT_RATE, true);

        // Increase ETH-C Stability Fee by 0.25% from 0.75% to 1%.
        DssExecLib.setIlkStabilityFee("ETH-C", ONE_PCT_RATE, true);

        // Increase WSTETH-A Stability Fee by 0.25% from 1.5% to 1.75%.
        DssExecLib.setIlkStabilityFee("WSTETH-A", ONE_PT_SEVEN_FIVE_PCT_RATE, true);

        // Increase WSTETH-B Stability Fee by 0.25% from 0.75% to 1%.
        DssExecLib.setIlkStabilityFee("WSTETH-B", ONE_PCT_RATE, true);

        // Increase RETH-A Stability Fee by 0.25% from 0.5% to 0.75%.
        DssExecLib.setIlkStabilityFee("RETH-A", ZERO_PT_SEVEN_FIVE_PCT_RATE, true);

        // Increase CRVV1ETHSTETH-A Stability Fee by 0.25% from 1.5% to 1.75%.
        // NOTE: ignore in goerli
        // DssExecLib.setIlkStabilityFee("CRVV1ETHSTETH-A", ONE_SEVENTY_FIVE_PCT_RATE, true);


        // Increase the WSTETH-A gap by 15 million DAI from 15 million DAI to 30 million DAI.
        // Increase the WSTETH-A ttl by 21,600 seconds from 21,600 seconds to 43,200 seconds
        DssExecLib.setIlkAutoLineParameters("WSTETH-A", 500 * MILLION, 30 * MILLION, 12 hours);

        // Increase the WSTETH-B gap by 15 million DAI from 15 million DAI to 30 million DAI.
        // Increase the WSTETH-B ttl by 28,800 seconds from 28,800 seconds to 57,600 seconds.
        DssExecLib.setIlkAutoLineParameters("WSTETH-B", 500 * MILLION, 30 * MILLION, 16 hours);

        // Reduce the WBTC-A gap by 10 million DAI from 20 million DAI to 10 million DAI.
        DssExecLib.setIlkAutoLineParameters("WBTC-A", 500 * MILLION, 10 * MILLION, 24 hours);

        // Reduce the WBTC-B gap by 5 million DAI from 10 million DAI to 5 million DAI.
        DssExecLib.setIlkAutoLineParameters("WBTC-B", 250 * MILLION, 5 * MILLION, 24 hours);

        // Reduce the WBTC-C gap by 10 million DAI from 20 million DAI to 10 million DAI.
        DssExecLib.setIlkAutoLineParameters("WBTC-C", 500 * MILLION, 10 * MILLION, 24 hours);

        // Bump the chainlog
        DssExecLib.setChangelogVersion("1.14.12");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
