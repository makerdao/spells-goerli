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

pragma solidity 0.6.12;
// Enable ABIEncoderV2 when onboarding collateral through `DssExecLib.addNewCollateral()`
// pragma experimental ABIEncoderV2;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";
// Enable ABIEncoderV2 when onboarding collateral through `DssExecLib.addNewCollateral()`
pragma experimental ABIEncoderV2;

interface StarknetGovRelayLike {
    function relay(uint256 spell) external;
}

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Turn office hours off
    function officeHours() public override returns (bool) {
        return false;
    }

    address constant internal MCD_CLIP_CALC_GUSD_A = 0x738EA932C2aFb1D8e47bebB7ed1c604399f2A99e;
    address constant internal MCD_CLIP_CALC_USDC_A = 0x3a278aA4264AD66c5DEaAfbC1fCf6E43ceD47325;
    address constant internal MCD_CLIP_CALC_PAXUSD_A = 0x8EE38002052CA938646F653831E9a6Af6Cc8BeBf;

    address immutable internal STARKNET_GOV_RELAY = DssExecLib.getChangelogAddress("STARKNET_GOV_RELAY");
    address constant internal NEW_STARKNET_GOV_RELAY = 0x8919aefA417745F22c6af5AD6550E83159a373F3;
    uint256 constant internal L2_GOV_RELAY_SPELL = 0x04c93f9818a4f81f6f2c6f0f660cb4986b789b6b6fb1b274b879649deed74eb8;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmVp4mhhbwWGTfbh2BzwQB9eiBrQBKiqcPRZCaAxNUaar6
    //
    uint256 internal constant TWO_FIVE_PCT_RATE   = 1000000000782997609082909351;

    // --- DEPLOYED COLLATERAL ADDRESSES ---
    address internal constant GNO                 = 0x86Bc432064d7F933184909975a384C7E4c9d0977;
    address internal constant PIP_GNO             = 0xf15221A159A4e7ba01E0d6e72111F0Ddff8Fa8Da;
    address internal constant MCD_JOIN_GNO_A      = 0x05a3b9D5F8098e558aF33c6b83557484f840055e;
    address internal constant MCD_CLIP_GNO_A      = 0x8274F3badD42C61B8bEa78Df941813D67d1942ED;
    address internal constant MCD_CLIP_CALC_GNO_A = 0x08Ae3e0C0CAc87E1B4187D53F0231C97B5b4Ab3E;

    function actions() public override {
        // ----------------- Activate Liquidations for GUSD-A, USDC-A and USDP-A -----------------
        // Poll: https://vote.makerdao.com/polling/QmZbsHqu#poll-detail
        // Forum: https://forum.makerdao.com/t/usdc-a-usdp-a-gusd-a-liquidation-parameters-auctions-activation/18744
        {
            bytes32 _ilk  = bytes32("GUSD-A");
            address _clip = DssExecLib.getChangelogAddress("MCD_CLIP_GUSD_A");
            //
            // Enable liquidations for GUSD-A
            // Note: ClipperMom cannot circuit-break on a DS-Value but we're adding
            //       the rely for consistency with other collaterals and in case the PIP
            //       changes to an OSM.
            DssExecLib.authorize(_clip, DssExecLib.clipperMom());
            DssExecLib.setValue(_clip, "stopped", 0);
            // Use Abacus/LinearDecrease
            DssExecLib.setContract(_clip, "calc", MCD_CLIP_CALC_GUSD_A);
            // Set Liquidation Penalty to 0
            DssExecLib.setIlkLiquidationPenalty(_ilk, 0);
            // Set Auction Price Multiplier (buf) to 1
            DssExecLib.setStartingPriceMultiplicativeFactor(_ilk, 100_00);
            // Set Local Liquidation Limit (ilk.hole) to 300k DAI
            DssExecLib.setIlkMaxLiquidationAmount(_ilk, 300_000);
            // Set tau for Abacus/LinearDecrease to 4,320,000 second
            DssExecLib.setLinearDecrease(MCD_CLIP_CALC_GUSD_A, 4_320_000);
            // Set Max Auction Duration (tail) to 43,200 seconds
            DssExecLib.setAuctionTimeBeforeReset(_ilk, 43_200);
            // Set Max Auction Drawdown / Permitted Drop (cusp) to 0.99
            DssExecLib.setAuctionPermittedDrop(_ilk, 99_00);
            // Set Proportional Kick Incentive (chip) to 0
            DssExecLib.setKeeperIncentivePercent(_ilk, 0);
            // Set Flat Kick Incentive (tip) to 0
            DssExecLib.setKeeperIncentiveFlatRate(_ilk, 0);
        }
        {
            bytes32 _ilk  = bytes32("USDC-A");
            address _clip = DssExecLib.getChangelogAddress("MCD_CLIP_USDC_A");
            //
            // Enable liquidations for USDC-A
            // Note: ClipperMom cannot circuit-break on a DS-Value but we're adding
            //       the rely for consistency with other collaterals and in case the PIP
            //       changes to an OSM.
            DssExecLib.authorize(_clip, DssExecLib.clipperMom());
            DssExecLib.setValue(_clip, "stopped", 0);
            // Use Abacus/LinearDecrease
            DssExecLib.setContract(_clip, "calc", MCD_CLIP_CALC_USDC_A);
            // Set Liquidation Penalty to 0
            DssExecLib.setIlkLiquidationPenalty(_ilk, 0);
            // Set Auction Price Multiplier (buf) to 1
            DssExecLib.setStartingPriceMultiplicativeFactor(_ilk, 100_00);
            // Set Local Liquidation Limit (ilk.hole) to 20m DAI
            DssExecLib.setIlkMaxLiquidationAmount(_ilk, 20_000_000);
            // Set tau for Abacus/LinearDecrease to 4,320,000 second
            DssExecLib.setLinearDecrease(MCD_CLIP_CALC_USDC_A, 4_320_000);
            // Set Max Auction Duration (tail) to 43,200 seconds
            DssExecLib.setAuctionTimeBeforeReset(_ilk, 43_200);
            // Set Max Auction Drawdown / Permitted Drop (cusp) to 0.99
            DssExecLib.setAuctionPermittedDrop(_ilk, 99_00);
            // Set Proportional Kick Incentive (chip) to 0
            DssExecLib.setKeeperIncentivePercent(_ilk, 0);
            // Set Flat Kick Incentive (tip) to 0
            DssExecLib.setKeeperIncentiveFlatRate(_ilk, 0);
        }
        {
            bytes32 _ilk  = bytes32("PAXUSD-A");
            address _clip = DssExecLib.getChangelogAddress("MCD_CLIP_PAXUSD_A");
            //
            // Enable liquidations for PAXUSD-A
            // Note: ClipperMom cannot circuit-break on a DS-Value but we're adding
            //       the rely for consistency with other collaterals and in case the PIP
            //       changes to an OSM.
            DssExecLib.authorize(_clip, DssExecLib.clipperMom());
            DssExecLib.setValue(_clip, "stopped", 0);
            // Use Abacus/LinearDecrease
            DssExecLib.setContract(_clip, "calc", MCD_CLIP_CALC_PAXUSD_A);
            // Set Liquidation Penalty to 0
            DssExecLib.setIlkLiquidationPenalty(_ilk, 0);
            // Set Auction Price Multiplier (buf) to 1
            DssExecLib.setStartingPriceMultiplicativeFactor(_ilk, 100_00);
            // Set Local Liquidation Limit (ilk.hole) to 3m DAI
            DssExecLib.setIlkMaxLiquidationAmount(_ilk, 3_000_000);
            // Set tau for Abacus/LinearDecrease to 4,320,000 second
            DssExecLib.setLinearDecrease(MCD_CLIP_CALC_PAXUSD_A, 4_320_000);
            // Set Max Auction Duration (tail) to 43,200 seconds
            DssExecLib.setAuctionTimeBeforeReset(_ilk, 43_200);
            // Set Max Auction Drawdown / Permitted Drop (cusp) to 0.99
            DssExecLib.setAuctionPermittedDrop(_ilk, 99_00);
            // Set Proportional Kick Incentive (chip) to 0
            DssExecLib.setKeeperIncentivePercent(_ilk, 0);
            // Set Flat Kick Incentive (tip) to 0
            DssExecLib.setKeeperIncentiveFlatRate(_ilk, 0);
        }

        // ------------------ Setup new Starknet Governance Relay -----------------

        // Relay l2 part of the spell
        StarknetGovRelayLike(STARKNET_GOV_RELAY).relay(L2_GOV_RELAY_SPELL);

        // Configure Chainlog
        DssExecLib.setChangelogAddress("STARKNET_GOV_RELAY_LEGACY", STARKNET_GOV_RELAY);
        DssExecLib.setChangelogAddress("STARKNET_GOV_RELAY", NEW_STARKNET_GOV_RELAY);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_GUSD_A", MCD_CLIP_CALC_GUSD_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_USDC_A", MCD_CLIP_CALC_USDC_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_PAXUSD_A", MCD_CLIP_CALC_PAXUSD_A);


        // ----------------------------- Collateral onboarding -----------------------------
        //  Add GNO-A as a new Vault Type
        //  Poll Link:   TODO
        //  Forum Post:  https://forum.makerdao.com/t/gno-collateral-onboarding-risk-evaluation/18820

        DssExecLib.addNewCollateral(
            CollateralOpts({
                ilk:                  "GNO-A",
                gem:                  GNO,
                join:                 MCD_JOIN_GNO_A,
                clip:                 MCD_CLIP_GNO_A,
                calc:                 MCD_CLIP_CALC_GNO_A,
                pip:                  PIP_GNO,
                isLiquidatable:       true,
                isOSM:                true,
                whitelistOSM:         true,
                ilkDebtCeiling:       5_000_000,         // line updated to 5M
                minVaultAmount:       100_000,           // debt floor - dust in DAI
                maxLiquidationAmount: 2_000_000,
                liquidationPenalty:   13_00,             // 13% penalty on liquidation
                ilkStabilityFee:      TWO_FIVE_PCT_RATE, // 2.50% stability fee
                startingPriceFactor:  120_00,            // Auction price begins at 120% of oracle price
                breakerTolerance:     50_00,             // Allows for a 50% hourly price drop before disabling liquidation
                auctionDuration:      140 minutes,
                permittedDrop:        25_00,             // 25% price drop before reset
                liquidationRatio:     350_00,            // 350% collateralization
                kprFlatReward:        250,               // 250 DAI tip - flat fee per kpr
                kprPctReward:         10                 // 0.1% chip - per kpr
            })
        );

        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_GNO_A, 60 seconds, 99_00);
        DssExecLib.setIlkAutoLineParameters("GNO-A", 5_000_000, 3_000_000, 8 hours);

        // -------------------- Changelog Update ---------------------

        DssExecLib.setChangelogAddress("GNO",                 GNO);
        DssExecLib.setChangelogAddress("PIP_GNO",             PIP_GNO);
        DssExecLib.setChangelogAddress("MCD_JOIN_GNO_A",      MCD_JOIN_GNO_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_GNO_A",      MCD_CLIP_GNO_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_GNO_A", MCD_CLIP_CALC_GNO_A);

        // Bump changelog
        DssExecLib.setChangelogVersion("1.14.7");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
