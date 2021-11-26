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
import { VatAbstract, LerpFactoryAbstract, SpotAbstract} from "dss-interfaces/Interfaces.sol";

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/287beee2bb76636b8b9e02c7e698fa639cb6b859/governance/votes/Executive%20vote%20-%20October%2022%2C%202021.md -q -O - 2>/dev/null)"
    string public constant override description = "Goerli Spell";

    // Office Hours Off
    function officeHours() public override returns (bool) {
        return false;
    }

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmefQMseb3AiTapiAKKexdKHig8wroKuZbmLtPLv4u2YwW
    //

    // --- Rates ---
    uint256 constant ZERO_PCT_RATE           = 1000000000000000000000000000;
    uint256 constant ONE_FIVE_PCT_RATE       = 1000000000472114805215157978;

    // --- Math ---
    uint256 constant MILLION                 = 10 ** 6;
    uint256 constant RAD                     = 10 ** 45;

    // --- WBTC-C ---
    address constant MCD_JOIN_WBTC_C        = 0xe15E69F10E1A362F69d9672BFeA20B75CFf8574A;
    address constant MCD_CLIP_WBTC_C        = 0xDa3cd88f5FF7D2B9ED6Ab171C8218421916B6e10;
    address constant MCD_CLIP_CALC_WBTC_C   = 0xD26B140fdaA11c23b09230c24cBe71f456AC7ab6;

    // --- PSM-GUSD-A ---
    address constant MCD_JOIN_PSM_GUSD_A      = 0x4115fDa246e2583b91aD602213f2ac4fC6E437Ca; // AuthGemJoin8
    address constant MCD_CLIP_PSM_GUSD_A      = 0x7A58fF23D5437C99b44BB02D7e24213D6dA20DFa;
    address constant MCD_CLIP_CALC_PSM_GUSD_A = 0xE99bd8c56d7B9d90A36C8a563a4CA375b144dD94;
    address constant MCD_PSM_GUSD_A           = 0x3B2dBE6767fD8B4f8334cE3E8EC3E2DF8aB3957b;

    function _add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "DssSpellAction-add-overflow");
    }
    function _sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "DssSpellAction-sub-underflow");
    }

    function actions() public override {

        // --- 2021-11-26 Weekly Executive ---

        // ----------------------------- Debt ceiling updates -----------------------------
        // Increase the Aave D3M Maximum Debt Ceiling to 100 million
        // https://vote.makerdao.com/polling/QmZhvNu5?network=mainnet#poll-detail
        // https://forum.makerdao.com/t/proposal-to-increase-the-d3m-dc-from-50m-to-100m/11737

        //DssExecLib.setIlkAutoLineDebtCeiling("DIRECT-AAVEV2-DAI", 100 * MILLION); // Not supported on Goerli

        //  ----------------- Increase the Surplus Buffer via Lerp -----------------------
        //  https://vote.makerdao.com/polling/QmUqfZRv?network=mainnet#poll-detail
        DssExecLib.linearInterpolation({
            _name:      "Increase SB - 20211126",
            _target:    DssExecLib.vow(),
            _what:      "hump",
            _startTime: block.timestamp,
            _start:     60 * MILLION * RAD,
            _end:       90 * MILLION * RAD,
            _duration:  210 days
        });

        // ----------------------------- Collateral Onboarding ----------------------------
        //  Add WBTC-C as a new Vault Type
        //  https://vote.makerdao.com/polling/QmdVYMRo?network=mainnet#poll-detail (WBTC-C Onboarding)
        //  https://forum.makerdao.com/t/proposed-risk-parameters-for-wbtc-c-vault-type/11707
        //  https://forum.makerdao.com/t/signal-request-new-vault-type-for-wbtc-with-a-higher-lr/11579

        // WBTC
        address WBTC     = DssExecLib.getChangelogAddress("WBTC");
        address PIP_WBTC = DssExecLib.getChangelogAddress("PIP_WBTC");

        DssExecLib.addNewCollateral(
            CollateralOpts({
                ilk:                   "WBTC-C",
                gem:                   WBTC,
                join:                  MCD_JOIN_WBTC_C,
                clip:                  MCD_CLIP_WBTC_C,
                calc:                  MCD_CLIP_CALC_WBTC_C,
                pip:                   PIP_WBTC,
                isLiquidatable:        true,
                isOSM:                 true,
                whitelistOSM:          true,
                ilkDebtCeiling:        100 * MILLION,
                minVaultAmount:        7500,
                maxLiquidationAmount:  25 * MILLION,
                liquidationPenalty:    1300,                // 13% penalty fee
                ilkStabilityFee:       ONE_FIVE_PCT_RATE,   // 1.5% stability fee
                startingPriceFactor:   12000,               // Auction price begins at 120% of oracle
                breakerTolerance:      5000,                // Allows for a 50% hourly price drop before disabling liquidations
                auctionDuration:       90 minutes,
                permittedDrop:         4000,                // 40% price drop before reset
                liquidationRatio:      17500,               // 175% collateralization
                kprFlatReward:         300,                 // 300 Dai
                kprPctReward:          10                   // 0.1%
            })
        );
        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_WBTC_C, 90 seconds, 9900);
        DssExecLib.setIlkAutoLineParameters("WBTC-C", 1000 * MILLION, 100 * MILLION, 8 hours);

        DssExecLib.setChangelogAddress("MCD_JOIN_WBTC_C", MCD_JOIN_WBTC_C);
        DssExecLib.setChangelogAddress("MCD_CLIP_WBTC_C", MCD_CLIP_WBTC_C);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_WBTC_C", MCD_CLIP_CALC_WBTC_C);

        // Add a GUSD Peg Stability Module
        // https://vote.makerdao.com/polling/QmayeEjz?network=mainnet#poll-detail
        // https://forum.makerdao.com/t/proposal-gusd-psm/11148
        // https://forum.makerdao.com/t/psm-gusd-a-collateral-onboarding-risk-evaluation/11559

        // GUSD
        address GUSD     = DssExecLib.getChangelogAddress("GUSD");
        address PIP_GUSD = DssExecLib.getChangelogAddress("PIP_GUSD");

        //GUSD PSM
        DssExecLib.authorize(MCD_JOIN_PSM_GUSD_A, MCD_PSM_GUSD_A);

        DssExecLib.addNewCollateral(CollateralOpts({
            ilk:                   "PSM-GUSD-A",
            gem:                   GUSD,
            join:                  MCD_JOIN_PSM_GUSD_A,
            clip:                  MCD_CLIP_PSM_GUSD_A,
            calc:                  MCD_CLIP_CALC_PSM_GUSD_A,
            pip:                   PIP_GUSD,
            isLiquidatable:        false,
            isOSM:                 false,
            whitelistOSM:          false,
            ilkDebtCeiling:        10 * MILLION,
            minVaultAmount:        0,
            maxLiquidationAmount:  0,
            liquidationPenalty:    1300,
            ilkStabilityFee:       ZERO_PCT_RATE,
            startingPriceFactor:   10500,
            breakerTolerance:      9500, // Allows for a 5% hourly price drop before disabling liquidations
            auctionDuration:       220 minutes,
            permittedDrop:         9000,
            liquidationRatio:      10000,
            kprFlatReward:         300,
            kprPctReward:          10 // 0.1%
        }));
        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_PSM_GUSD_A, 120 seconds, 9990);
        DssExecLib.setIlkAutoLineParameters("PSM-GUSD-A", 10 * MILLION, 10 * MILLION, 24 hours);

        DssExecLib.setValue(MCD_PSM_GUSD_A, "tin", 0);
        DssExecLib.setValue(MCD_PSM_GUSD_A, "tout", 0);

        DssExecLib.setChangelogAddress("MCD_JOIN_PSM_GUSD_A", MCD_JOIN_PSM_GUSD_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_PSM_GUSD_A", MCD_CLIP_PSM_GUSD_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_PSM_GUSD_A", MCD_CLIP_CALC_PSM_GUSD_A);
        DssExecLib.setChangelogAddress("MCD_PSM_GUSD_A", MCD_PSM_GUSD_A);

        // Changelog version
        DssExecLib.setChangelogVersion("1.9.11");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
