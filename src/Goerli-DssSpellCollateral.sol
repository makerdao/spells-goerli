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
    //

    // --- Math ---
    uint256 constant MILLION = 10 ** 6;

    bytes32 constant RWA007_A                 = "RWA007-A";
    uint256 constant RWA007_A_AUTOLINE_AMOUNT = 250 * MILLION;
    uint256 constant RWA007_A_AUTOLINE_GAP    =  50 * MILLION;
    uint256 constant RWA007_A_AUTOLINE_TTL    = 1 weeks; 


    function onboardCollaterals() internal {
        // ----------------------------- Collateral onboarding -----------------------------
    }

    function offboardCollaterals() internal {
        // ----------------------------- Collateral offboarding -----------------------------
    }

    function updateCollaterals() internal {
        // ------------------------------- Collateral updates -------------------------------

        // Enable autoline for MIP65
        // https://forum.makerdao.com/t/rwa007-mip65-monetalis-clydesdale-ces-domain-team-assessment/17787
        DssExecLib.setIlkAutoLineParameters(
            RWA007_A,
            RWA007_A_AUTOLINE_AMOUNT,
            RWA007_A_AUTOLINE_GAP,
            RWA007_A_AUTOLINE_TTL
        );
    }
}
