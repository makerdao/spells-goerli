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
    function file(bytes32 what, uint256 data) external;
    function ilks(bytes32 ilk) external view returns (uint256 Art, uint256 rate, uint256 spot, uint256 line, uint256 dust);
}

interface RwaLiquidationLike {
    function ilks(bytes32) external view returns (string memory doc, address pip, uint48 tau, uint48 toc);
    function init(bytes32 ilk, uint256 val, string memory doc, uint48 tau) external;
    function bump(bytes32 ilk, uint256 val) external;
}

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Always keep office hours off on goerli
    function officeHours() public pure override returns (bool) {
        return false;
    }

    // ---------- Rates ----------
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
    uint256 internal constant THREE_PT_THREE_THREE_PCT_RATE = 1000000001038735548426731741;
    uint256 internal constant THREE_PT_FIVE_EIGHT_PCT_RATE  = 1000000001115362602336059074;
    uint256 internal constant FOUR_PT_ZERO_EIGHT_PCT_RATE   = 1000000001268063427242299977;
    uint256 internal constant FIVE_PT_PCT_RATE              = 1000000001547125957863212448;
    uint256 internal constant FIVE_PT_TWO_FIVE_PCT_RATE     = 1000000001622535724756171269;
    uint256 internal constant FIVE_PT_FIVE_FIVE_PCT_RATE    = 1000000001712791360746325100;
    uint256 internal constant FIVE_PT_EIGHT_ZERO_PCT_RATE   = 1000000001787808646832390371;
    uint256 internal constant SIX_PT_THREE_ZERO_PCT_RATE    = 1000000001937312893803622469;
    uint256 internal constant SEVEN_PT_PCT_RATE             = 1000000002145441671308778766;

    // ---------- Math ----------
    uint256 internal constant THOUSAND = 10 ** 3;
    uint256 internal constant MILLION  = 10 ** 6;
    uint256 internal constant BILLION  = 10 ** 9;
    uint256 internal constant WAD      = 10 ** 18;
    uint256 internal constant RAD      = 10 ** 45;

    // ---------- Smart Burn Engine Parameter Updates ----------
    address internal immutable MCD_VOW            = DssExecLib.vow();
    address internal immutable MCD_FLAP           = DssExecLib.flap();

    // ---------- CRVV1ETHSTETH-A 2nd Stage Offboarding ----------
    // VatLike internal immutable vat = VatLike(DssExecLib.vat());

    // ---------- New Silver Parameter Changes ----------
    address internal immutable MIP21_LIQUIDATION_ORACLE = DssExecLib.getChangelogAddress("MIP21_LIQUIDATION_ORACLE");

    function actions() public override {
        // ---------- EDSR Update ----------
        // Forum: https://forum.makerdao.com/t/request-for-gov12-1-2-edit-to-the-stability-scope-to-quickly-modify-enhanced-dsr-based-on-observed-data/21581

        // Reduce DSR by 3% from 8% to 5%
        DssExecLib.setDSR(FIVE_PT_PCT_RATE, /* doDrip = */ true);

        // ---------- DSR-based Stability Fee Updates ----------
        // Forum: https://forum.makerdao.com/t/request-for-gov12-1-2-edit-to-the-stability-scope-to-quickly-modify-enhanced-dsr-based-on-observed-data/21581

        // Increase ETH-A SF by 0.14% from 3.44% to 3.58%
        DssExecLib.setIlkStabilityFee("ETH-A", THREE_PT_FIVE_EIGHT_PCT_RATE, /* doDrip = */ true);

        // Increase ETH-B SF by 0.14% from 3.94%% to 4.08%
        DssExecLib.setIlkStabilityFee("ETH-B", FOUR_PT_ZERO_EIGHT_PCT_RATE, /* doDrip = */ true);

        // Increase ETH-C SF by 0.14% from 3.19% to 3.33%
        DssExecLib.setIlkStabilityFee("ETH-C", THREE_PT_THREE_THREE_PCT_RATE, /* doDrip = */ true);

        // Increase WSTETH-A SF by 1.81% from 3.44% to 5.25%
        DssExecLib.setIlkStabilityFee("WSTETH-A", FIVE_PT_TWO_FIVE_PCT_RATE, /* doDrip = */ true);

        // Increase WSTETH-B SF by 1.81% from 3.19% to 5.00%
        DssExecLib.setIlkStabilityFee("WSTETH-B", FIVE_PT_PCT_RATE, /* doDrip = */ true);

        // Increase RETH-A SF by 1.81% from 3.44% to 5.25%
        DssExecLib.setIlkStabilityFee("RETH-A", FIVE_PT_TWO_FIVE_PCT_RATE, /* doDrip = */ true);

        // Increase WBTC-A SF by 0.11% from 5.69% to 5.80%
        DssExecLib.setIlkStabilityFee("WBTC-A", FIVE_PT_EIGHT_ZERO_PCT_RATE, /* doDrip = */ true);

        // Increase WBTC-B SF by 0.11% from 6.19% to 6.30%
        DssExecLib.setIlkStabilityFee("WBTC-B", SIX_PT_THREE_ZERO_PCT_RATE, /* doDrip = */ true);

        // Increase WBTC-C SF by 0.11% from 5.44% to 5.55%
        DssExecLib.setIlkStabilityFee("WBTC-C", FIVE_PT_FIVE_FIVE_PCT_RATE, /* doDrip = */ true);

        // ---------- Smart Burn Engine Parameter Updates ----------
        // Poll: https://vote.makerdao.com/polling/QmTRJNNH
        // Forum: https://forum.makerdao.com/t/smart-burn-engine-parameters-update-1/21545

        // Increase vow.bump by 15,000 DAI from 5,000 DAI to 20,000 DAI
        DssExecLib.setValue(MCD_VOW, "bump", 20 * THOUSAND * RAD);

        // Increase hop by 4,731 seconds from 1,577 seconds to 6,308 seconds
        DssExecLib.setValue(MCD_FLAP, "hop", 6_308);

        // ---------- Non-DSR Related Parameter Changes ----------
        // Forum: https://forum.makerdao.com/t/stability-scope-parameter-changes-4/21567
        // Mip: https://mips.makerdao.com/mips/details/MIP104#14-3-native-vault-engine

        // Increase WSTETH-A line by 250 million DAI from 500 million DAI to 750 million DAI (no change to gap or ttl)
        DssExecLib.setIlkAutoLineDebtCeiling("WSTETH-A", 750 * MILLION);

        // Increase WSTETH-B line by 500 million DAi from 500 million DAI to 1 billion DAI
        // Increase WSTETH-B gap by 15 million DAI from 30 million DAI to 45 million DAI
        // Reduce WSTETH-B ttl by 14,400 seconds from 57,600 seconds to 43,200 seconds
        DssExecLib.setIlkAutoLineParameters("WSTETH-B", 1 * BILLION, 45 * MILLION, 12 hours);

        // Increase RETH-A line by 25 million DAI from 50 million DAI to 75 million DAI
        DssExecLib.setIlkAutoLineDebtCeiling("RETH-A", 75 * MILLION);

        // ---------- CRVV1ETHSTETH-A 2nd Stage Offboarding ----------
        // Forum: https://forum.makerdao.com/t/stability-scope-parameter-changes-4/21567#crvv1ethsteth-a-offboarding-parameters-13
        // Mip: https://mips.makerdao.com/mips/details/MIP104#14-3-native-vault-engine
        // NOTE: ignore on goerli (since there is no CRVV1ETHSTETH-A there)

        // Set chop to 0%
        // DssExecLib.setIlkLiquidationPenalty("CRVV1ETHSTETH-A", 0);

        // Set tip to 0%
        // DssExecLib.setKeeperIncentiveFlatRate("CRVV1ETHSTETH-A", 0);

        // Set chip to 0%
        // DssExecLib.setKeeperIncentivePercent("CRVV1ETHSTETH-A", 0);

        // Set Liquidation Ratio to 10,000%
        // NOTE: We are using low level methods because DssExecLib only allows setting `mat < 1000%`: https://github.com/makerdao/dss-exec-lib/blob/69b658f35d8618272cd139dfc18c5713caf6b96b/src/DssExecLib.sol#L717
        // DssExecLib.setValue(MCD_SPOT, "CRVV1ETHSTETH-A", "mat", 100 * RAY);

        // NOTE: Update spotter price
        // DssExecLib.updateCollateralPrice("CRVV1ETHSTETH-A");

        // Reduce Global Debt Ceiling by 100 million DAI to account for offboarded collateral
        // vat.file("Line", vat.Line() - 100 * MILLION * RAD);

        // ---------- Aligned Delegate Compensation for July 2023 ----------
        // NOTE: ignore on goerli

        // ---------- Old D3M Parameter Housekeeping ----------
        // Forum: https://forum.makerdao.com/t/notice-of-executive-vote-date-change-and-housekeeping-changes/21613
        // NOTE: ignore on goerli

        // Remove DIRECT-AAVEV2-DAI from autoline
        // DssExecLib.removeIlkFromAutoLine("DIRECT-AAVEV2-DAI");

        // Set DIRECT-AAVEV2-DAI Debt Ceiling to 0
        // DssExecLib.setIlkDebtCeiling("DIRECT-AAVEV2-DAI", 0);

        // Remove DIRECT-COMPV2-DAI from autoline
        // DssExecLib.removeIlkFromAutoLine("DIRECT-COMPV2-DAI");

        // Set DIRECT-COMPV2-DAI Debt Ceiling to 0
        // DssExecLib.setIlkDebtCeiling("DIRECT-COMPV2-DAI", 0);

        // Reduce Global Debt Ceiling? Yes

        // ---------- New Silver Parameter Changes ----------
        // Forum: https://forum.makerdao.com/t/rwa-002-new-silver-restructuring-risk-and-legal-assessment/21417
        // Poll: https://vote.makerdao.com/polling/QmaU1eaD#poll-detail

        // Increase RWA002-A Debt Ceiling by 30 million DAI from 20 million DAI to 50 million DAI
        DssExecLib.increaseIlkDebtCeiling(
            "RWA002-A",
            30 * MILLION,
            true // Increase global Line
        );

        // Increase RWA002-A Stability Fee by 3.5% from 3.5% to 7%
        DssExecLib.setIlkStabilityFee("RWA002-A", SEVEN_PT_PCT_RATE, /* doDrip = */ true);

        // Bump Oracle price to account for new DC and SF
        // NOTE: the formula is: Debt ceiling * [ (1 + RWA stability fee ) ^ (minimum deal duration in years) ] * liquidation ratio
        // 50_000_000 * (1.07 ^ 2) * 1.05
        RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).bump(
            "RWA002-A",
            60_107_250 * WAD
        );
        DssExecLib.updateCollateralPrice("RWA002-A");

        // ---------- Transfer Spark Proxy Admin Controls ----------

        // ---------- Trigger Spark Proxy Spell ----------
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
