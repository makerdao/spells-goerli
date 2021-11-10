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

contract DssSpellAction is DssAction {

    uint256 constant MILLION  = 10**6;

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/287beee2bb76636b8b9e02c7e698fa639cb6b859/governance/votes/Executive%20vote%20-%20October%2022%2C%202021.md -q -O - 2>/dev/null)"
    string public constant override description =
        "2021-11-xx MakerDAO Executive Spell | Hash: 0x0";
    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmefQMseb3AiTapiAKKexdKHig8wroKuZbmLtPLv4u2YwW
    //
    uint256 constant FIVE_PCT_RATE = 1000000001547125957863212448;

    address public constant WBTC_GEM               = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address public constant MCD_JOIN_WBTC_B        = 0x13B8EB3d2d40A00d65fD30abF247eb470dDF6C25;
    address public constant MCD_CLIP_WBTC_B        = 0x4F51B15f8B86822d2Eca8a74BB4bA1e3c64F733F;
    address public constant MCD_CLIP_CALC_WBTC_B   = 0x1b5a9aDaf15CAE0e3d0349be18b77180C1a0deCc;
    address public constant PIP_WBTC               = 0xf185d0682d50819263941e5f4EacC763CC5C6C42;

    function actions() public override {


        // GUNIV3DAIUSDC-A Parameter Adjustments
        // https://vote.makerdao.com/polling/QmemHGSM?network=mainnet
        // https://forum.makerdao.com/t/request-to-raise-the-guniv3daiusdc1-a-dc-to-500m/11394
        bytes32 GUNIV3DAIUSDC_ILK = "GUNIV3DAIUSDC1-A";
        setIlkAutoLineDebtCeiling(GUNIV3DAIUSDC_ILK, 500 * MILLION);    // Set DCIAM Max debt ceiling to 500 M
        setIlkLiquidationRatio(GUNIV3DAIUSDC_ILK, 102 * BPS_ONE_PCT);   // Set LR to 102 %
        setIlkStabilityFee(GUNIV3DAIUSDC_ILK, 0.5 * BPS_ONE_PCT);       // Set stability fee to 0.5 %
        
        // Add WBTC-B as a new Vault Type - November xx, 2021
        //  https://vote.makerdao.com/polling/QmSL1kDq?network=mainnet#poll-detail
        //  https://forum.makerdao.com/t/signal-request-new-iam-vault-type-for-wbtc-with-lower-lr/5736
        CollateralOpts memory WBTC_B = CollateralOpts({
            ilk:                   "WBTC-B",
            gem:                   WBTC_GEM,
            join:                  MCD_JOIN_WBTC_B,
            clip:                  MCD_CLIP_WBTC_B,
            calc:                  MCD_CLIP_CALC_WBTC_B,
            pip:                   PIP_WBTC,
            isLiquidatable:        true,
            isOSM:                 true,
            whitelistOSM:          true,
            ilkDebtCeiling:        500 * MILLION,
            minVaultAmount:        30000,
            maxLiquidationAmount:  25 * MILLION,
            liquidationPenalty:    1300,        // 13% penalty fee
            ilkStabilityFee:       FIVE_PCT_RATE,
            startingPriceFactor:   12000,       // Auction price begins at 130% of oracle
            breakerTolerance:      5000,        // Allows for a 50% hourly price drop before disabling liquidations
            auctionDuration:       90 minutes,
            permittedDrop:         4000,        // 40% price drop before reset
            liquidationRatio:      13000,       // 130% collateralization
            kprFlatReward:         300,         // 300 Dai
            kprPctReward:          10           // 0.1%
        });
        DssExecLib.addNewCollateral(WBTC_B);
        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_WBTC_B, 60 seconds, 9900);
        DssExecLib.setIlkAutoLineParameters("WBTC-B", 500 * MILLION, 30 * MILLION, 8 hours);

        DssExecLib.setChangelogAddress("MCD_JOIN_WBTC_B", MCD_JOIN_WBTC_B);
        DssExecLib.setChangelogAddress("MCD_CLIP_WBTC_B", MCD_CLIP_WBTC_B);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_WBTC_B", MCD_CLIP_CALC_WBTC_B);


        // bump changelog version
        DssExecLib.setChangelogVersion("1.9.10");
    }
}


contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
