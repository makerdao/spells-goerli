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
import "dss-interfaces/dss/IlkRegistryAbstract.sol";

interface FaucetLike {
    function setAmt(address,uint256) external;
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

    address constant MATIC                 = 0x5B3b6CF665Cc7B4552F4347623a2A9E00600CBB5;
    address constant MCD_JOIN_MATIC_A      = 0xeb680839564F0F9bFB96fE2dF47a31cE31689e63;
    address constant MCD_CLIP_MATIC_A      = 0x2082c825b5311A2612c12e6DaF7EFa3Fb37BACbD;
    address constant MCD_CLIP_CALC_MATIC_A = 0xB2dF4Ed2f6a665656CE3405E8f75b9DE8A6E24e9;
    address constant PIP_MATIC             = 0xDe112F61b823e776B3439f2F39AfF41f57993045;
    uint256 constant FAUCET_AMT            = 100 * THOUSAND * WAD;

    address constant VOTE_DELEGATE_PROXY_FACTORY = 0xE2d249AE3c156b132C40D07bd4d34e73c1712947;

    uint256 constant THOUSAND   = 10**3;
    uint256 constant MILLION    = 10**6;
    uint256 constant WAD        = 10**18;

    function actions() public override {
        // Add MATIC-A
        // values taken from https://forum.makerdao.com/t/matic-collateral-onboarding-risk-evaluation/9069
        DssExecLib.addNewCollateral(CollateralOpts({
            ilk:                   "MATIC-A",
            gem:                   MATIC,
            join:                  MCD_JOIN_MATIC_A,
            clip:                  MCD_CLIP_MATIC_A,
            calc:                  MCD_CLIP_CALC_MATIC_A,
            pip:                   PIP_MATIC,
            isLiquidatable:        true,
            isOSM:                 true,
            whitelistOSM:          true,
            ilkDebtCeiling:        3 * MILLION,
            minVaultAmount:        10 * THOUSAND,
            maxLiquidationAmount:  3 * MILLION,
            liquidationPenalty:    1300,
            ilkStabilityFee:       1000000000937303470807876289,
            startingPriceFactor:   13000,
            breakerTolerance:      5000, // Allows for a 50% hourly price drop before disabling liquidations
            auctionDuration:       140 minutes,
            permittedDrop:         4000,
            liquidationRatio:      17500,
            kprFlatReward:         300,
            kprPctReward:          10 // 0.1%
        }));

        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_MATIC_A, 90 seconds, 9900);

        DssExecLib.setIlkAutoLineParameters("MATIC-A", 10 * MILLION, 3 * MILLION, 8 hours);

        IlkRegistryAbstract(DssExecLib.reg()).update("MATIC-A");

        FaucetLike(DssExecLib.getChangelogAddress("FAUCET")).setAmt(MATIC, FAUCET_AMT);

        DssExecLib.setChangelogAddress("MATIC", MATIC);
        DssExecLib.setChangelogAddress("PIP_MATIC", PIP_MATIC);
        DssExecLib.setChangelogAddress("MCD_JOIN_MATIC_A", MCD_JOIN_MATIC_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_MATIC_A", MCD_CLIP_MATIC_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_MATIC_A", MCD_CLIP_CALC_MATIC_A);

        // Add VOTE_DELEGATE_PROXY_FACTORY to chainlog
        DssExecLib.setChangelogAddress("VOTE_DELEGATE_PROXY_FACTORY", VOTE_DELEGATE_PROXY_FACTORY);
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
