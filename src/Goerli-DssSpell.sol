// SPDX-FileCopyrightText: © 2020 Dai Foundation <www.daifoundation.org>
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
// Enable ABIEncoderV2 when onboarding collateral through `DssExecLib.addNewCollateral()`
// pragma experimental ABIEncoderV2;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

import { DssSpellCollateralAction } from "./Goerli-DssSpellCollateral.sol";

interface ERC20Like {
    function approve(address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
}

interface RwaUrnLike {
    function lock(uint256) external;
    function draw(uint256) external;
    function free(uint256) external;
    function wipe(uint256) external;
}

contract DssSpellAction is DssAction, DssSpellCollateralAction {

    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    address constant RWA_TOKEN_FAB = 0x8FCe002C320E85e4D8c111E6f46ee4CDb3eBc67E;

    uint256 constant RWA009_DRAW_AMOUNT = 25_000_000 * WAD;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmX2QMoM1SZq2XMoTbMak8pZP86Y2icpgPAKDjQg4r4YHn
    //

    //-----SF-001 wuz here
    // Adding new MKR vesting streams following repricing on https://forum.makerdao.com/t/mip40c3-sp48-strategic-finance-unit-mkr-compensation-sf-001/12060/11
    //

    address public immutable MCD_VEST_MKR_TREASURY = DssExecLib.getChangelogAddress("MCD_VEST_MKR_TREASURY");

    address constant SF_001_WALLET         = 0xf737C76D2B358619f7ef696cf3F94548fEcec379;

    address constant SF_001_VEST_01        = 0xcc81578d163a04ea8d2eae6904d0c8e61a84e1bb; // s
    address constant SF_001_VEST_02        = 0x31C01e90Edcf8602C1A18B2aE4e5A72D8DCE76bD; // a
    address constant SF_001_VEST_03        = 0x12b19C5857CF92AaE5e5e5ADc6350e25e4C902e9; // l
    address constant SF_001_VEST_04        = 0x61606beafca314347cD2c6325786d54582335566; // p
    address constant SF_001_VEST_05        = 0xbdAF0300c488c6E8a3e28788CaE9902143dF6AFe; // j

    uint256 constant AUG_05_2022 = 1659682800;
    uint256 constant AUG_05_2023 = 1691218800;
    uint256 constant AUG_05_2025 = 1754377200;

    // Math
    uint256 constant MILLION = 10**6;
    uint256 constant WAD = 10**18;


    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {
        wipeFromRWA009Urn();
        // ---------------------------------------------------------------------
        // Includes changes from the DssSpellCollateralAction
        onboardNewCollaterals();
        drawFromRWA009Urn();

        // Add RWA_TOKEN_FAB to changelog
        DssExecLib.setChangelogAddress("RWA_TOKEN_FAB", RWA_TOKEN_FAB);

        DssExecLib.setChangelogVersion("1.13.3");

        //-----SF-001 wuz here
        // Adding new MKR vesting streams following repricing on https://forum.makerdao.com/t/mip40c3-sp48-strategic-finance-unit-mkr-compensation-sf-001/12060/11
        //

        DssVestLike(MCD_VEST_MKR_TREASURY).restrict(
            DssVestLike(MCD_VEST_MKR_TREASURY).create(
                SF_001_VEST_01,  // Participant
                216.09 * 3 * WAD,       // Amount
                AUG_05_2022,     // Begin date
                3 * 365 days,    // Vest duration
                365 days,        // Cliff time
                SF_001_WALLET    // Manager
            )
        );

        DssVestLike(MCD_VEST_MKR_TREASURY).restrict(
            DssVestLike(MCD_VEST_MKR_TREASURY).create(
                SF_001_VEST_02,  // Participant
                216.09 * 3 * WAD,       // Amount
                AUG_05_2022,     // Begin date
                3 * 365 days,    // Vest duration
                365 days,        // Cliff time
                SF_001_WALLET    // Manager
            )
        );

        DssVestLike(MCD_VEST_MKR_TREASURY).restrict(
            DssVestLike(MCD_VEST_MKR_TREASURY).create(
                SF_001_VEST_03,  // Participant
                175.58 * 3 * WAD,       // Amount
                AUG_05_2022,     // Begin date
                3 * 365 days,    // Vest duration
                365 days,        // Cliff time
                SF_001_WALLET    // Manager
            )
        );

        DssVestLike(MCD_VEST_MKR_TREASURY).restrict(
            DssVestLike(MCD_VEST_MKR_TREASURY).create(
                SF_001_VEST_04,  // Participant
                27 * WAD,       // Amount
                AUG_05_2022,     // Begin date
                365 days,    // Vest duration
                365 days,        // Cliff time
                SF_001_WALLET    // Manager
            )
        );

        DssVestLike(MCD_VEST_MKR_TREASURY).restrict(
            DssVestLike(MCD_VEST_MKR_TREASURY).create(
                SF_001_VEST_05,  // Participant
                13.5 * WAD,       // Amount
                AUG_05_2022,     // Begin date
                365 days,    // Vest duration
                365 days,        // Cliff time
                SF_001_WALLET    // Manager
            )
        );


    }

    function wipeFromRWA009Urn() internal {
        // wipe DAI
        RwaUrnLike(RWA009_A_URN_OLD).wipe(RWA009_DRAW_AMOUNT);

        // free old RWA009 Token from the URN
        RwaUrnLike(RWA009_A_URN_OLD).free(1 * WAD);
    }

    function drawFromRWA009Urn() internal {
        // lock RWA009 Token in the URN
        ERC20Like(RWA009).approve(RWA009_A_URN, 1 * WAD);
        RwaUrnLike(RWA009_A_URN).lock(1 * WAD);

        // draw DAI to genesis address
        RwaUrnLike(RWA009_A_URN).draw(RWA009_DRAW_AMOUNT);
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
