// SPDX-FileCopyrightText: © 2022 Dai Foundation <www.daifoundation.org>
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

import "dss-exec-lib/DssExecLib.sol";



contract DssSpellCollateralAction {
    // --- Rates ---
    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmVp4mhhbwWGTfbh2BzwQB9eiBrQBKiqcPRZCaAxNUaar6
    //

    // --- Math ---
    uint256 internal constant MILLION = 10 **  6;
    uint256 internal constant WAD     = 10 ** 18;
    uint256 internal constant RAY     = 10 ** 27;
    uint256 internal constant RAD     = 10 ** 45;

    // Change clip parameters
    function collateralAuctionParameterChanges(
        address MCD_DOG
    ) internal {
        
        // Load Clippers for ilks being modified
        address MCD_CLIP_ETH_A   = DssExecLib.getChangelogAddress("MCD_CLIP_ETH_A"); 
        address MCD_CLIP_ETH_B   = DssExecLib.getChangelogAddress("MCD_CLIP_ETH_B");
        address MCD_CLIP_ETH_C   = DssExecLib.getChangelogAddress("MCD_CLIP_ETH_C");
        address MCD_CLIP_WBTC_A   = DssExecLib.getChangelogAddress("MCD_CLIP_WBTC_A");
        address MCD_CLIP_WBTC_B   = DssExecLib.getChangelogAddress("MCD_CLIP_WBTC_B");
        address MCD_CLIP_WBTC_C   = DssExecLib.getChangelogAddress("MCD_CLIP_WBTC_C");
        address MCD_CLIP_WSTETH_A   = DssExecLib.getChangelogAddress("MCD_CLIP_WSTETH_A");
        address MCD_CLIP_WSTETH_B   = DssExecLib.getChangelogAddress("MCD_CLIP_WSTETH_B");
        // address MCD_CLIP_CRVV1ETHSTETH_A   = DssExecLib.getChangelogAddress("MCD_CLIP_CRVV1ETHSTETH_A"); // Not on Goerli
        address MCD_CLIP_LINK_A   = DssExecLib.getChangelogAddress("MCD_CLIP_LINK_A");
        address MCD_CLIP_MANA_A   = DssExecLib.getChangelogAddress("MCD_CLIP_MANA_A");
        address MCD_CLIP_MATIC_A   = DssExecLib.getChangelogAddress("MCD_CLIP_MATIC_A");
        address MCD_CLIP_RENBTC_A   = DssExecLib.getChangelogAddress("MCD_CLIP_RENBTC_A");
        address MCD_CLIP_YFI_A   = DssExecLib.getChangelogAddress("MCD_CLIP_YFI_A");

        // buf changes (Auction price multiplier)
        Fileable(MCD_CLIP_ETH_A).file("buf", 110 * RAY / 100);
        Fileable(MCD_CLIP_ETH_B).file("buf", 110 * RAY / 100);
        Fileable(MCD_CLIP_ETH_C).file("buf", 110 * RAY / 100);
        Fileable(MCD_CLIP_WBTC_A).file("buf", 110 * RAY / 100);
        Fileable(MCD_CLIP_WBTC_B).file("buf", 110 * RAY / 100);
        Fileable(MCD_CLIP_WBTC_C).file("buf", 110 * RAY / 100);
        Fileable(MCD_CLIP_WSTETH_A).file("buf", 110 * RAY / 100);
        Fileable(MCD_CLIP_WSTETH_B).file("buf", 110 * RAY / 100);
        //Fileable(MCD_CLIP_CRVV1ETHSTETH_A).file("buf", 120 * RAY / 100); // Not on Goerli
        Fileable(MCD_CLIP_LINK_A).file("buf", 120 * RAY / 100);
        Fileable(MCD_CLIP_MANA_A).file("buf", 120 * RAY / 100);
        Fileable(MCD_CLIP_MATIC_A).file("buf", 120 * RAY / 100);
        Fileable(MCD_CLIP_RENBTC_A).file("buf", 120 * RAY / 100);
        
        // cusp changes (Max asset drawdown)
        Fileable(MCD_CLIP_ETH_A).file("cusp", 45 * RAY / 100);
        Fileable(MCD_CLIP_ETH_B).file("cusp", 45 * RAY / 100);
        Fileable(MCD_CLIP_ETH_C).file("cusp", 45 * RAY / 100);
        Fileable(MCD_CLIP_WBTC_A).file("cusp", 45 * RAY / 100);
        Fileable(MCD_CLIP_WBTC_B).file("cusp", 45 * RAY / 100);
        Fileable(MCD_CLIP_WBTC_C).file("cusp", 45 * RAY / 100);
        Fileable(MCD_CLIP_WSTETH_A).file("cusp", 45 * RAY / 100);
        Fileable(MCD_CLIP_WSTETH_B).file("cusp", 45 * RAY / 100);
        
        // tail changes (Max auction duration)
        Fileable(MCD_CLIP_ETH_A).file("tail", 7200 seconds);
        Fileable(MCD_CLIP_ETH_C).file("tail", 7200 seconds);
        Fileable(MCD_CLIP_WBTC_A).file("tail", 7200 seconds);
        Fileable(MCD_CLIP_WSTETH_A).file("tail", 7200 seconds);
        Fileable(MCD_CLIP_WSTETH_B).file("tail", 7200 seconds);
        Fileable(MCD_CLIP_ETH_B).file("tail", 4800 seconds); 
        Fileable(MCD_CLIP_WBTC_B).file("tail", 4800 seconds);
        Fileable(MCD_CLIP_WBTC_C).file("tail", 7200 seconds);
        
        // dog.hole changes (ilk.hole)
        Fileable(MCD_DOG).file("ETH-A", "hole", 40_000_000 * RAD);
        Fileable(MCD_DOG).file("ETH-B", "hole", 15_000_000 * RAD);
        Fileable(MCD_DOG).file("WBTC-A", "hole", 30_000_000 * RAD);
        Fileable(MCD_DOG).file("WBTC-B", "hole", 10_000_000 * RAD);
        Fileable(MCD_DOG).file("WBTC-C", "hole", 20_000_000 * RAD);
        Fileable(MCD_DOG).file("LINK-A", "hole", 3_000_000 * RAD);
        Fileable(MCD_DOG).file("YFI-A", "hole", 1_000_000 * RAD);
        Fileable(MCD_DOG).file("RENBTC-A", "hole", 2_000_000 * RAD);

        // tip changes 
        Fileable(MCD_CLIP_ETH_A).file("tip", 250 * RAD);
        Fileable(MCD_CLIP_ETH_B).file("tip", 250 * RAD);
        Fileable(MCD_CLIP_ETH_C).file("tip", 250 * RAD);
        Fileable(MCD_CLIP_WBTC_A).file("tip", 250 * RAD);
        Fileable(MCD_CLIP_WBTC_B).file("tip", 250 * RAD);
        Fileable(MCD_CLIP_WBTC_C).file("tip", 250 * RAD);
        Fileable(MCD_CLIP_WSTETH_A).file("tip", 250 * RAD);
        Fileable(MCD_CLIP_WSTETH_B).file("tip", 250 * RAD);
        //Fileable(MCD_CLIP_CRVV1ETHSTETH_A).file("tip", 250 * RAD); // Not on Goerli
        Fileable(MCD_CLIP_LINK_A).file("tip", 250 * RAD);
        Fileable(MCD_CLIP_MANA_A).file("tip", 250 * RAD);
        Fileable(MCD_CLIP_MATIC_A).file("tip", 250 * RAD);
        Fileable(MCD_CLIP_RENBTC_A).file("tip", 250 * RAD);
        Fileable(MCD_CLIP_YFI_A).file("tip", 250 * RAD);

    }

    // NOTE: Awaiting confirmation: MOMC Parameter Changes - vote ends Thursday

    // TODO: Skip on Goerli - Delegate Compensation - September 2022

    function systemParameterChanges(
        address MCD_DOG
    ) internal {
        // Reduce the Hole from 100,000,000 DAI to 70,000,000 DAI
        dog. file("Hole", 70 * MILLION);
    }

    function onboardNewCollaterals() internal {

        // --------------------------- Auction parameter changes ---------------------------
        // Parameter changes : https://vote.makerdao.com/polling/QmREbu1j
        address MCD_DOG = DssExecLib.getChangelogAddress("MCD_DOG");
        // Change ilk-specific auction parameters
        collateralAuctionParameterChanges(MCD_DOG);
        // Change global auction parameters
        systemParameterChanges(MCD_DOG);
    }
}
