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

import "dss-interfaces/dss/EndAbstract.sol";
import "dss-interfaces/dss/IlkRegistryAbstract.sol";
import "dss-interfaces/dss/FlashAbstract.sol";

contract DssSpellAction is DssAction, DssSpellCollateralOnboardingAction {

    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Math

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

    address constant MCD_END   = 0xb82F60bAf6980b9fE035A82cF6Acb770C06d3896;
    address constant MCD_CURE  = 0xFA5d993DdA243A57eefbbF86Cb3a1c817Dfc7e4E;
    address constant MCD_FLASH = 0xAa5F7d5b29Fa366BB04F6E4c39ACF569d5214075;

    address immutable MCD_VAT          = DssExecLib.vat();
    address immutable MCD_VOW          = DssExecLib.vow();
    address immutable MCD_CAT          = DssExecLib.cat();
    address immutable MCD_DOG          = DssExecLib.dog();
    address immutable MCD_SPOT         = DssExecLib.spotter();
    address immutable MCD_POT          = DssExecLib.pot();
    address immutable MCD_ESM          = DssExecLib.esm();
    address immutable ILK_REGISTRY     = DssExecLib.reg();
    address immutable MCD_END_OLD      = DssExecLib.end();
    address immutable MCD_FLASH_LEGACY = DssExecLib.getChangelogAddress("MCD_FLASH");

    function actions() public override {
        // ---------------------------------------------------------------------
        // Includes changes from the DssSpellCollateralOnboardingAction
        // onboardNewCollaterals();

        // -------------------------- Cure + New End ---------------------------
        require(EndAbstract(MCD_END_OLD).live() == 1, "system-is-caged");
        DssExecLib.setValue(MCD_END, "wait", EndAbstract(MCD_END_OLD).wait());
        DssExecLib.setContract(MCD_END, "cure", MCD_CURE);
        DssExecLib.authorize(MCD_CURE, MCD_END);

        require(MCD_VAT == EndAbstract(MCD_END_OLD).vat(), "sanity-error-vat");
        DssExecLib.setContract(MCD_END, "vat", MCD_VAT);
        DssExecLib.authorize(MCD_VAT, MCD_END);
        DssExecLib.deauthorize(MCD_VAT, MCD_END_OLD);

        require(MCD_VOW == EndAbstract(MCD_END_OLD).vow(), "sanity-error-vow");
        DssExecLib.setContract(MCD_END, "vow", MCD_VOW);
        DssExecLib.authorize(MCD_VOW, MCD_END);
        DssExecLib.deauthorize(MCD_VOW, MCD_END_OLD);

        require(MCD_CAT == EndAbstract(MCD_END_OLD).cat(), "sanity-error-cat");
        DssExecLib.setContract(MCD_END, "cat", MCD_CAT);
        DssExecLib.authorize(MCD_CAT, MCD_END);
        DssExecLib.deauthorize(MCD_CAT, MCD_END_OLD);

        require(MCD_DOG == EndAbstract(MCD_END_OLD).dog(), "sanity-error-dog");
        DssExecLib.setContract(MCD_END, "dog", MCD_DOG);
        DssExecLib.authorize(MCD_DOG, MCD_END);
        DssExecLib.deauthorize(MCD_DOG, MCD_END_OLD);

        require(MCD_SPOT == EndAbstract(MCD_END_OLD).spot(), "sanity-error-spot");
        DssExecLib.setContract(MCD_END, "spot", MCD_SPOT);
        DssExecLib.authorize(MCD_SPOT, MCD_END);
        DssExecLib.deauthorize(MCD_SPOT, MCD_END_OLD);

        require(MCD_POT == EndAbstract(MCD_END_OLD).pot(), "sanity-error-pot");
        DssExecLib.setContract(MCD_END, "pot", MCD_POT);
        DssExecLib.authorize(MCD_POT, MCD_END);
        DssExecLib.deauthorize(MCD_POT, MCD_END_OLD);

        DssExecLib.setContract(MCD_ESM, "end", MCD_END);
        DssExecLib.authorize(MCD_END, MCD_ESM);
        DssExecLib.deauthorize(MCD_END_OLD, MCD_ESM);

        bytes32[] memory ilks = IlkRegistryAbstract(ILK_REGISTRY).list();
        for (uint256 i = 0; i < ilks.length; i++) {
            bytes32 ilk = ilks[i];

            address xlip = IlkRegistryAbstract(ILK_REGISTRY).xlip(ilk);
            if (IlkRegistryAbstract(ILK_REGISTRY).class(ilks[i]) < 3) {
                DssExecLib.deauthorize(xlip, MCD_END_OLD);
                DssExecLib.authorize(xlip, MCD_END);
            }

            try DssExecLib.removeReaderFromWhitelist(IlkRegistryAbstract(ILK_REGISTRY).pip(ilk), MCD_END_OLD) {} catch {}
            try DssExecLib.addReaderToWhitelist(IlkRegistryAbstract(ILK_REGISTRY).pip(ilk), MCD_END) {} catch {}
        }

        // --------------------------- New DssFlash ----------------------------

        DssExecLib.authorize(MCD_VAT, MCD_FLASH);
        uint256 newMax = FlashAbstract(MCD_FLASH_LEGACY).max() / 2;
        DssExecLib.setValue(MCD_FLASH, "max", newMax);
        DssExecLib.setValue(MCD_FLASH_LEGACY, "max", newMax);

        // ----------------------------- Chainlog ------------------------------

        DssExecLib.setChangelogAddress("MCD_END", MCD_END);
        DssExecLib.setChangelogAddress("MCD_CURE", MCD_CURE);
        DssExecLib.setChangelogAddress("MCD_FLASH", MCD_FLASH);
        DssExecLib.setChangelogAddress("MCD_FLASH_LEGACY", MCD_FLASH_LEGACY);
        DssExecLib.setChangelogVersion("1.13.0");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
