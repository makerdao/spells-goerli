// SPDX-License-Identifier: AGPL-3.0-or-later
//
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
pragma experimental ABIEncoderV2;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";
import "dss-interfaces/dss/OsmAbstract.sol";

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/287beee2bb76636b8b9e02c7e698fa639cb6b859/governance/votes/Executive%20vote%20-%20October%2022%2C%202021.md -q -O - 2>/dev/null)"
    string public constant override description = "Goerli Spell";

    uint256 constant MILLION = 10**6;

    uint256 constant ZERO_FIVE_PCT_RATE     = 1000000000158153903837946257;
    uint256 constant FOUR_PCT_RATE          = 1000000001243680656318820312;

    address constant STETH                    = 0x1643E812aE58766192Cf7D2Cf9567dF2C37e9B7F;
    address constant WSTETH                   = 0x6320cD32aA674d2898A68ec82e869385Fc5f7E2f;
    address constant PIP_WSTETH               = 0x852779784DBB2Fa9A1e711c9776744d2E99c60B4;
    address constant MCD_JOIN_WSTETH_A        = 0xF99834937715255079849BE25ba31BF8b5D5B45D;
    address constant MCD_CLIP_WSTETH_A        = 0x3673978974fC3fB1bA61aea0a6eb1Bac8e27182c;
    address constant MCD_CLIP_CALC_WSTETH_A   = 0xb4f2f0eDFc10e9084a8bba23d84aF2c23B312852;

    function actions() public override {

        // GUNIV3DAIUSDC-A Parameter Adjustments
        // https://vote.makerdao.com/polling/QmemHGSM?network=mainnet
        // https://forum.makerdao.com/t/request-to-raise-the-guniv3daiusdc1-a-dc-to-500m/11394
        DssExecLib.setIlkAutoLineDebtCeiling("GUNIV3DAIUSDC1-A", 500 * MILLION);     // Set DCIAM Max debt ceiling to 500 M
        DssExecLib.setIlkLiquidationRatio("GUNIV3DAIUSDC1-A", 10200);                // Set LR to 102 %
        DssExecLib.setIlkStabilityFee("GUNIV3DAIUSDC1-A", ZERO_FIVE_PCT_RATE, true); // Set stability fee to 0.5 %

        // Add WSTETH-A as a new Vault Type (It should have come on version 1.9.8)
       DssExecLib.addNewCollateral(CollateralOpts({
            ilk:                   "WSTETH-A",
            gem:                   WSTETH,
            join:                  MCD_JOIN_WSTETH_A,
            clip:                  MCD_CLIP_WSTETH_A,
            calc:                  MCD_CLIP_CALC_WSTETH_A,
            pip:                   PIP_WSTETH,
            isLiquidatable:        true,
            isOSM:                 true,
            whitelistOSM:          true,
            ilkDebtCeiling:        3 * MILLION,
            minVaultAmount:        10000,
            maxLiquidationAmount:  3 * MILLION,
            liquidationPenalty:    1300,        // 13% penalty fee
            ilkStabilityFee:       FOUR_PCT_RATE,
            startingPriceFactor:   13000,       // Auction price begins at 130% of oracle
            breakerTolerance:      5000,        // Allows for a 50% hourly price drop before disabling liquidations
            auctionDuration:       140 minutes,
            permittedDrop:         4000,        // 40% price drop before reset
            liquidationRatio:      16000,       // 160% collateralization
            kprFlatReward:         300,         // 300 Dai
            kprPctReward:          10           // 0.1%
        }));
        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_WSTETH_A, 90 seconds, 9900);
        DssExecLib.setIlkAutoLineParameters("WSTETH-A", 50 * MILLION, 3 * MILLION, 8 hours);

        DssExecLib.setChangelogAddress("STETH", STETH);
        DssExecLib.setChangelogAddress("WSTETH", WSTETH);
        DssExecLib.setChangelogAddress("PIP_WSTETH", PIP_WSTETH);
        DssExecLib.setChangelogAddress("MCD_JOIN_WSTETH_A", MCD_JOIN_WSTETH_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_WSTETH_A", MCD_CLIP_WSTETH_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_WSTETH_A", MCD_CLIP_CALC_WSTETH_A);

        // Rely Median to Oracles team

        DssExecLib.authorize(OsmAbstract(PIP_WSTETH).src(),  0x1f42e41A34B71606FcC60b4e624243b365D99745);
    }
}


contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
