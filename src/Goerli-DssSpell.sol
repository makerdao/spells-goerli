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

import { DssSpellCollateralOnboardingAction } from "./DssSpellCollateralOnboarding.sol";

contract DssSpellAction is DssAction, DssSpellCollateralOnboardingAction {
    // Provides a descriptive tag for bot consumption
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
    uint256 constant ZERO_ONE_PCT_RATE       = 1000000000031693947650284507;
    uint256 constant TWO_PCT_RATE            = 1000000000627937192491029810;
    uint256 constant TWO_FIVE_PCT_RATE       = 1000000000782997609082909351;
    uint256 constant TWO_SEVEN_FIVE_PCT_RATE = 1000000000860244400048238898;
    uint256 constant THREE_PCT_RATE          = 1000000000937303470807876289;
    uint256 constant FOUR_PCT_RATE           = 1000000001243680656318820312;
    uint256 constant SIX_PCT_RATE            = 1000000001847694957439350562;
    uint256 constant SIX_FIVE_PCT_RATE       = 1000000001996917783620820123;

    // --- Math ---
    uint256 constant BILLION = 10 ** 9;

    // --- Ilks ---
    bytes32 constant WSTETH_A = "WSTETH-A";
    bytes32 constant MATIC_A  = "MATIC-A";
    bytes32 constant RWA006_A = "RWA006-A";

    function actions() public override {


        // ------------- Changes corresponding to the 2021-12-03 mainnet spell -------------
        // ---------------------------------------------------------------------------------

        // ---------------------------------------------------------------------------------
        // Includes changes from the DssSpellCollateralOnboardingAction
        onboardNewCollaterals();

        // ----------------------------- Rates updates -----------------------------
        // https://vote.makerdao.com/polling/QmNqCZGa?network=mainnet
        // Increase the ETH-A Stability Fee from 2.5% to 2.75%
        DssExecLib.setIlkStabilityFee("ETH-A", TWO_SEVEN_FIVE_PCT_RATE, true);

        // Increase the ETH-B Stability Fee from 6.0% to 6.5%
        DssExecLib.setIlkStabilityFee("ETH-B", SIX_FIVE_PCT_RATE, true);

        // Increase the LINK-A Stability Fee from 1.5% to 2.5%
        DssExecLib.setIlkStabilityFee("LINK-A", TWO_FIVE_PCT_RATE, true);

        // Increase the MANA-A Stability Fee from 3.0% to 6.0%
        DssExecLib.setIlkStabilityFee("MANA-A", SIX_PCT_RATE, true);

        // Increase the UNI-A Stability Fee from 1.0% to 3.0%
        DssExecLib.setIlkStabilityFee("UNI-A", THREE_PCT_RATE, true);

        // Increase the GUSD-A Stability Fee from 0.0% to 1.0%
        DssExecLib.setIlkStabilityFee("GUSD-A", ONE_PCT_RATE, true);

        // Increase the UNIV2DAIETH-A Stability Fee from 1.5% to 2.0%
        DssExecLib.setIlkStabilityFee("UNIV2DAIETH-A", TWO_PCT_RATE, true);

        // Increase the UNIV2WBTCETH-A Stability Fee from 2.5% to 3.0%
        DssExecLib.setIlkStabilityFee("UNIV2WBTCETH-A", THREE_PCT_RATE, true);

        // Increase the UNIV2USDCETH-A Stability Fee from 2.0% to 2.5%
        DssExecLib.setIlkStabilityFee("UNIV2USDCETH-A", TWO_FIVE_PCT_RATE, true);

        // Increase the UNIV2UNIETH-A Stability Fee from 2.0% to 4.0%
        DssExecLib.setIlkStabilityFee("UNIV2UNIETH-A", FOUR_PCT_RATE, true);

        // Decrease the GUNIV3DAIUSDC1-A Stability Fee from 0.5% to 0.1%
        DssExecLib.setIlkStabilityFee("GUNIV3DAIUSDC1-A", ZERO_ONE_PCT_RATE, true);

        // ----------------------------- Debt Ceiling updates -----------------------------
        // Increase the WBTC-A Maximum Debt Ceiling (line) from 1.5 billion DAI to 2 billion DAI
        // Increase the WBTC-A Target Available Debt (gap) from 60 million DAI to 80 million DAI
        // https://vote.makerdao.com/polling/QmNqCZGa?network=mainnet
        DssExecLib.setIlkAutoLineParameters("WBTC-A", 2 * BILLION, 80 * MILLION, 6 hours);

        // Increase the Dust Parameter from 30,000 DAI to 40,000 DAI for the ETH-B
        // https://vote.makerdao.com/polling/QmZXnn16?network=mainnet#poll-detail
        DssExecLib.setIlkMinVaultAmount("ETH-B", 40_000);

        // Increase the Dust Parameter from 10,000 DAI to 15,000 DAI for all vault-types excluding ETH-B and ETH-C
        // https://vote.makerdao.com/polling/QmUYLPcr?network=mainnet#poll-detail
        DssExecLib.setIlkMinVaultAmount("ETH-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("USDC-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("WBTC-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("TUSD-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("MANA-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("PAXUSD-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("LINK-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("YFI-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("GUSD-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNI-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("RENBTC-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2DAIETH-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2WBTCETH-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2USDCETH-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2DAIUSDC-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2UNIETH-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2WBTCDAI-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("MATIC-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("GUNIV3DAIUSDC1-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("WSTETH-A", 15_000);


        // no budget distributions on Görli


        // ---------------------------------------------------------------------------------
        // ------------- Changes corresponding to the 2021-12-10 mainnet spell -------------
        // ---------------------------------------------------------------------------------


        // ------------- Transfer vesting streams from MCD_VEST_MKR to MCD_VEST_MKR_TREASURY -------------
        // https://vote.makerdao.com/polling/QmYdDTsn

        // no vesting streams on Görli


        // -------------------- wstETH-A Parameter Changes ------------------------
        // https://vote.makerdao.com/polling/QmYuK441

        DssExecLib.setIlkAutoLineParameters({
            _ilk:    WSTETH_A,
            _amount: 200 * MILLION,
            _gap:    20 * MILLION,
            _ttl:    6 hours
        });
        DssExecLib.setStartingPriceMultiplicativeFactor(WSTETH_A, 120_00);
        DssExecLib.setIlkMaxLiquidationAmount(WSTETH_A, 15 * MILLION);


        // ------------------- MATIC-A Parameter Changes --------------------------
        // https://vote.makerdao.com/polling/QmdzwZyS

        DssExecLib.setIlkAutoLineParameters({
            _ilk:    MATIC_A,
            _amount: 35 * MILLION,
            _gap:    10 * MILLION,
            _ttl:    8 hours
        });


        // ------------------------------------------------------------------------
        // ----------------- Other cleanup changes --------------------------------
        // ------------------------------------------------------------------------

        DssExecLib.setIlkDebtCeiling({
            _ilk:    RWA006_A,
            _amount: 0
        });

        DssExecLib.decreaseGlobalDebtCeiling(20 * MILLION);

    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
