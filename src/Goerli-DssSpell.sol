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

interface VatLike {
    function ilks(bytes32) external view returns (uint256, uint256, uint256, uint256, uint256);
    function Line() external view returns (uint256);
}


contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Turn office hours off
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
    //    https://ipfs.io/ipfs/QmVp4mhhbwWGTfbh2BzwQB9eiBrQBKiqcPRZCaAxNUaar6
    //
    uint256 internal constant ONE_PCT_RATE      = 1000000000315522921573372069;
    uint256 internal constant TWO_FIVE_PCT_RATE = 1000000000782997609082909351;

    // --- MATH ---
    uint256 internal constant MILLION           = 10 ** 6;
    uint256 internal constant WAD               = 10 ** 18;
    uint256 internal constant RAY               = 10 ** 27;

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    address internal immutable VAT            = DssExecLib.vat();
    address internal immutable MCD_PSM_PAX_A  = DssExecLib.getChangelogAddress("MCD_PSM_PAX_A");
    address internal immutable MCD_PSM_GUSD_A = DssExecLib.getChangelogAddress("MCD_PSM_GUSD_A");

    // --- DEPLOYED COLLATERAL ADDRESSES ---
    address internal constant GNO                 = 0x86Bc432064d7F933184909975a384C7E4c9d0977;
    address internal constant PIP_GNO             = 0xf15221A159A4e7ba01E0d6e72111F0Ddff8Fa8Da;
    address internal constant MCD_JOIN_GNO_A      = 0x05a3b9D5F8098e558aF33c6b83557484f840055e;
    address internal constant MCD_CLIP_GNO_A      = 0x8274F3badD42C61B8bEa78Df941813D67d1942ED;
    address internal constant MCD_CLIP_CALC_GNO_A = 0x08Ae3e0C0CAc87E1B4187D53F0231C97B5b4Ab3E;

    function actions() public override {

        // Delegate Compensation - November 2022
        // https://forum.makerdao.com/t/recognized-delegate-compensation-november-2022/19012
        // NOT ON GOERLI


        // Tech-Ops MKR Transfer
        // https://mips.makerdao.com/mips/details/MIP40c3SP54
        // NOT ON GOERLI


        // MOMC Parameter Changes
        // https://vote.makerdao.com/polling/QmVXj9cW

        // Increase WSTETH-A line from 150 million DAI to 500 million DAI
        // Reduce WSTETH-A gap from 30 million DAI to 15 million DAI
        DssExecLib.setIlkAutoLineParameters("WSTETH-A", 500 * MILLION, 15 * MILLION, 6 hours);
        // Increase WSTETH-B line from 200 million DAI to 500 million DAI
        // Reduce WSTETH-B gap from 30 million DAI to 15 million DAI
        DssExecLib.setIlkAutoLineParameters("WSTETH-B", 500 * MILLION, 15 * MILLION, 8 hours);
        // Reduce ETH-B line from 500 million to 250 million DAI
        DssExecLib.setIlkAutoLineDebtCeiling("ETH-B", 250 * MILLION);
        // Reduce WBTC-A line from 2 billion DAI to 500 million DAI
        // Reduce WBTC-A gap from 80 million DAI to 20 million DAI
        // Increase WBTC-A ttl from 6 hours to 24 hours
        DssExecLib.setIlkAutoLineParameters("WBTC-A", 500 * MILLION, 20 * MILLION, 24 hours);
        // Reduce WBTC-B line from 500 million DAI to 250 million DAI
        // Reduce WBTC-B gap from 30 million DAI to 10 million DAI
        // Increase WBTC-B ttl from 8 hours to 24 hours
        DssExecLib.setIlkAutoLineParameters("WBTC-B", 250 * MILLION, 10 * MILLION, 24 hours);
        // Reduce WBTC-C line from 1 billion DAI to 500 million DAI
        // Reduce WBTC-C gap from 100 million DAI to 20 million DAI
        // Increase WBTC-C ttl from 8 hours to 24 hours
        DssExecLib.setIlkAutoLineParameters("WBTC-C", 500 * MILLION, 20 * MILLION, 24 hours);
        // Reduce MANA-A line from 1 million DAI to 0 DAI
        bytes32 _ilk = "MANA-A";
        DssExecLib.removeIlkFromAutoLine(_ilk);
        (,,, uint256 _line,) = VatLike(VAT).ilks(_ilk);
        DssExecLib.setValue(VAT, _ilk, "line", 0);
        DssExecLib.setValue(VAT, "Line", sub(VatLike(VAT).Line(), _line));
        // Reduce GUNIV3DAIUSDC1-A line from 1 billion DAI to 100 million DAI
        DssExecLib.setIlkAutoLineDebtCeiling("GUNIV3DAIUSDC1-A", 100 * MILLION);
        // Reduce GUINV3DAIUSDC2-A line from 1.25 billion DAI to 100 million DAI
        DssExecLib.setIlkAutoLineDebtCeiling("GUNIV3DAIUSDC2-A", 100 * MILLION);
        // Reduce the UNIV2DAIUSDC-A line from 300 million DAI to 100 million DAI
        DssExecLib.setIlkAutoLineDebtCeiling("UNIV2DAIUSDC-A", 100 * MILLION);
        // Reduce the PSM-USDP-A line from 500 million DAI to 450 million DAI
        DssExecLib.setIlkAutoLineDebtCeiling("PSM-PAX-A", 450 * MILLION);
        // Reduce LINK-A gap from 7 million DAI to 2.5 million DAI
        DssExecLib.setIlkAutoLineParameters("LINK-A", 5 * MILLION, 2_500_000, 8 hours);
        // Reduce YFI-A gap from 7 million DAI to 1.5 million DAI
        DssExecLib.setIlkAutoLineParameters("YFI-A", 3 * MILLION, 1_500_000, 8 hours);


        // PSM tin increases
        // Increase PSM-USDP-A tin from 0% to 0.1%
        DssExecLib.setValue(MCD_PSM_PAX_A, "tin", 1 * WAD / 1000);
        // Increase PSM-GUSD-A tin from 0% to 0.1%
        DssExecLib.setValue(MCD_PSM_GUSD_A, "tin", 1 * WAD / 1000);

        // PSM tout decrease
        // Reduce PSM-GUSD-A tout from 0.2% to 0.1%
        DssExecLib.setValue(MCD_PSM_GUSD_A, "tout", 1 * WAD / 1000);


        // DSR Adjustment
        // https://vote.makerdao.com/polling/914#vote-breakdown
        // Increase the DSR to 1%
        DssExecLib.setDSR(ONE_PCT_RATE, true);

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


        // RWA-010 Onboarding
        // https://vote.makerdao.com/polling/QmNucsGt
        // TODO


        // RWA-011 Onboarding
        // https://vote.makerdao.com/polling/QmNucsGt
        // TODO


        // RWA-012 Onboarding
        // https://vote.makerdao.com/polling/QmNucsGt
        // TODO


        // RWA-013 Onboarding
        // https://vote.makerdao.com/polling/QmNucsGt
        // TODO


        // ----------------------------- Collateral offboarding -----------------------------
        //  Offboard RENBTC-A
        //  Poll Link:   https://vote.makerdao.com/polling/QmTNMDfb#poll-detail
        //  Forum Post:  https://forum.makerdao.com/t/renbtc-a-proposed-offboarding-parameters-context/18864

        DssExecLib.setIlkLiquidationPenalty("RENBTC-A", 0);
        DssExecLib.setKeeperIncentiveFlatRate("RENBTC-A", 0);
        // setIlkLiquidationRatio to 5000%
        // We are using low level methods  because DssExecLib allow to set `mat < 1000%`: https://github.com/makerdao/dss-exec-lib/blob/2afff4373e8a827659df28f6d349feb25f073e59/src/DssExecLib.sol#L733
        DssExecLib.setValue(DssExecLib.spotter(), "RENBTC-A", "mat", 50 * RAY); // 5000%
        DssExecLib.setIlkMaxLiquidationAmount("RENBTC-A", 350_000);
        // PIP_RENBTC `kiss` MCD_CLIP_RENBTC_A. This should not be included in mainnet spell
        DssExecLib.addReaderToWhitelist(DssExecLib.getChangelogAddress("PIP_RENBTC"), DssExecLib.getChangelogAddress("MCD_CLIP_RENBTC_A"));

        // Bump changelog
        DssExecLib.setChangelogVersion("1.14.7");

    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
