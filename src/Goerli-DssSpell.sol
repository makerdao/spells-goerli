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
pragma experimental ABIEncoderV2;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

import { DssSpellCollateralOnboardingAction } from "./Goerli-DssSpellCollateralOnboarding.sol";

contract DssSpellAction is DssAction, DssSpellCollateralOnboardingAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Turn office hours off
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

    address constant NEW_MCD_ESM = address(1); // TODO
    bytes32 constant MCD_ESM = "MCD_ESM";

    // Math
    uint256 constant MILLION = 10**6;

    function actions() public override {


        // ---------------------------------------------------------------------
        // Includes changes from the DssSpellCollateralOnboardingAction
        // onboardNewCollaterals();


        address OLD_MCD_ESM = DssExecLib.getChangelogAddress(MCD_ESM);

        address addr;

        // MCD_END
        addr = DssExecLib.getChangelogAddress("MCD_END");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_ETH_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_ETH_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_ETH_B
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_ETH_B");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_ETH_C
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_ETH_C");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_BAT_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_BAT_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_USDC_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_USDC_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_USDC_B
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_USDC_B");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_TUSD_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_TUSD_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_WBTC_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_WBTC_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_ZRX_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_ZRX_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_KNC_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_KNC_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_MANA_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_MANA_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_USDT_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_USDT_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_PAXUSD_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_PAXUSD_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_COMP_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_COMP_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_LRC_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_LRC_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_LINK_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_LINK_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_BAL_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_BAL_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_YFI_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_YFI_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_GUSD_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_GUSD_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_UNI_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_UNI_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_RENBTC_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_RENBTC_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_AAVE_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_AAVE_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_PSM_USDC_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_PSM_USDC_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_MATIC_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_MATIC_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_UNIV2DAIETH_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_UNIV2DAIETH_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_UNIV2WBTCETH_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_UNIV2WBTCETH_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_UNIV2USDCETH_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_UNIV2USDCETH_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_UNIV2DAIUSDC_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_UNIV2DAIUSDC_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_UNIV2ETHUSDT_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_UNIV2ETHUSDT_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_UNIV2LINKETH_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_UNIV2LINKETH_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_UNIV2UNIETH_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_UNIV2UNIETH_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_UNIV2WBTCDAI_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_UNIV2WBTCDAI_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_UNIV2AAVEETH_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_UNIV2AAVEETH_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_UNIV2DAIUSDT_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_UNIV2DAIUSDT_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_PSM_PAX_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_PSM_PAX_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_GUNIV3DAIUSDC1_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_GUNIV3DAIUSDC1_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_WSTETH_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_WSTETH_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_WBTC_B
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_WBTC_B");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_WBTC_C
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_WBTC_C");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_PSM_GUSD_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_PSM_GUSD_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_CLIP_GUNIV3DAIUSDC2_A
        addr = DssExecLib.getChangelogAddress("MCD_CLIP_GUNIV3DAIUSDC2_A");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        // MCD_VAT
        addr = DssExecLib.getChangelogAddress("MCD_VAT");
        DssExecLib.deauthorize(addr, OLD_MCD_ESM);
        DssExecLib.authorize(addr, NEW_MCD_ESM);

        DssExecLib.setChangelogAddress(MCD_ESM, NEW_MCD_ESM);
        DssExecLib.setChangelogVersion("1.10.0");



    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
