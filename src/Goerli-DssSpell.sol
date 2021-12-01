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
import { VatAbstract, LerpFactoryAbstract, SpotAbstract, IlkRegistryAbstract, DogAbstract } from "dss-interfaces/Interfaces.sol";

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
    uint256 constant ZERO_ONE_PCT_RATE       = 1000000000031693947650284507;
    uint256 constant ONE_PCT_RATE            = 1000000000315522921573372069;
    uint256 constant ONE_FIVE_PCT_RATE       = 1000000000472114805215157978;
    uint256 constant TWO_PCT_RATE            = 1000000000627937192491029810;
    uint256 constant TWO_FIVE_PCT_RATE       = 1000000000782997609082909351;
    uint256 constant TWO_SEVEN_FIVE_PCT_RATE = 1000000000860244400048238898;
    uint256 constant THREE_PCT_RATE          = 1000000000937303470807876289;
    uint256 constant FOUR_PCT_RATE           = 1000000001243680656318820312;
    uint256 constant SIX_PCT_RATE            = 1000000001847694957439350562;
    uint256 constant SIX_FIVE_PCT_RATE       = 1000000001996917783620820123;

    // --- Math ---
    uint256 constant MILLION = 10 ** 6;
    uint256 constant BILLION = 10 ** 9;
    uint256 constant RAD     = 10 ** 45;

    function _add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "DssSpellAction-add-overflow");
    }
    function _sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "DssSpellAction-sub-underflow");
    }

    function actions() public override {

        // --- 2021-12-03 Weekly Executive ---

        // ----------------------------- Rates updates -----------------------------
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
        DssExecLib.setIlkAutoLineParameters("WBTC-A", 2 * BILLION, 80 * MILLION, 6 hours);

        // Increase the Dust Parameter from 30,000 DAI to 40,000 DAI for the ETH-B
        DssExecLib.setIlkMinVaultAmount("ETH-B", 40_000);

        // Increase the Dust Parameter from 10,000 DAI to 15,000 DAI for all vault-types excluding ETH-B and ETH-C
        DssExecLib.setIlkMinVaultAmount("ETH-A", 15_000);
        // DssExecLib.setIlkMinVaultAmount("USDC-A", 15_000);
        // DssExecLib.setIlkMinVaultAmount("USDC-B", 15_000);
        // DssExecLib.setIlkMinVaultAmount("TUSD-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("WBTC-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("WBTC-B", 15_000);
        DssExecLib.setIlkMinVaultAmount("WBTC-C", 15_000);
        DssExecLib.setIlkMinVaultAmount("KNC-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("MANA-A", 15_000);
        // DssExecLib.setIlkMinVaultAmount("USDT-A", 15_000);
        // DssExecLib.setIlkMinVaultAmount("PAXUSD-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("LINK-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("YFI-A", 15_000);
        // DssExecLib.setIlkMinVaultAmount("GUSD-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNI-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("RENBTC-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("MATIC-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2DAIETH-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2WBTCETH-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2USDCETH-A", 15_000);
        // DssExecLib.setIlkMinVaultAmount("UNIV2DAIUSDC-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2ETHUSDT-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2UNIETH-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2WBTCDAI-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2AAVEETH-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2DAIUSDT-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("GUNIV3DAIUSDC1-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("WSTETH-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("WBTC-B", 15_000);
        DssExecLib.setIlkMinVaultAmount("WBTC-C", 15_000);

        // Changelog version
        DssExecLib.setChangelogVersion("1.9.12"); // ?????
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
