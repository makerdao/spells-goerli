// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Copyright (C) 2021-2022 Dai Foundation
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
// Enable ABIEncoderV2 when onboarding collateral
//pragma experimental ABIEncoderV2;
import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

import { DssSpellCollateralOnboardingAction } from "./Goerli-DssSpellCollateralOnboarding.sol";

interface RegistryLike {
    function list() external view returns (bytes32[] memory);
    function pip(bytes32 ilk) external view returns (address);
    function class(bytes32 ilk) external view returns (uint256);
}

contract DssSpellAction is DssAction, DssSpellCollateralOnboardingAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Math
    uint256 constant internal MILLION  = 10 ** 6;
    uint256 constant internal BILLION  = 10 ** 9;

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
    uint256 constant ZERO_ZERO_FIVE_PCT_RATE = 1000000000015850933588756013;
    uint256 constant TWO_TWO_FIVE_PCT_RATE   = 1000000000705562181084137268;
    uint256 constant THREE_TWO_FIVE_PCT_RATE = 1000000001014175731521720677;
    uint256 constant FOUR_FIVE_PCT_RATE      = 1000000001395766281313196627;

    address constant public ORACLE_WALLET01 = 0x4D6fbF888c374D7964D56144dE0C0cFBd49750D3;
    address constant public ORACLE_WALLET02 = 0x1f42e41A34B71606FcC60b4e624243b365D99745;

    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {
        // ---------------------------------------------------------------------
        // Includes changes from the DssSpellCollateralOnboardingAction
        // onboardNewCollaterals();


        // ------------------------- Rates Updates -----------------------------
        // https://vote.makerdao.com/polling/QmdS8mCx#poll-detail

        // Decrease the WSTETH-A Stability Fee from 2.5% to 2.25%
        DssExecLib.setIlkStabilityFee("WSTETH-A", TWO_TWO_FIVE_PCT_RATE, true);

        // Decrease the CRVV1ETHSTETH-A Stability Fee from 3.5% to 2.25%
        // NOTE: ignore in goerli
        // DssExecLib.setIlkStabilityFee("CRVV1ETHSTETH-A", TWO_TWO_FIVE_PCT_RATE, true);

        // Decrease the WBTC-A Stability Fee from 3.75% to 3.25%
        DssExecLib.setIlkStabilityFee("WBTC-A", THREE_TWO_FIVE_PCT_RATE, true);

        // Decrease the WBTC-B Stability Fee from 5.0% to 4.5%
        DssExecLib.setIlkStabilityFee("WBTC-B", FOUR_FIVE_PCT_RATE, true);

        // Decrease the GUNIV3DAIUSDC1-A Stability Fee from 0.1% to 0%
        DssExecLib.setIlkStabilityFee("GUNIV3DAIUSDC1-A", ZERO_PCT_RATE, true);

        // Decrease the GUNIV3DAIUSDC2-A Stability Fee from 0.25% to 0.05%
        DssExecLib.setIlkStabilityFee("GUNIV3DAIUSDC2-A", ZERO_ZERO_FIVE_PCT_RATE, true);


        // ---------------------- Debt Ceiling Updates -------------------------

        // https://forum.makerdao.com/t/immediate-short-term-parameter-changes-proposal-for-crvv1ethsteth-a-dc-and-gap-increase/14476 
        // Increase the CRVV1ETHSTETH-A Maximum Debt Ceiling from 3 million DAI to 5 million DAI.
        // NOTE: ignore in goerli
        // DssExecLib.setIlkAutoLineDebtCeiling("CRVV1ETHSTETH-A", 5 * MILLION);

        // https://vote.makerdao.com/polling/QmdS8mCx#poll-detail
        // Increase the GUNIV3DAIUSDC1-A Maximum Debt Ceiling from 100 million DAI to 750 million DAI.
        // Increase the GUNIV3DAIUSDC1-A gap from 10 million to 50 million
        // Leave the GUNIV3DAIUSDC1-A ttl the same
        DssExecLib.setIlkAutoLineParameters("GUNIV3DAIUSDC1-A", 750 * MILLION, 50 * MILLION, 8 hours);

        // https://vote.makerdao.com/polling/QmdS8mCx#poll-detail
        // Increase the GUNIV3DAIUSDC2-A Maximum Debt Ceiling from 750 million DAI to 1 billion DAI.
        DssExecLib.setIlkAutoLineDebtCeiling("GUNIV3DAIUSDC2-A", 1 * BILLION);


        // ----------------------- Target Borrow Rates -------------------------
        // https://vote.makerdao.com/polling/QmdS8mCx#poll-detail 

        // Increase the DIRECT-AAVEV2-DAI target borrow rate from 2.85% to 3.5%
        // NOTE: ignore in goerli
        // DssExecLib.setD3MTargetInterestRate(DssExecLib.getChangelogAddress("MCD_JOIN_DIRECT_AAVEV2_DAI"), 350); // 3.5%


        // ------------------------ OSM auth updates ---------------------------
        // Adds two oracle wallets to all the OSMs
        // https://discord.com/channels/893112320329396265/897479589171986434/960938185800683580
        bytes32[] memory ilks = RegistryLike(DssExecLib.reg()).list();
        for(uint256 i = 0; i < ilks.length; i++) {
            uint256 class = RegistryLike(DssExecLib.reg()).class(ilks[i]);
            if (class != 1) { continue; }

            address pip = RegistryLike(DssExecLib.reg()).pip(ilks[i]);
            // skip USDC, TUSD, PAXUSD, GUSD
            if (pip == 0x838212865E2c2f4F7226fCc0A3EFc3EB139eC661 ||
                pip == 0x0ce19eA2C568890e63083652f205554C927a0caa ||
                pip == 0xdF8474337c9D3f66C0b71d31C7D3596E4F517457 ||
                pip == 0x57A00620Ba1f5f81F20565ce72df4Ad695B389d7) {
                continue;
            }

            DssExecLib.authorize(pip, ORACLE_WALLET01);
            DssExecLib.authorize(pip, ORACLE_WALLET02);
        }
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
