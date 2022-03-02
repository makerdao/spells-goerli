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
pragma experimental ABIEncoderV2;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

import { DssSpellCollateralOnboardingAction } from "./Goerli-DssSpellCollateralOnboarding.sol";

interface CharterLike {
    function setImplementation(address) external;
    function file(bytes32, bytes32, uint256) external;
    function file(bytes32, address, bytes32, uint256) external;
}

contract DssSpellAction is DssAction, DssSpellCollateralOnboardingAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    address constant MCD_CHARTER_IMP           = 0xf6a9bD36553208ee02049Dc8A9c44919383C9a6b;

    // The below addresses are given for documentation purposes:
    address constant CDP_REGISTRY              = 0x0636E6878703E30aB11Ba13A68C6124d9d252e6B;
    address constant PROXY_ACTIONS_CHARTER     = 0xfFb896D7BEf704DF73abc9A2EBf295CE236c5919;
    address constant PROXY_ACTIONS_END_CHARTER = 0xDAdE5a1bAC92c539B886eeC82738Ff26b66Dc484;

    address constant OAZO_DS_PROXY = 0xDdA54E31B7586153D72A2AC1bAFaC5B9C21fc45C;

    // Turn office hours off
    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {

        // ---------------------------------------------------------------------------------
        onboardNewCollaterals();

        CharterLike(MCD_CHARTER).setImplementation(MCD_CHARTER_IMP);

        CharterLike(MCD_CHARTER).file("INST-ETH-A", "gate", 1);
        CharterLike(MCD_CHARTER).file("INST-ETH-A", OAZO_DS_PROXY, "nib", 1 * WAD / 100); // 1%
        CharterLike(MCD_CHARTER).file("INST-ETH-A", OAZO_DS_PROXY, "peace", 150 * RAY / 100); // 150%
        CharterLike(MCD_CHARTER).file("INST-ETH-A", OAZO_DS_PROXY, "uline", 900 * MILLION * RAD);

        CharterLike(MCD_CHARTER).file("INST-WBTC-A", "gate", 1);
        CharterLike(MCD_CHARTER).file("INST-WBTC-A", OAZO_DS_PROXY, "nib", 1 * WAD / 100); // 1%
        CharterLike(MCD_CHARTER).file("INST-WBTC-A", OAZO_DS_PROXY, "peace", 150 * RAY / 100); // 150%
        CharterLike(MCD_CHARTER).file("INST-WBTC-A", OAZO_DS_PROXY, "uline", 600 * MILLION * RAD);
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
