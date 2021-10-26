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

interface CharterManagerLike {
    function file(bytes32, bytes32, uint256) external;
    function file(bytes32, address, bytes32, uint256) external;
    function join(address, address, uint256) external;
    function getOrCreateProxy(address) external returns (address);
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

    uint256 constant ONE_POINT_FIVE_PCT = 1000000000472114805215157978;

    address public constant MCD_VAT                   = 0x0000000000000000000000000000000000000000;
    address public constant MCD_VOW                   = 0x0000000000000000000000000000000000000000;
    address public constant MCD_CHARTER_MANAGER       = 0x0000000000000000000000000000000000000000;

    address public constant ETH_GEM                   = 0x0000000000000000000000000000000000000000;
    address public constant MCD_JOIN_INST_ETH_A       = 0x0000000000000000000000000000000000000000;
    address public constant MCD_CLIP_INST_ETH_A       = 0x0000000000000000000000000000000000000000;
    address public constant MCD_CLIP_CALC_INST_ETH_A  = 0x0000000000000000000000000000000000000000;
    address public constant PIP_ETH                   = 0x0000000000000000000000000000000000000000;

    address public constant WBTC_GEM                  = 0x0000000000000000000000000000000000000000;
    address public constant MCD_JOIN_INST_WBTC_A      = 0x0000000000000000000000000000000000000000;
    address public constant MCD_CLIP_INST_WBTC_A      = 0x0000000000000000000000000000000000000000;
    address public constant MCD_CLIP_CALC_INST_WBTC_A = 0x0000000000000000000000000000000000000000;
    address public constant PIP_WBTC                  = 0x0000000000000000000000000000000000000000;

    address public constant NEXO                      = 0x0000000000000000000000000000000000000000;
    address public constant NEXO_ETH_A_URN            = 0x0000000000000000000000000000000000000000;
    address public constant MCD_JOIN_ETH_A            = 0x0000000000000000000000000000000000000000;
    address public constant NEXO_WBTC_A_URN            = 0x0000000000000000000000000000000000000000;
    address public constant MCD_JOIN_WBTC_A            = 0x0000000000000000000000000000000000000000;

    function migrate(
        address gem,
        bytes32 oldIlk,
        bytes32 ilk,
        address oldUrn,
        address oldAdapter,
        address adapter
    ) internal {
        // Note: this assumes we migrate the entire vault, otherwise we need to calculate _getWipeDart
        (uint256 ink, uint256 art) = VatLike(MCD_VAT).urns(oldIlk, oldUrn);

        (, uint256 oldRate,,,) = VatLike(MCD_VAT).ilks(oldIlk);
        (, uint256 rate,,,) = VatLike(MCD_VAT).ilks(ilk);

        int256  dart = int256(_mul(oldRate, art) / rate);
        uint256 dec = TokenLike(gem).decimals();
        uint256 gemAmt = ink / (10 ** (18 - dec));

        VatLike(MCD_VAT).grab(oldIlk, oldUrn, address(this), MCD_VOW, -int256(ink), -int256(art));
        GemJoinLike(oldAdapter).exit(address(this), gemAmt);
        TokenLike(gem).approve(MCD_CHARTER_MANAGER, gemAmt);
        CharterManagerLike(MCD_CHARTER_MANAGER).join(adapter, NEXO, gemAmt);
        VatLike(MCD_VAT).grab(
            ilk,
            CharterManagerLike(MCD_CHARTER_MANAGER).getOrCreateProxy(NEXO),
            CharterManagerLike(MCD_CHARTER_MANAGER).getOrCreateProxy(NEXO),
            MCD_VOW,
            int256(ink),
            dart
        );
    }

    function actions() public override {

        // INST-ETH-A
        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_INST_ETH_A, 90 seconds, 9900);

        CollateralOpts memory INST_ETH_A = CollateralOpts({
            ilk:                   "INST-ETH-A",
            gem:                   ETH_GEM,
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
        DssExecLib.setIlkAutoLineParameters("INST-ETH-A", 900 * MILLION, 50 * MILLION, 8 hours);

        GemJoinLike(MCD_JOIN_INST_ETH_A).rely(MCD_CHARTER_MANAGER);
        CharterManagerLike(MCD_CHARTER_MANAGER).file("INST-ETH-A", "gate", 1);
        CharterManagerLike(MCD_CHARTER_MANAGER).file("INST-ETH-A", NEXO, "nib", 1 * WAD / 100); // 1%
        CharterManagerLike(MCD_CHARTER_MANAGER).file("INST-ETH-A", NEXO, "peace", 150 * RAY / 100); // 150%
        CharterManagerLike(MCD_CHARTER_MANAGER).file("INST-ETH-A", NEXO, "uline", 900 * MILLION * RAD);

        migrate(
            ETH_GEM,
            "ETH-A",
            "INST-ETH-A",
            NEXO_ETH_A_URN,
            MCD_JOIN_ETH_A,
            MCD_JOIN_INST_ETH_A
        );

        // INST-WBTC-A
        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_INST_WBTC_A, 90 seconds, 9900);

        CollateralOpts memory INST_WBTC_A = CollateralOpts({
            ilk:                   "INST-WBTC-A",
            gem:                   WBTC_GEM,
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
        DssExecLib.setIlkAutoLineParameters("INST-WBTC-A", 600 * MILLION, 50 * MILLION, 8 hours);

        GemJoinLike(MCD_JOIN_INST_WBTC_A).rely(MCD_CHARTER_MANAGER);
        CharterManagerLike(MCD_CHARTER_MANAGER).file("INST-WBTC-A", "gate", 1);
        CharterManagerLike(MCD_CHARTER_MANAGER).file("INST-WBTC-A", NEXO, "nib", 1 * WAD / 100); // 1%
        CharterManagerLike(MCD_CHARTER_MANAGER).file("INST-WBTC-A", NEXO, "peace", 150 * RAY / 100); // 150%
        CharterManagerLike(MCD_CHARTER_MANAGER).file("INST-WBTC-A", NEXO, "uline", 600 * MILLION * RAD);

        migrate(
            ETH_GEM,
            "WBTC-A",
            "INST-WBTC-A",
            NEXO_WBTC_A_URN,
            MCD_JOIN_WBTC_A,
            MCD_JOIN_INST_WBTC_A
        );

        // Changelog
        DssExecLib.setChangelogAddress("MCD_CHARTER_MANAGER", MCD_CHARTER_MANAGER);
        DssExecLib.setChangelogVersion("1.9.8");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
