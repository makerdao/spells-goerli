// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2021 Maker Ecosystem Growth Holdings, INC.
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
import "dss-interfaces/dapp/DSValueAbstract.sol";
import "dss-interfaces/dss/SpotAbstract.sol";
import "dss-interfaces/dss/DssAutoLineAbstract.sol";

interface Fileable {
    function file(bytes32,uint256) external;
}

contract DssSpellAction is DssAction {

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/TODO -q -O - 2>/dev/null)"
    string public constant override description = "Goerli Spell";

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    address constant MCD_JOIN_PSM_USDC_A       = 0xF2f86B76d1027f3777c522406faD710419C80bbB;
    address constant MCD_CLIP_PSM_USDC_A       = 0x8f570B146655Cd52173B0db2DDeb40B7b32c5A9C;
    address constant MCD_CLIP_CALC_PSM_USDC_A  = 0x6eB7f16842b13A1Fbb270Fc952Fb9a73D7c90a0e;
    address constant MCD_PSM_USDC_A            = 0xb480B8dD5A232Cb7B227989Eacda728D1F247dB6;
    bytes32 constant ILK_PSM_USDC_A            = "PSM-USDC-A";

    uint256 constant BILLION = 10 ** 9;
    uint256 constant WAD     = 10 ** 18;
    uint256 constant RAY     = 10 ** 27;
    uint256 constant RAD     = 10 ** 45;

    function actions() public override {
        address USDC = DssExecLib.getChangelogAddress("USDC");
        address PIP_USDC = DssExecLib.getChangelogAddress("PIP_USDC");

        // Fix price stables
        DSValueAbstract(PIP_USDC).poke(bytes32(WAD));
        DSValueAbstract(DssExecLib.getChangelogAddress("PIP_TUSD")).poke(bytes32(WAD));
        DSValueAbstract(DssExecLib.getChangelogAddress("PIP_PAXUSD")).poke(bytes32(WAD));
        DSValueAbstract(DssExecLib.getChangelogAddress("PIP_GUSD")).poke(bytes32(WAD));

        DssExecLib.updateCollateralPrice("USDC-A");
        DssExecLib.updateCollateralPrice("USDC-B");
        DssExecLib.updateCollateralPrice("TUSD-A");
        DssExecLib.updateCollateralPrice("PAXUSD-A");
        DssExecLib.updateCollateralPrice("GUSD-A");
        //

        // Add PSM_USDC_A
        DssExecLib.authorize(MCD_JOIN_PSM_USDC_A, MCD_PSM_USDC_A);

        DssExecLib.addNewCollateral(CollateralOpts({
            ilk: ILK_PSM_USDC_A,
            gem: USDC,
            join: MCD_JOIN_PSM_USDC_A,
            clip: MCD_CLIP_PSM_USDC_A,
            calc: MCD_CLIP_CALC_PSM_USDC_A,
            pip: PIP_USDC,
            isLiquidatable: false,
            isOSM: false,
            whitelistOSM: false,
            ilkDebtCeiling: 0,
            minVaultAmount: 0,
            maxLiquidationAmount: 0,
            liquidationPenalty: 1300,
            ilkStabilityFee: RAY,
            startingPriceFactor: 10500,
            breakerTolerance: 9500,
            auctionDuration: 220 minutes,
            permittedDrop: 9000,
            liquidationRatio: 10000,
            kprFlatReward: 300,
            kprPctReward: 10
        }));

        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_PSM_USDC_A, 120 seconds, 9990);
        Fileable(MCD_PSM_USDC_A).file("tin", WAD / 1000);

        DssExecLib.setIlkAutoLineParameters(ILK_PSM_USDC_A, 10 * BILLION, 1 * BILLION, 24 hours);
        DssAutoLineAbstract(DssExecLib.autoLine()).exec(ILK_PSM_USDC_A);

        DssExecLib.setChangelogAddress("MCD_JOIN_PSM_USDC_A", MCD_JOIN_PSM_USDC_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_PSM_USDC_A", MCD_CLIP_PSM_USDC_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_PSM_USDC_A", MCD_CLIP_CALC_PSM_USDC_A);
        DssExecLib.setChangelogAddress("MCD_PSM_USDC_A", MCD_PSM_USDC_A);
        //
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
