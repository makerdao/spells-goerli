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

contract DssSpellAction is DssAction, DssSpellCollateralAction {

    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    uint256 internal constant MILLION = 10 ** 6;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmVp4mhhbwWGTfbh2BzwQB9eiBrQBKiqcPRZCaAxNUaar6
    //
    uint256 internal constant ONE_FIVE_PCT_RATE = 1000000000472114805215157978; 

    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {

        // Includes changes from the DssSpellCollateralAction
        // onboardNewCollaterals();

        // ---------------------------------------------------------------------
        // Collateral Auction Parameter Changes
        // https://vote.makerdao.com/polling/QmREbu1j#poll-detail
        // https://forum.makerdao.com/t/collateral-auctions-analysis-parameter-updates-september-2022/18063#proposed-changes-17
        
        // buf changes (Starting auction price multiplier)
        DssExecLib.setStartingPriceMultiplicativeFactor("ETH-A"          , 110_00);
        DssExecLib.setStartingPriceMultiplicativeFactor("ETH-B"          , 110_00);
        DssExecLib.setStartingPriceMultiplicativeFactor("ETH-C"          , 110_00);
        DssExecLib.setStartingPriceMultiplicativeFactor("WBTC-A"         , 110_00);
        DssExecLib.setStartingPriceMultiplicativeFactor("WBTC-B"         , 110_00);
        DssExecLib.setStartingPriceMultiplicativeFactor("WBTC-C"         , 110_00);
        DssExecLib.setStartingPriceMultiplicativeFactor("WSTETH-A"       , 110_00);
        DssExecLib.setStartingPriceMultiplicativeFactor("WSTETH-B"       , 110_00);
        //DssExecLib.setStartingPriceMultiplicativeFactor("CRVV1ETHSTETH-A", 120_00); // Not on Goerli
        DssExecLib.setStartingPriceMultiplicativeFactor("LINK-A"         , 120_00);
        DssExecLib.setStartingPriceMultiplicativeFactor("MANA-A"         , 120_00);
        DssExecLib.setStartingPriceMultiplicativeFactor("MATIC-A"        , 120_00);
        DssExecLib.setStartingPriceMultiplicativeFactor("RENBTC-A"       , 120_00);
        
        // cusp changes (Max percentage drop permitted before auction reset)
        DssExecLib.setAuctionPermittedDrop("ETH-A"    , 45_00);
        DssExecLib.setAuctionPermittedDrop("ETH-B"    , 45_00);
        DssExecLib.setAuctionPermittedDrop("ETH-C"    , 45_00);
        DssExecLib.setAuctionPermittedDrop("WBTC-A"   , 45_00);
        DssExecLib.setAuctionPermittedDrop("WBTC-B"   , 45_00);
        DssExecLib.setAuctionPermittedDrop("WBTC-C"   , 45_00);
        DssExecLib.setAuctionPermittedDrop("WSTETH-A" , 45_00);
        DssExecLib.setAuctionPermittedDrop("WSTETH-B" , 45_00);
        
        // tail changes (Max auction duration)
        DssExecLib.setAuctionTimeBeforeReset("ETH-A"    , 7200 seconds);
        DssExecLib.setAuctionTimeBeforeReset("ETH-C"    , 7200 seconds);
        DssExecLib.setAuctionTimeBeforeReset("WBTC-A"   , 7200 seconds);
        DssExecLib.setAuctionTimeBeforeReset("WBTC-C"   , 7200 seconds);
        DssExecLib.setAuctionTimeBeforeReset("WSTETH-A" , 7200 seconds);
        DssExecLib.setAuctionTimeBeforeReset("WSTETH-B" , 7200 seconds);
        DssExecLib.setAuctionTimeBeforeReset("ETH-B"    , 4800 seconds);
        DssExecLib.setAuctionTimeBeforeReset("WBTC-B"   ,  4800 seconds);
        
        // ilk hole changes (Max concurrent liquidation amount for an ilk)
        DssExecLib.setIlkMaxLiquidationAmount("ETH-A"    , 40 * MILLION);
        DssExecLib.setIlkMaxLiquidationAmount("ETH-B"    , 15 * MILLION);
        DssExecLib.setIlkMaxLiquidationAmount("WBTC-A"   , 30 * MILLION);
        DssExecLib.setIlkMaxLiquidationAmount("WBTC-B"   , 10 * MILLION);
        DssExecLib.setIlkMaxLiquidationAmount("WBTC-C"   , 20 * MILLION);
        DssExecLib.setIlkMaxLiquidationAmount("LINK-A"   , 3 * MILLION);
        DssExecLib.setIlkMaxLiquidationAmount("YFI-A"    , 1 * MILLION);
        DssExecLib.setIlkMaxLiquidationAmount("RENBTC-A" , 2 * MILLION);

        // tip changes (Max keeper incentive in DAI)
        DssExecLib.setKeeperIncentiveFlatRate("ETH-A"           , 250);
        DssExecLib.setKeeperIncentiveFlatRate("ETH-B"           , 250);
        DssExecLib.setKeeperIncentiveFlatRate("ETH-C"           , 250);
        DssExecLib.setKeeperIncentiveFlatRate("WBTC-A"          , 250);
        DssExecLib.setKeeperIncentiveFlatRate("WBTC-B"          , 250);
        DssExecLib.setKeeperIncentiveFlatRate("WBTC-C"          , 250);
        DssExecLib.setKeeperIncentiveFlatRate("WSTETH-A"        , 250);
        DssExecLib.setKeeperIncentiveFlatRate("WSTETH-B"        , 250);
        //DssExecLib.setKeeperIncentiveFlatRate("CRVV1ETHSTETH-A" , 250); // Not on Goerli
        DssExecLib.setKeeperIncentiveFlatRate("LINK-A"          , 250);
        DssExecLib.setKeeperIncentiveFlatRate("MANA-A"          , 250);
        DssExecLib.setKeeperIncentiveFlatRate("MATIC-A"         , 250);
        //DssExecLib.setKeeperIncentiveFlatRate("RENBTC-A"        , 250); // Not on Goerli
        DssExecLib.setKeeperIncentiveFlatRate("YFI-A"           , 250);

        // dog Hole change (Max concurrent global liquidation value)
        DssExecLib.setMaxTotalDAILiquidationAmount(70 * MILLION);

        // ---------------------------------------------------------------------
        // MOMC Parameter Changes
        // https://vote.makerdao.com/polling/QmbLyNUd#poll-detail
        // https://forum.makerdao.com/t/parameter-changes-proposal-ppg-omc-001-29-september-2022/18143
        
        // CRVV1ETHSTETH-A stability fee change (2.0% --> 1.5%) // Not on Goerli
        //DssExecLib.setIlkStabilityFee("CRVV1ETHSTETH-A", ONE_FIVE_PCT_RATE, true);
        
        // YFI-A DC IAM line change (25M --> 10M)
        DssExecLib.setIlkAutoLineDebtCeiling("YFI-A" , 10 * MILLION);

        // ---------------------------------------------------------------------
        // Delegate Compensation - September 2022 // Not on Goerli

        // ---------------------------------------------------------------------
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
