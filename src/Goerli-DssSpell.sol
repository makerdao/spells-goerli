// SPDX-License-Identifier: AGPL-3.0-or-later
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

contract DssSpellAction is DssAction {

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/TODO -q -O - 2>/dev/null)"
    string public constant override description = "Goerli Spell";

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmefQMseb3AiTapiAKKexdKHig8wroKuZbmLtPLv4u2YwW
    //
    uint256 constant ONE_PCT_RATE = 1000000000315522921573372069;

    address constant LERP_FAB = 0xbBD821c291c492c40Db2577D9b6E5B1bdAEBD207;

    // Math
    uint256 constant THOUSAND = 10 ** 3;
    uint256 constant MILLION  = 10 ** 6;
    uint256 constant BILLION  = 10 ** 9;
    uint256 constant WAD      = 10 ** 18;
    uint256 constant RAY      = 10 ** 27;
    uint256 constant RAD      = 10 ** 45;

    address constant GUNI                   = 0xc5D83e829Ecdce4d67645EE1a1317451e0b4c68d;
    address constant MCD_JOIN_GUNI_A        = 0xFBF4e3bB9B86d24F91Da185E6F4C8D903Fb63C86;
    address constant MCD_CLIP_GUNI_A        = 0xFb98C5A49eDd0888e85f6d2CCc7695b5202A6B32;
    address constant MCD_CLIP_CALC_GUNI_A   = 0x4652E3a6b4850a0fE50E60B0ac72aBd74199D973;
    address constant PIP_GUNI               = 0x7B3a8452eED8Af27EE2c8a9b826CCfd3b7760461;

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {

        // Add LerpFactory to ChainLog
        DssExecLib.setChangelogAddress("LERP_FAB", LERP_FAB);

        // Offboard KNC Legacy Token
        // https://vote.makerdao.com/polling/QmQ4Jotm?network=mainnet#poll-detail
        DssExecLib.setIlkLiquidationPenalty("KNC-A", 0);
        DssExecLib.linearInterpolation({
            _name:      "KNC Offboarding",
            _target:    DssExecLib.spotter(),
            _ilk:       "KNC-A",
            _what:      "mat",
            _startTime: block.timestamp,
            _start:       175 * RAY / 100,
            _end:       5_000 * RAY / 100,
            _duration:  60 days
        });

        // Adopt the Debt Ceiling Instant Access Module (DC-IAM) for PSM-PAX-A
        // https://vote.makerdao.com/polling/QmbGPgxo?network=mainnet#poll-detail
        DssExecLib.setIlkAutoLineParameters({
            _ilk:    "PSM-PAX-A",
            _amount: 500 * MILLION,
            _gap:     50 * MILLION,
            _ttl:    24 hours
        });
        DssExecLib.setIlkAutoLineParameters({
            _ilk:    "PSM-USDC-A",
            _amount:  10 * BILLION,
            _gap:    950 * MILLION,
            _ttl:    24 hours
        });

        // G-UNI DAI/USDC
        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_GUNI_A, 90 seconds, 9900);

        CollateralOpts memory GUNI_A = CollateralOpts({
            ilk:                   "GUNIV3DAIUSDC1-A",
            gem:                   GUNI,
            join:                  MCD_JOIN_GUNI_A,
            clip:                  MCD_CLIP_GUNI_A,
            calc:                  MCD_CLIP_CALC_GUNI_A,
            pip:                   PIP_GUNI,
            isLiquidatable:        false,
            isOSM:                 true,
            whitelistOSM:          false,
            ilkDebtCeiling:        3 * MILLION,
            minVaultAmount:        10 * THOUSAND,
            maxLiquidationAmount:  5 * MILLION,
            liquidationPenalty:    1300,
            ilkStabilityFee:       ONE_PCT_RATE,
            startingPriceFactor:   10500,
            breakerTolerance:      9500, // Allows for a 5% hourly price drop before disabling liquidations
            auctionDuration:       220 minutes,
            permittedDrop:         9000,
            liquidationRatio:      10500,
            kprFlatReward:         300,
            kprPctReward:          10 // 0.1%
        });

        DssExecLib.addNewCollateral(GUNI_A);
        DssExecLib.setIlkAutoLineParameters("GUNIV3DAIUSDC1-A", 10 * MILLION, 10 * MILLION, 8 hours);

        DssExecLib.setChangelogAddress("GUNIV3DAIUSDC1", GUNI);
        DssExecLib.setChangelogAddress("MCD_JOIN_GUNIV3DAIUSDC1_A", MCD_JOIN_GUNI_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_GUNIV3DAIUSDC1_A", MCD_CLIP_GUNI_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_GUNIV3DAIUSDC1_A", MCD_CLIP_CALC_GUNI_A);
        DssExecLib.setChangelogAddress("PIP_GUNIV3DAIUSDC1", PIP_GUNI);
    }

}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
