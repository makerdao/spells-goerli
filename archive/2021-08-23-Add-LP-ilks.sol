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
import "dss-interfaces/dss/MedianAbstract.sol";
import "dss-interfaces/dss/LPOsmAbstract.sol";
import "dss-interfaces/dss/IlkRegistryAbstract.sol";

interface FaucetLike {
    function setAmt(address,uint256) external;
}

contract DssSpellAction is DssAction {

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/TODO -q -O - 2>/dev/null)"
    string public constant override description = "Goerli Spell";

    address constant UNIV2DAIETH                    = 0x5dD9dec52a16d4d1Df10a66ac71d4731c9Dad984;
    address constant PIP_UNIV2DAIETH                = 0x044c9aeD56369aA3f696c898AEd0C38dC53c6C3D;
    address constant MCD_JOIN_UNIV2DAIETH_A         = 0x66931685b532CB4F31abfe804d2408dD34Cd419D;
    address constant MCD_CLIP_UNIV2DAIETH_A         = 0x76a4Ee8acEAAF7F92455277C6e10471F116ffF2c;
    address constant MCD_CLIP_CALC_UNIV2DAIETH_A    = 0x7DCA9CAE2Dc463eBBF05341727FB6ed181D690c2;
    address constant UNIV2WBTCETH                   = 0x7883a92ac3e914F3400e8AE6a2FF05E6BA4Bd403;
    address constant PIP_UNIV2WBTCETH               = 0xD375daC26f7eF991878136b387ca959b9ac1DDaF;
    address constant MCD_JOIN_UNIV2WBTCETH_A        = 0x345a29Db10Aa5CF068D61Bb20F74771eC7DF66FE;
    address constant MCD_CLIP_UNIV2WBTCETH_A        = 0x8520AA6784d51B1984B6f693f1Ea646368d9f868;
    address constant MCD_CLIP_CALC_UNIV2WBTCETH_A   = 0xab5B4759c8D28d05c4cd335a0315A52981F93D04;
    address constant UNIV2USDCETH                   = 0xD90313b3E43D9a922c71d26a0fBCa75A01Bb3Aeb;
    address constant PIP_UNIV2USDCETH               = 0x54ADcaB9B99b1B548764dAB637db751eC66835F0;
    address constant MCD_JOIN_UNIV2USDCETH_A        = 0x46267d84dA4D6e7b2F5A999518Cf5DAF91E204E3;
    address constant MCD_CLIP_UNIV2USDCETH_A        = 0x7424D5319172a3dC57add04dBb48E6323Da4B473;
    address constant MCD_CLIP_CALC_UNIV2USDCETH_A   = 0x83B20C43D92224E128c2b1e0ECb6305B1001FF4f;
    address constant UNIV2DAIUSDC                   = 0x260719B2ef507A86116FC24341ff0994F2097D42;
    address constant PIP_UNIV2DAIUSDC               = 0xEf22289E240cFcCCdCD2B98fdefF167da10f452d;
    address constant MCD_JOIN_UNIV2DAIUSDC_A        = 0x4CEEf4EB4988cb374B0b288D685AeBE4c6d4C41E;
    address constant MCD_CLIP_UNIV2DAIUSDC_A        = 0x04254C28c09C8a09c76653acA92538EC04954341;
    address constant MCD_CLIP_CALC_UNIV2DAIUSDC_A   = 0x3dB02f19D2d1609661f9bD774De23a962642F25B;
    address constant UNIV2ETHUSDT                   = 0xfcB32e1C4A4F1C820c9304B5CFfEDfB91aE2321C;
    address constant PIP_UNIV2ETHUSDT               = 0x974f7f4dC6D91f144c87cc03749c98f85F997bc7;
    address constant MCD_JOIN_UNIV2ETHUSDT_A        = 0x46A8f8e2C0B62f5D7E4c95297bB26a457F358C82;
    address constant MCD_CLIP_UNIV2ETHUSDT_A        = 0x4bBCD4dc8cD4bfc907268AB5AD3aE01e2567f0E1;
    address constant MCD_CLIP_CALC_UNIV2ETHUSDT_A   = 0x9e24c087EbBA685dFD4AF1fC6C31C414f6EfA74f;
    address constant UNIV2LINKETH                   = 0x3361fB8f923D1Aa1A45B2d2eD4B8bdF313a3dA0c;
    address constant PIP_UNIV2LINKETH               = 0x11C884B3FEE1494A666Bb20b6F6144387beAf4A6;
    address constant MCD_JOIN_UNIV2LINKETH_A        = 0x98B7023Aced6D8B889Ad7D340243C3F9c81E8c5F;
    address constant MCD_CLIP_UNIV2LINKETH_A        = 0x71c6d999c54AB5C91589F45Aa5F0E2E782647268;
    address constant MCD_CLIP_CALC_UNIV2LINKETH_A   = 0x30747d2D2f9C23CBCc2ff318c31C15A6f0AA78bF;
    address constant UNIV2UNIETH                    = 0xB80A38E50B2990Ac83e46Fe16631fFBb94F2780b;
    address constant PIP_UNIV2UNIETH                = 0xB18BC24e52C23A77225E7cf088756581EE257Ad8;
    address constant MCD_JOIN_UNIV2UNIETH_A         = 0x52c31E3592352Cd0CBa20Fa73Da42584EC693283;
    address constant MCD_CLIP_UNIV2UNIETH_A         = 0xaBb1F3fBe1c404829BC1807D67126286a71b85dE;
    address constant MCD_CLIP_CALC_UNIV2UNIETH_A    = 0x663D47b5AF171D7b54dfB2A234406903307721b8;
    address constant UNIV2WBTCDAI                   = 0x3f78Bd3980c49611E5FA885f25Ca3a5fCbf0d7A0;
    address constant PIP_UNIV2WBTCDAI               = 0x916fc346910fd25867c81874f7F982a1FB69aac7;
    address constant MCD_JOIN_UNIV2WBTCDAI_A        = 0x04d23e99504d61050CAF46B4ce2dcb9D4135a7fD;
    address constant MCD_CLIP_UNIV2WBTCDAI_A        = 0xee139bB397211A21656046efb2c7a5b255d3bC07;
    address constant MCD_CLIP_CALC_UNIV2WBTCDAI_A   = 0xf89C3DDA6D0f496900ecC39e4a7D31075d360856;
    address constant UNIV2AAVEETH                   = 0xaF2CC6F46d1d0AB30dd45F59B562394c3E21e6f3;
    address constant PIP_UNIV2AAVEETH               = 0xFADF05B56E4b211877248cF11C0847e7F8924e10;
    address constant MCD_JOIN_UNIV2AAVEETH_A        = 0x73C4E5430768e24Fd704291699823f35953bbbA2;
    address constant MCD_CLIP_UNIV2AAVEETH_A        = 0xeA4F6DA7Ac68F9244FCDd13AE2C36647829AfCa0;
    address constant MCD_CLIP_CALC_UNIV2AAVEETH_A   = 0x14F4D6cB78632535230D1591121E35108bbBdAAA;
    address constant UNIV2DAIUSDT                   = 0xBF2C9aBbEC9755A0b6144051E19c6AD4e6fd6D71;
    address constant PIP_UNIV2DAIUSDT               = 0x2fc2706C61Fba5b941381e8838bC646908845db6;
    address constant MCD_JOIN_UNIV2DAIUSDT_A        = 0xBF70Ca17ce5032CCa7cD55a946e96f0E72f79452;
    address constant MCD_CLIP_UNIV2DAIUSDT_A        = 0xABB9ca15E7e261E255560153e312c98F638E57f4;
    address constant MCD_CLIP_CALC_UNIV2DAIUSDT_A   = 0xDD610087b4a029BD63e4990A6A29a077764B632B;

    uint256 constant THOUSAND   = 10 ** 3;
    uint256 constant MILLION    = 10 ** 6;

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {
        // UNIV2DAIETH-A
        DssExecLib.addNewCollateral(CollateralOpts({
            ilk:                   "UNIV2DAIETH-A",
            gem:                   UNIV2DAIETH,
            join:                  MCD_JOIN_UNIV2DAIETH_A,
            clip:                  MCD_CLIP_UNIV2DAIETH_A,
            calc:                  MCD_CLIP_CALC_UNIV2DAIETH_A,
            pip:                   PIP_UNIV2DAIETH,
            isLiquidatable:        true,
            isOSM:                 true,
            whitelistOSM:          false,
            ilkDebtCeiling:        5 * MILLION,
            minVaultAmount:        10 * THOUSAND,
            maxLiquidationAmount:  5 * MILLION,
            liquidationPenalty:    1300,
            ilkStabilityFee:       1000000000472114805215157978,
            startingPriceFactor:   11500,
            breakerTolerance:      7000,
            auctionDuration:       215 minutes,
            permittedDrop:         6000,
            liquidationRatio:      12500,
            kprFlatReward:         300,
            kprPctReward:          10
        }));
        MedianAbstract(LPOsmAbstract(PIP_UNIV2DAIETH).orb1()).kiss(PIP_UNIV2DAIETH);
        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_UNIV2DAIETH_A, 125 seconds, 9950);
        DssExecLib.setIlkAutoLineParameters("UNIV2DAIETH-A", 50 * MILLION, 5 * MILLION, 8 hours);
        IlkRegistryAbstract(DssExecLib.reg()).update("UNIV2DAIETH-A");
        DssExecLib.setChangelogAddress("UNIV2DAIETH", UNIV2DAIETH);
        DssExecLib.setChangelogAddress("PIP_UNIV2DAIETH", PIP_UNIV2DAIETH);
        DssExecLib.setChangelogAddress("MCD_JOIN_UNIV2DAIETH_A", MCD_JOIN_UNIV2DAIETH_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_UNIV2DAIETH_A", MCD_CLIP_UNIV2DAIETH_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_UNIV2DAIETH_A", MCD_CLIP_CALC_UNIV2DAIETH_A);
        //
        // UNIV2WBTCETH-A
        DssExecLib.addNewCollateral(CollateralOpts({
            ilk:                   "UNIV2WBTCETH-A",
            gem:                   UNIV2WBTCETH,
            join:                  MCD_JOIN_UNIV2WBTCETH_A,
            clip:                  MCD_CLIP_UNIV2WBTCETH_A,
            calc:                  MCD_CLIP_CALC_UNIV2WBTCETH_A,
            pip:                   PIP_UNIV2WBTCETH,
            isLiquidatable:        true,
            isOSM:                 true,
            whitelistOSM:          true,
            ilkDebtCeiling:        3 * MILLION,
            minVaultAmount:        10 * THOUSAND,
            maxLiquidationAmount:  5 * MILLION,
            liquidationPenalty:    1300,
            ilkStabilityFee:       1000000000627937192491029810,
            startingPriceFactor:   13000,
            breakerTolerance:      5000,
            auctionDuration:       200 minutes,
            permittedDrop:         4000,
            liquidationRatio:      15000,
            kprFlatReward:         300,
            kprPctReward:          10
        }));
        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_UNIV2WBTCETH_A, 130 seconds, 9900);
        DssExecLib.setIlkAutoLineParameters("UNIV2WBTCETH-A", 20 * MILLION, 3 * MILLION, 8 hours);
        IlkRegistryAbstract(DssExecLib.reg()).update("UNIV2WBTCETH-A");
        DssExecLib.setChangelogAddress("UNIV2WBTCETH", UNIV2WBTCETH);
        DssExecLib.setChangelogAddress("PIP_UNIV2WBTCETH", PIP_UNIV2WBTCETH);
        DssExecLib.setChangelogAddress("MCD_JOIN_UNIV2WBTCETH_A", MCD_JOIN_UNIV2WBTCETH_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_UNIV2WBTCETH_A", MCD_CLIP_UNIV2WBTCETH_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_UNIV2WBTCETH_A", MCD_CLIP_CALC_UNIV2WBTCETH_A);
        //
        // UNIV2USDCETH-A
        DssExecLib.addNewCollateral(CollateralOpts({
            ilk:                   "UNIV2USDCETH-A",
            gem:                   UNIV2USDCETH,
            join:                  MCD_JOIN_UNIV2USDCETH_A,
            clip:                  MCD_CLIP_UNIV2USDCETH_A,
            calc:                  MCD_CLIP_CALC_UNIV2USDCETH_A,
            pip:                   PIP_UNIV2USDCETH,
            isLiquidatable:        true,
            isOSM:                 true,
            whitelistOSM:          false,
            ilkDebtCeiling:        5 * MILLION,
            minVaultAmount:        10 * THOUSAND,
            maxLiquidationAmount:  5 * MILLION,
            liquidationPenalty:    1300,
            ilkStabilityFee:       1000000000627937192491029810,
            startingPriceFactor:   11500,
            breakerTolerance:      7000,
            auctionDuration:       215 minutes,
            permittedDrop:         6000,
            liquidationRatio:      12500,
            kprFlatReward:         300,
            kprPctReward:          10
        }));
        MedianAbstract(LPOsmAbstract(PIP_UNIV2USDCETH).orb1()).kiss(PIP_UNIV2USDCETH);
        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_UNIV2USDCETH_A, 125 seconds, 9950);
        DssExecLib.setIlkAutoLineParameters("UNIV2USDCETH-A", 50 * MILLION, 5 * MILLION, 8 hours);
        IlkRegistryAbstract(DssExecLib.reg()).update("UNIV2USDCETH-A");
        DssExecLib.setChangelogAddress("UNIV2USDCETH", UNIV2USDCETH);
        DssExecLib.setChangelogAddress("PIP_UNIV2USDCETH", PIP_UNIV2USDCETH);
        DssExecLib.setChangelogAddress("MCD_JOIN_UNIV2USDCETH_A", MCD_JOIN_UNIV2USDCETH_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_UNIV2USDCETH_A", MCD_CLIP_UNIV2USDCETH_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_UNIV2USDCETH_A", MCD_CLIP_CALC_UNIV2USDCETH_A);
        //
        // UNIV2DAIUSDC-A
        DssExecLib.addNewCollateral(CollateralOpts({
            ilk:                   "UNIV2DAIUSDC-A",
            gem:                   UNIV2DAIUSDC,
            join:                  MCD_JOIN_UNIV2DAIUSDC_A,
            clip:                  MCD_CLIP_UNIV2DAIUSDC_A,
            calc:                  MCD_CLIP_CALC_UNIV2DAIUSDC_A,
            pip:                   PIP_UNIV2DAIUSDC,
            isLiquidatable:        false,
            isOSM:                 true,
            whitelistOSM:          false,
            ilkDebtCeiling:        10 * MILLION,
            minVaultAmount:        10 * THOUSAND,
            maxLiquidationAmount:  0,
            liquidationPenalty:    1300,
            ilkStabilityFee:       1000000000000000000000000000,
            startingPriceFactor:   10500,
            breakerTolerance:      9500,
            auctionDuration:       220 minutes,
            permittedDrop:         9000,
            liquidationRatio:      10200,
            kprFlatReward:         300,
            kprPctReward:          10
        }));
        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_UNIV2DAIUSDC_A, 120 seconds, 9990);
        DssExecLib.setIlkAutoLineParameters("UNIV2DAIUSDC-A", 250 * MILLION, 10 * MILLION, 8 hours);
        IlkRegistryAbstract(DssExecLib.reg()).update("UNIV2DAIUSDC-A");
        DssExecLib.setChangelogAddress("UNIV2DAIUSDC", UNIV2DAIUSDC);
        DssExecLib.setChangelogAddress("PIP_UNIV2DAIUSDC", PIP_UNIV2DAIUSDC);
        DssExecLib.setChangelogAddress("MCD_JOIN_UNIV2DAIUSDC_A", MCD_JOIN_UNIV2DAIUSDC_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_UNIV2DAIUSDC_A", MCD_CLIP_UNIV2DAIUSDC_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_UNIV2DAIUSDC_A", MCD_CLIP_CALC_UNIV2DAIUSDC_A);
        //
        // UNIV2ETHUSDT-A
        DssExecLib.addNewCollateral(CollateralOpts({
            ilk:                   "UNIV2ETHUSDT-A",
            gem:                   UNIV2ETHUSDT,
            join:                  MCD_JOIN_UNIV2ETHUSDT_A,
            clip:                  MCD_CLIP_UNIV2ETHUSDT_A,
            calc:                  MCD_CLIP_CALC_UNIV2ETHUSDT_A,
            pip:                   PIP_UNIV2ETHUSDT,
            isLiquidatable:        true,
            isOSM:                 true,
            whitelistOSM:          true,
            ilkDebtCeiling:        0,
            minVaultAmount:        10 * THOUSAND,
            maxLiquidationAmount:  5 * MILLION,
            liquidationPenalty:    1300,
            ilkStabilityFee:       1000000000627937192491029810,
            startingPriceFactor:   11500,
            breakerTolerance:      7000,
            auctionDuration:       215 minutes,
            permittedDrop:         6000,
            liquidationRatio:      14000,
            kprFlatReward:         300,
            kprPctReward:          10
        }));
        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_UNIV2ETHUSDT_A, 125 seconds, 9950);
        IlkRegistryAbstract(DssExecLib.reg()).update("UNIV2ETHUSDT-A");
        DssExecLib.setChangelogAddress("UNIV2ETHUSDT", UNIV2ETHUSDT);
        DssExecLib.setChangelogAddress("PIP_UNIV2ETHUSDT", PIP_UNIV2ETHUSDT);
        DssExecLib.setChangelogAddress("MCD_JOIN_UNIV2ETHUSDT_A", MCD_JOIN_UNIV2ETHUSDT_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_UNIV2ETHUSDT_A", MCD_CLIP_UNIV2ETHUSDT_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_UNIV2ETHUSDT_A", MCD_CLIP_CALC_UNIV2ETHUSDT_A);
        //
        // UNIV2LINKETH-A
        DssExecLib.addNewCollateral(CollateralOpts({
            ilk:                   "UNIV2LINKETH-A",
            gem:                   UNIV2LINKETH,
            join:                  MCD_JOIN_UNIV2LINKETH_A,
            clip:                  MCD_CLIP_UNIV2LINKETH_A,
            calc:                  MCD_CLIP_CALC_UNIV2LINKETH_A,
            pip:                   PIP_UNIV2LINKETH,
            isLiquidatable:        true,
            isOSM:                 true,
            whitelistOSM:          true,
            ilkDebtCeiling:        2 * MILLION,
            minVaultAmount:        10 * THOUSAND,
            maxLiquidationAmount:  3 * MILLION,
            liquidationPenalty:    1300,
            ilkStabilityFee:       1000000000937303470807876289,
            startingPriceFactor:   13000,
            breakerTolerance:      5000,
            auctionDuration:       200 minutes,
            permittedDrop:         4000,
            liquidationRatio:      16500,
            kprFlatReward:         300,
            kprPctReward:          10
        }));
        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_UNIV2LINKETH_A, 130 seconds, 9900);
        DssExecLib.setIlkAutoLineParameters("UNIV2LINKETH-A", 20 * MILLION, 2 * MILLION, 8 hours);
        IlkRegistryAbstract(DssExecLib.reg()).update("UNIV2LINKETH-A");
        DssExecLib.setChangelogAddress("UNIV2LINKETH", UNIV2LINKETH);
        DssExecLib.setChangelogAddress("PIP_UNIV2LINKETH", PIP_UNIV2LINKETH);
        DssExecLib.setChangelogAddress("MCD_JOIN_UNIV2LINKETH_A", MCD_JOIN_UNIV2LINKETH_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_UNIV2LINKETH_A", MCD_CLIP_UNIV2LINKETH_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_UNIV2LINKETH_A", MCD_CLIP_CALC_UNIV2LINKETH_A);
        //
        // UNIV2UNIETH-A
        DssExecLib.addNewCollateral(CollateralOpts({
            ilk:                   "UNIV2UNIETH-A",
            gem:                   UNIV2UNIETH,
            join:                  MCD_JOIN_UNIV2UNIETH_A,
            clip:                  MCD_CLIP_UNIV2UNIETH_A,
            calc:                  MCD_CLIP_CALC_UNIV2UNIETH_A,
            pip:                   PIP_UNIV2UNIETH,
            isLiquidatable:        true,
            isOSM:                 true,
            whitelistOSM:          true,
            ilkDebtCeiling:        2 * MILLION,
            minVaultAmount:        10 * THOUSAND,
            maxLiquidationAmount:  3 * MILLION,
            liquidationPenalty:    1300,
            ilkStabilityFee:       1000000000627937192491029810,
            startingPriceFactor:   13000,
            breakerTolerance:      5000,
            auctionDuration:       200 minutes,
            permittedDrop:         4000,
            liquidationRatio:      16500,
            kprFlatReward:         300,
            kprPctReward:          10
        }));
        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_UNIV2UNIETH_A, 130 seconds, 9900);
        DssExecLib.setIlkAutoLineParameters("UNIV2UNIETH-A", 20 * MILLION, 3 * MILLION, 8 hours);
        IlkRegistryAbstract(DssExecLib.reg()).update("UNIV2UNIETH-A");
        DssExecLib.setChangelogAddress("UNIV2UNIETH", UNIV2UNIETH);
        DssExecLib.setChangelogAddress("PIP_UNIV2UNIETH", PIP_UNIV2UNIETH);
        DssExecLib.setChangelogAddress("MCD_JOIN_UNIV2UNIETH_A", MCD_JOIN_UNIV2UNIETH_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_UNIV2UNIETH_A", MCD_CLIP_UNIV2UNIETH_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_UNIV2UNIETH_A", MCD_CLIP_CALC_UNIV2UNIETH_A);
        //
        // UNIV2WBTCDAI-A
        DssExecLib.addNewCollateral(CollateralOpts({
            ilk:                   "UNIV2WBTCDAI-A",
            gem:                   UNIV2WBTCDAI,
            join:                  MCD_JOIN_UNIV2WBTCDAI_A,
            clip:                  MCD_CLIP_UNIV2WBTCDAI_A,
            calc:                  MCD_CLIP_CALC_UNIV2WBTCDAI_A,
            pip:                   PIP_UNIV2WBTCDAI,
            isLiquidatable:        true,
            isOSM:                 true,
            whitelistOSM:          false,
            ilkDebtCeiling:        3 * MILLION,
            minVaultAmount:        10 * THOUSAND,
            maxLiquidationAmount:  5 * MILLION,
            liquidationPenalty:    1300,
            ilkStabilityFee:       1000000000000000000000000000,
            startingPriceFactor:   11500,
            breakerTolerance:      7000,
            auctionDuration:       215 minutes,
            permittedDrop:         6000,
            liquidationRatio:      12500,
            kprFlatReward:         300,
            kprPctReward:          10
        }));
        MedianAbstract(LPOsmAbstract(PIP_UNIV2WBTCDAI).orb1()).kiss(PIP_UNIV2WBTCDAI);
        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_UNIV2WBTCDAI_A, 125 seconds, 9950);
        DssExecLib.setIlkAutoLineParameters("UNIV2WBTCDAI-A", 20 * MILLION, 3 * MILLION, 8 hours);
        IlkRegistryAbstract(DssExecLib.reg()).update("UNIV2WBTCDAI-A");
        DssExecLib.setChangelogAddress("UNIV2WBTCDAI", UNIV2WBTCDAI);
        DssExecLib.setChangelogAddress("PIP_UNIV2WBTCDAI", PIP_UNIV2WBTCDAI);
        DssExecLib.setChangelogAddress("MCD_JOIN_UNIV2WBTCDAI_A", MCD_JOIN_UNIV2WBTCDAI_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_UNIV2WBTCDAI_A", MCD_CLIP_UNIV2WBTCDAI_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_UNIV2WBTCDAI_A", MCD_CLIP_CALC_UNIV2WBTCDAI_A);
        //
        // UNIV2AAVEETH-A
        DssExecLib.addNewCollateral(CollateralOpts({
            ilk:                   "UNIV2AAVEETH-A",
            gem:                   UNIV2AAVEETH,
            join:                  MCD_JOIN_UNIV2AAVEETH_A,
            clip:                  MCD_CLIP_UNIV2AAVEETH_A,
            calc:                  MCD_CLIP_CALC_UNIV2AAVEETH_A,
            pip:                   PIP_UNIV2AAVEETH,
            isLiquidatable:        true,
            isOSM:                 true,
            whitelistOSM:          true,
            ilkDebtCeiling:        2 * MILLION,
            minVaultAmount:        10 * THOUSAND,
            maxLiquidationAmount:  3 * MILLION,
            liquidationPenalty:    1300,
            ilkStabilityFee:       1000000000937303470807876289,
            startingPriceFactor:   13000,
            breakerTolerance:      5000,
            auctionDuration:       200 minutes,
            permittedDrop:         4000,
            liquidationRatio:      16500,
            kprFlatReward:         300,
            kprPctReward:          10
        }));
        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_UNIV2AAVEETH_A, 130 seconds, 9900);
        DssExecLib.setIlkAutoLineParameters("UNIV2AAVEETH-A", 20 * MILLION, 2 * MILLION, 8 hours);
        IlkRegistryAbstract(DssExecLib.reg()).update("UNIV2AAVEETH-A");
        DssExecLib.setChangelogAddress("UNIV2AAVEETH", UNIV2AAVEETH);
        DssExecLib.setChangelogAddress("PIP_UNIV2AAVEETH", PIP_UNIV2AAVEETH);
        DssExecLib.setChangelogAddress("MCD_JOIN_UNIV2AAVEETH_A", MCD_JOIN_UNIV2AAVEETH_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_UNIV2AAVEETH_A", MCD_CLIP_UNIV2AAVEETH_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_UNIV2AAVEETH_A", MCD_CLIP_CALC_UNIV2AAVEETH_A);
        //
        // UNIV2DAIUSDT-A
        DssExecLib.addNewCollateral(CollateralOpts({
            ilk:                   "UNIV2DAIUSDT-A",
            gem:                   UNIV2DAIUSDT,
            join:                  MCD_JOIN_UNIV2DAIUSDT_A,
            clip:                  MCD_CLIP_UNIV2DAIUSDT_A,
            calc:                  MCD_CLIP_CALC_UNIV2DAIUSDT_A,
            pip:                   PIP_UNIV2DAIUSDT,
            isLiquidatable:        true,
            isOSM:                 true,
            whitelistOSM:          false,
            ilkDebtCeiling:        0,
            minVaultAmount:        10 * THOUSAND,
            maxLiquidationAmount:  5 * MILLION,
            liquidationPenalty:    1300,
            ilkStabilityFee:       1000000000627937192491029810,
            startingPriceFactor:   10500,
            breakerTolerance:      9500,
            auctionDuration:       220 minutes,
            permittedDrop:         9000,
            liquidationRatio:      12500,
            kprFlatReward:         300,
            kprPctReward:          10
        }));
        MedianAbstract(LPOsmAbstract(PIP_UNIV2DAIUSDT).orb1()).kiss(PIP_UNIV2DAIUSDT);
        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_UNIV2DAIUSDT_A, 120 seconds, 9990);
        IlkRegistryAbstract(DssExecLib.reg()).update("UNIV2DAIUSDT-A");
        DssExecLib.setChangelogAddress("UNIV2DAIUSDT", UNIV2DAIUSDT);
        DssExecLib.setChangelogAddress("PIP_UNIV2DAIUSDT", PIP_UNIV2DAIUSDT);
        DssExecLib.setChangelogAddress("MCD_JOIN_UNIV2DAIUSDT_A", MCD_JOIN_UNIV2DAIUSDT_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_UNIV2DAIUSDT_A", MCD_CLIP_UNIV2DAIUSDT_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_UNIV2DAIUSDT_A", MCD_CLIP_CALC_UNIV2DAIUSDT_A);
        //
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
