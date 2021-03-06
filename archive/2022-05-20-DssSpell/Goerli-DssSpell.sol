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
// pragma experimental ABIEncoderV2;
import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

import { DssSpellCollateralOnboardingAction } from "./Goerli-DssSpellCollateralOnboarding.sol";

contract DssSpellAction is DssAction, DssSpellCollateralOnboardingAction {

    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Math
    uint256 constant WAD = 10 ** 18;
    uint256 constant RAD = 10 ** 45;
    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmPgPVrVxDCGyNR5rGp9JC5AUxppLzUAqvncRJDcxQnX1u
    //

    // Turn office hours off
    function officeHours() public override returns (bool) {
        return false;
    }

    address immutable MCD_FLAP = DssExecLib.flap();
    address immutable MCD_ESM = DssExecLib.esm();

    // No Transfer on Goerli
    // address immutable MCD_GOV = DssExecLib.mkr();
    // address immutable DUX_WALLET =        ;
    // address immutable SIDESTREAM_WALLET = ;

    function actions() public override {
        // ---------------------------------------------------------------------
        // Includes changes from the DssSpellCollateralOnboardingAction
        // onboardNewCollaterals();

        // ---------------------------- Lid for Flap ---------------------------
        DssExecLib.setValue(MCD_FLAP, "lid", 30_000 * RAD);

        // ------------------------------ ESM Min ------------------------------
        DssExecLib.setValue(MCD_ESM, "min", 150_000 * WAD);

        // ---------------------------- Transfer MKR ---------------------------
        // No Transfer on Goerli

    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
