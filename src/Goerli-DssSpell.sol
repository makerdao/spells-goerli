// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2021 Dai Foundation
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

interface TokenLike {
    function decimals() external view returns (uint256);
    function approve(address, uint256) external returns (bool);
}

interface VatLike {
    function ilks(bytes32) external view returns (uint256, uint256, uint256, uint256, uint256);
    function urns(bytes32,address) external view returns (uint256, uint256);
    function grab(bytes32,address,address,address,int256,int256) external;
}

interface GemJoinLike {
    function rely(address) external;
    function exit(address, uint) external;
}

interface SpotterLike {
    function ilks(bytes32) external returns (address, uint256);
}

interface CharterManagerLike {
    function setImplementation(address) external;
    function file(bytes32, bytes32, uint256) external;
    function file(bytes32, address, bytes32, uint256) external;
    function join(address, address, uint256) external;
    function getOrCreateProxy(address) external returns (address);
    function uline(bytes32, address) external returns (uint256);
    function peace(bytes32, address) external returns (uint256);
}

contract DssSpellAction is DssAction {

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/TODO -q -O - 2>/dev/null)"
    string public constant override description = "Goerli Spell";

    uint256 constant THOUSAND = 10 ** 3;
    uint256 constant MILLION  = 10 ** 6;
    uint256 constant WAD      = 10 ** 18;
    uint256 constant RAY      = 10 ** 27;
    uint256 constant RAD      = 10 ** 45;

    function _mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function _rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = _mul(x, y) / RAY;
    }

    function _rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = _mul(x, RAY) / y;
    }

    uint256 constant ONE_POINT_FIVE_PCT = 1000000000472114805215157978;

    address public constant MCD_VAT                   = 0xB966002DDAa2Baf48369f5015329750019736031;
    address public constant MCD_VOW                   = 0x23f78612769b9013b3145E43896Fa1578cAa2c2a;
    address public constant MCD_SPOT                  = 0xACe2A9106ec175bd56ec05C9E38FE1FDa8a1d758;
    address public constant MCD_CHARTER_MANAGER       = 0x91678e757C20351d0D393e3C907c6C9B5ef46d6c;
    address public constant MCD_CHARTER_MANAGER_IMP   = 0x23eA5CC5c9252033208C177da7A936b6060A5af9;

    address public constant ETH                       = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    address public constant PIP_ETH                   = 0x94588e35fF4d2E99ffb8D5095F35d1E37d6dDf12;
    address public constant MCD_JOIN_INST_ETH_A       = 0x64840DA08EEC4E25D37A26F13AD5EEA0d83E36A0;
    address public constant MCD_CLIP_INST_ETH_A       = 0x6222213862c49d87fE452876036A73c42386bdc8;
    address public constant MCD_CLIP_CALC_INST_ETH_A  = 0x250BCc40fF755D6c6f56b28826EB830cD3638570;

    address public constant WBTC                      = 0x7ccF0411c7932B99FC3704d68575250F032e3bB7;
    address public constant PIP_WBTC                  = 0xE7de200a3a29E9049E378b52BD36701A0Ce68C3b;
    address public constant MCD_JOIN_INST_WBTC_A      = 0xa461e204Cb099463a190403Bd460C54093b37320;
    address public constant MCD_CLIP_INST_WBTC_A      = 0x720221bcAEbdC0b0837ca4569FF0E568954D658e;
    address public constant MCD_CLIP_CALC_INST_WBTC_A = 0x7E906D070E16e7c0dA33E57b3ca460CC8217E9b1;

    // 0xe1BDDCbED1C90785fdcA9a72A9345e498313Bd4F
    address public constant NEXO                      = 0xA46C5449feD1dAd583fbdCA4cee7804eC59B1f0c;
    address public constant MCD_JOIN_ETH_A            = 0x2372031bB0fC735722AA4009AeBf66E8BEAF4BA1;
    address public constant NEXO_OLD_ETH_A_URN        = 0xc82f39C54F0709Fe624E35BF91B76Ba7674de54D;
    address public constant MCD_JOIN_WBTC_A           = 0x3cbE712a12e651eEAF430472c0C1BF1a2a18939D;
    address public constant NEXO_OLD_WBTC_A_URN       = 0x20B9a6eB4A8249e879Db6C6A6799BF52294eFeB7;

    function migrate(
        address gem,
        bytes32 oldIlk,
        address oldAdapter,
        address oldUrn,
        bytes32 ilk,
        address adapter,
        uint256 dai,
        uint256 dink
    ) internal {

        (, uint256 oldRate,,,) = VatLike(MCD_VAT).ilks(oldIlk);
        (, uint256 rate,,,) = VatLike(MCD_VAT).ilks(ilk);

        uint256 oldDart = dai / oldRate; // TODO: not nice that dart is uint
        uint256 gemAmt = dink / (10 ** (18 - TokenLike(gem).decimals()));
        int256  dart = int256(_mul(oldRate, oldDart) / rate);

        VatLike(MCD_VAT).grab(oldIlk, oldUrn, address(this), MCD_VOW, -int256(dink), -int256(oldDart));
        GemJoinLike(oldAdapter).exit(address(this), gemAmt);
        require(TokenLike(gem).approve(MCD_CHARTER_MANAGER, gemAmt));
        CharterManagerLike(MCD_CHARTER_MANAGER).join(adapter, NEXO, gemAmt);
        VatLike(MCD_VAT).grab(
            ilk,
            CharterManagerLike(MCD_CHARTER_MANAGER).getOrCreateProxy(NEXO),
            CharterManagerLike(MCD_CHARTER_MANAGER).getOrCreateProxy(NEXO),
            MCD_VOW,
            int256(dink),
            dart
        );
    }

    function validateSafe(bytes32 ilk, address urn) internal {
        (, uint256 rate, uint256 spot,,) = VatLike(MCD_VAT).ilks(ilk);
        (uint256 ink, uint256 art) = VatLike(MCD_VAT).urns(ilk, urn);

        uint tab = _mul(rate, art);
        require(tab <= _mul(ink, spot), "not-safe");
    }

    function validateUlinePeace(bytes32 ilk, address urn) internal {
        (, uint256 rate, uint256 spot,,) = VatLike(MCD_VAT).ilks(ilk);
        (uint256 ink, uint256 art) = VatLike(MCD_VAT).urns(ilk, urn);

        uint256 tab = _mul(art, rate); // rad
        uint256 uline = CharterManagerLike(MCD_CHARTER_MANAGER).uline(ilk, NEXO);
        require(tab <= uline, "user-line-exceeded");

        uint256 peace = CharterManagerLike(MCD_CHARTER_MANAGER).peace(ilk, NEXO);
        (, uint256 mat) = SpotterLike(MCD_SPOT).ilks(ilk);
        uint256 peaceSpot = _rdiv(_rmul(spot, mat), peace); // ray
        require(tab <= _mul(ink, peaceSpot), "below-peace-ratio");
    }

    function actions() public override {

        // Charter Manager
        CharterManagerLike(MCD_CHARTER_MANAGER).setImplementation(MCD_CHARTER_MANAGER_IMP);

        // INST-ETH-A
        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_INST_ETH_A, 90 seconds, 9900);

        CollateralOpts memory INST_ETH_A = CollateralOpts({
            ilk:                   "INST-ETH-A",
            gem:                   ETH,
            join:                  MCD_JOIN_INST_ETH_A,
            clip:                  MCD_CLIP_INST_ETH_A,
            calc:                  MCD_CLIP_CALC_INST_ETH_A,
            pip:                   PIP_ETH,
            isLiquidatable:        true,
            isOSM:                 true,
            whitelistOSM:          false,
            ilkDebtCeiling:        900 * MILLION,
            minVaultAmount:        10 * THOUSAND,
            maxLiquidationAmount:  50 * MILLION,
            liquidationPenalty:    2000,
            ilkStabilityFee:       ONE_POINT_FIVE_PCT,
            startingPriceFactor:   12000,
            breakerTolerance:      5000,
            auctionDuration:       140 minutes,
            permittedDrop:         4000,
            liquidationRatio:      12000,
            kprFlatReward:         300,
            kprPctReward:          10 // 0.1%
        });

        DssExecLib.addNewCollateral(INST_ETH_A);

        GemJoinLike(MCD_JOIN_INST_ETH_A).rely(MCD_CHARTER_MANAGER);
        CharterManagerLike(MCD_CHARTER_MANAGER).file("INST-ETH-A", "gate", 1);
        CharterManagerLike(MCD_CHARTER_MANAGER).file("INST-ETH-A", NEXO, "nib", 1 * WAD / 100); // 1%
        CharterManagerLike(MCD_CHARTER_MANAGER).file("INST-ETH-A", NEXO, "peace", 150 * RAY / 100); // 150%
        CharterManagerLike(MCD_CHARTER_MANAGER).file("INST-ETH-A", NEXO, "uline", 900 * MILLION * RAD);

        // INST-WBTC-A
        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_INST_WBTC_A, 90 seconds, 9900);

        migrate(
            ETH,
            "ETH-A",
            MCD_JOIN_ETH_A,
            NEXO_OLD_ETH_A_URN,
            "INST-ETH-A",
            MCD_JOIN_INST_ETH_A,
            15_000 * RAD,
            10 * WAD
        );
        validateSafe("ETH-A", NEXO_OLD_ETH_A_URN);
        validateSafe("INST-ETH-A", CharterManagerLike(MCD_CHARTER_MANAGER).getOrCreateProxy(NEXO));
        validateUlinePeace("INST-ETH-A", CharterManagerLike(MCD_CHARTER_MANAGER).getOrCreateProxy(NEXO));

        CollateralOpts memory INST_WBTC_A = CollateralOpts({
            ilk:                   "INST-WBTC-A",
            gem:                   WBTC,
            join:                  MCD_JOIN_INST_WBTC_A,
            clip:                  MCD_CLIP_INST_WBTC_A,
            calc:                  MCD_CLIP_CALC_INST_WBTC_A,
            pip:                   PIP_WBTC,
            isLiquidatable:        true,
            isOSM:                 true,
            whitelistOSM:          false,
            ilkDebtCeiling:        600 * MILLION,
            minVaultAmount:        10 * THOUSAND,
            maxLiquidationAmount:  30 * MILLION,
            liquidationPenalty:    2000,
            ilkStabilityFee:       ONE_POINT_FIVE_PCT,
            startingPriceFactor:   12000,
            breakerTolerance:      5000,
            auctionDuration:       140 minutes,
            permittedDrop:         4000,
            liquidationRatio:      12000,
            kprFlatReward:         300,
            kprPctReward:          10 // 0.1%
        });

        DssExecLib.addNewCollateral(INST_WBTC_A);

        GemJoinLike(MCD_JOIN_INST_WBTC_A).rely(MCD_CHARTER_MANAGER);
        CharterManagerLike(MCD_CHARTER_MANAGER).file("INST-WBTC-A", "gate", 1);
        CharterManagerLike(MCD_CHARTER_MANAGER).file("INST-WBTC-A", NEXO, "nib", 1 * WAD / 100); // 1%
        CharterManagerLike(MCD_CHARTER_MANAGER).file("INST-WBTC-A", NEXO, "peace", 150 * RAY / 100); // 150%
        CharterManagerLike(MCD_CHARTER_MANAGER).file("INST-WBTC-A", NEXO, "uline", 600 * MILLION * RAD);

        migrate(
            WBTC,
            "WBTC-A",
            MCD_JOIN_WBTC_A,
            NEXO_OLD_WBTC_A_URN,
            "INST-WBTC-A",
            MCD_JOIN_INST_WBTC_A,
            10_000 * RAD,
            41 * WAD / 100 // 0.41
        );
        validateSafe("WBTC-A", NEXO_OLD_WBTC_A_URN);
        validateSafe("INST-WBTC-A", CharterManagerLike(MCD_CHARTER_MANAGER).getOrCreateProxy(NEXO));
        validateUlinePeace("INST-WBTC-A", CharterManagerLike(MCD_CHARTER_MANAGER).getOrCreateProxy(NEXO));

        // Changelog
        DssExecLib.setChangelogAddress("MCD_CHARTER_MANAGER", MCD_CHARTER_MANAGER);
        DssExecLib.setChangelogVersion("1.9.10");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
