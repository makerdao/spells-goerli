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

interface DssVestLike {
    function cap() external view returns (uint256);
    function ids() external view returns (uint256);
    function create(address, uint256, uint256, uint256, uint256, address) external returns (uint256);
    function file(bytes32, uint256) external;
    function rely(address) external;
}

contract DssSpellAction is DssAction, DssSpellCollateralOnboardingAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    address constant MCD_VEST_DAI = 0x7520970Bd0f63D4EA4AA5E4Be05F22e0b8b09BD4;

    uint256 constant WAD = 10 ** 18;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmPgPVrVxDCGyNR5rGp9JC5AUxppLzUAqvncRJDcxQnX1u
    //

    // --- Rates ---
    // uint256 constant FOUR_FIVE_PCT_RATE      = 1000000001395766281313196627;

    // Turn office hours off
    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {
        // ---------------------------------------------------------------------
        // Includes changes from the DssSpellCollateralOnboardingAction
        // onboardNewCollaterals();

        // Rely ESM in MCD_VEST_DAI_LEGACY
        address MCD_VEST_DAI_LEGACY = DssExecLib.getChangelogAddress("MCD_VEST_DAI");
        DssVestLike(MCD_VEST_DAI_LEGACY).rely(DssExecLib.getChangelogAddress("MCD_ESM"));

        // Add new MCD_VEST_DAI
        require(DssVestLike(MCD_VEST_DAI).ids() == 0, "DssSpell/non-empty-vesting-contract");
        DssExecLib.authorize(DssExecLib.vat(), MCD_VEST_DAI);
        DssVestLike(MCD_VEST_DAI).file("cap", DssVestLike(MCD_VEST_DAI_LEGACY).cap());

        DssExecLib.setChangelogAddress("MCD_VEST_DAI", MCD_VEST_DAI);
        DssExecLib.setChangelogAddress("MCD_VEST_DAI_LEGACY", MCD_VEST_DAI_LEGACY);
        DssExecLib.setChangelogVersion("1.12.0");

        // Test DAI payment in new vesting contract
        DssVestLike(MCD_VEST_DAI).create(address(this), WAD, block.timestamp - 1 days, 1 days, 0, address(0));
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
