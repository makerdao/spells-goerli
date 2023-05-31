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
import { CollateralOpts } from "dss-exec-lib/CollateralOpts.sol";
import "dss-interfaces/dss/IlkRegistryAbstract.sol";
import "dss-exec-lib/DssAction.sol";
// Enable ABIEncoderV2 when onboarding collateral through `DssExecLib.addNewCollateral()`
pragma experimental ABIEncoderV2;

interface Authorizable {
    function rely(address) external;
    function deny(address) external;
    function setAuthority(address) external;
}

contract DssSpellAction is DssAction {
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
    //    https://ipfs.io/ipfs/QmVp4mhhbwWGTfbh2BzwQB9eiBrQBKiqcPRZCaAxNUaar6
    //
    uint256 internal constant TWO_FIVE_PCT_RATE   = 1000000000782997609082909351;
    uint256 constant THOUSAND   = 10 ** 3;
    uint256 constant MILLION    = 10 ** 6;
    // --- DEPLOYED COLLATERAL ADDRESSES ---
    address internal constant USDT                 = 0xac0d203a8d9dD6EAf444d3DA95a0cfB3dcf9DBc9;
    address internal constant VAL_USDT             = 0xab6f09c3c3f0d25379690308fd63321bD655d218;
    address internal constant PIP_USDT             = 0x58b3586bF716e78D3036Af45A3d63a9fAd520f76;
    address internal constant MCD_JOIN_USDT_A      = 0xC186C13Eca0937697899018AF62B40460d3Cd148;
    address internal constant MCD_CLIP_USDT_A      = 0x812105Ff1A7546fB5160445E24b96fEf25980Fe8;
    address internal constant MCD_CLIP_CALC_USDT_A = 0xecAFd89A7bf2d878aBf3fE903C4e806d8284fd80;
    address internal constant ETH_FROM = 0x125fC0CcCDee5ac474062F6358d4d056b0430b84;

    function actions() public override {
        // ----------------------------- Collateral onboarding -----------------------------
        //  Add USDT-A as a new Vault Type
        //  Poll Link:   TODO
        //  Forum Post:  https://forum.makerdao.com/t/USDT-collateral-onboarding-risk-evaluation/18820
        CollateralOpts memory co = CollateralOpts({
            ilk:                   "USDT-D",
            gem:                   USDT,
            join:                  MCD_JOIN_USDT_A,
            clip:                  MCD_CLIP_USDT_A,
            calc:                  MCD_CLIP_CALC_USDT_A,
            pip:                   PIP_USDT,
            isLiquidatable:        true,
            isOSM:                 true,
            whitelistOSM:          true,
            ilkDebtCeiling:        100 * MILLION,
            minVaultAmount:        7500,
            maxLiquidationAmount:  25 * MILLION,
            liquidationPenalty:    1300,                // 13% penalty fee
            ilkStabilityFee:       TWO_FIVE_PCT_RATE,   // 1.5% stability fee
            startingPriceFactor:   12000,               // Auction price begins at 120% of oracle
            breakerTolerance:      5000,                // Allows for a 50% hourly price drop before disabling liquidations
            auctionDuration:       90 minutes,
            permittedDrop:         4000,                // 40% price drop before reset
            liquidationRatio:      10100,               // 175% collateralization
            kprFlatReward:         300,                 // 300 Dai
            kprPctReward:          10                   // 0.1%
        });

        DssExecLib.addNewCollateral(co);
        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_USDT_A, 130 seconds, 9900);
        DssExecLib.setIlkAutoLineParameters("USDT-D", 20 * MILLION, 3 * MILLION, 8 hours);
        IlkRegistryAbstract(DssExecLib.reg()).update("USDT-D");
        DssExecLib.setChangelogAddress("USDT", USDT);
        DssExecLib.setChangelogAddress("PIP_USDT", PIP_USDT);
        DssExecLib.setChangelogAddress("MCD_JOIN_USDT_D", MCD_JOIN_USDT_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_USDT_D", MCD_CLIP_USDT_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_USDT_D", MCD_CLIP_CALC_USDT_A);
        // Denying the ETH_FROM Address
        Authorizable(VAL_USDT).deny(ETH_FROM);
        Authorizable(PIP_USDT).deny(ETH_FROM);
        Authorizable(MCD_JOIN_USDT_A).deny(ETH_FROM);
        Authorizable(MCD_CLIP_USDT_A).deny(ETH_FROM);
        Authorizable(MCD_CLIP_CALC_USDT_A).deny(ETH_FROM);
    }
}
contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {
    }
}