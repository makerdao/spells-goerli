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
    // https://ipfs.io/ipfs/QmVp4mhhbwWGTfbh2BzwQB9eiBrQBKiqcPRZCaAxNUaar6

    // --- Math ---
    uint256 constant MILLION                  = 10 ** 6;

    uint256 constant FIFTY_PCT_RATE           = 1000000012857214317438491659;

    // RWA007-A
    bytes32 constant RWA007_A                 = "RWA007-A";
    uint256 constant RWA007_A_AUTOLINE_AMOUNT = 500 * MILLION;
    uint256 constant RWA007_A_AUTOLINE_GAP    = 100 * MILLION;
    uint256 constant RWA007_A_AUTOLINE_TTL    = 1 weeks; 

    // MANA-A
    bytes32 constant MANA_A                   = "MANA-A";
    uint256 constant MANA_A_AUTOLINE_AMOUNT   = 3 * MILLION;
    uint256 constant MANA_A_CHOP              = 3000; // 30%

    // RETH-A
    bytes32 constant RETH_A                 = "RETH-A";
    uint256 constant RETH_A_AUTOLINE_AMOUNT = 5 * MILLION;
    uint256 constant RETH_A_AUTOLINE_GAP    = 3 * MILLION;
    uint256 constant RETH_A_AUTOLINE_TTL    = 8 hours;

    function collateralAction() internal {
        onboardCollaterals();
        updateCollaterals();
        offboardCollaterals();
    }

    function onboardCollaterals() internal {
        // ----------------------------- Collateral onboarding -----------------------------
    }

    function updateCollaterals() internal {
        // ------------------------------- Collateral updates -------------------------------
        
        // RWA007-A param changes:
        // - increase DC to 500m
        // - increase autoline `gap` to 100m
        //
        // https://vote.makerdao.com/polling/QmSfMtTM#poll-detail
        DssExecLib.setIlkAutoLineParameters(
            RWA007_A,
            RWA007_A_AUTOLINE_AMOUNT,
            RWA007_A_AUTOLINE_GAP,
            RWA007_A_AUTOLINE_TTL
        );

        // MANA-A param changes:
        // - decrease line to 3m
        // - increase SF to 50%
        // - increase liquidation penalty to 30% from current 13%
        //
        // https://forum.makerdao.com/t/mana-a-intermediate-parameter-change-proposal/18727
        DssExecLib.setIlkAutoLineDebtCeiling(MANA_A, MANA_A_AUTOLINE_AMOUNT);
        DssExecLib.setIlkStabilityFee(MANA_A, FIFTY_PCT_RATE, true);
        DssExecLib.setIlkLiquidationPenalty(MANA_A, MANA_A_CHOP);

        // set rETH autoline:
        // - line 5m
        // - gap 3m
        // - ttl 8h
        //
        //  https://vote.makerdao.com/polling/QmfMswF2#poll-detail
        DssExecLib.setIlkAutoLineParameters(
            RETH_A,
            RETH_A_AUTOLINE_AMOUNT,
            RETH_A_AUTOLINE_GAP,
            RETH_A_AUTOLINE_TTL
        );
    }

    function offboardCollaterals() internal {
        // ----------------------------- Collateral offboarding -----------------------------
    }
}
