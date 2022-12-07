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
pragma experimental ABIEncoderV2;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

interface Initializable {
    function init(bytes32) external;
}

interface GemLike {
    function transfer(address, uint256) external returns (bool);
    function decimals() external view returns (uint8);
}

interface GemJoinLike {
    function rely(address) external;
    function vat() external view returns (address);
    function ilk() external view returns (bytes32);
    function gem() external view returns (address);
    function dec() external view returns (uint256);
}

interface IlkRegistryLike {
    function put(bytes32, address, address, uint256, uint256, address, address, string calldata, string calldata) external;
}

interface VatLike {
    function ilks(bytes32) external view returns (uint256, uint256, uint256, uint256, uint256);
    function Line() external view returns (uint256);
}

interface RwaLiquidationLike {
    function ilks(bytes32) external returns (string memory,address,uint48,uint48);
    function init(bytes32, uint256, string calldata, uint48) external;
}

interface RwaUrnLike {
    function daiJoin() external view returns(address);
    function gemJoin() external view returns(address);
    function hope(address) external;
    function jug() external view returns(address);
    function outputConduit() external view returns(address);
    function vat() external view returns(address);
}

interface TinlakeManagerLike {
    function file(bytes32, address) external;
    function dai() external view returns (address);
    function daiJoin() external view returns (address);
    function end() external view returns (address);
    function liq() external view returns (address);
    function lock(uint256) external;
    function owner() external view returns (address);
    function pool() external view returns (address);
    function tranche() external view returns (address);
    function urn() external view returns (address);
    function vat() external view returns (address);
    function vow() external view returns (address);
    function gem() external view returns (address);
}

interface StarknetLike {
    function setCeiling(uint256) external;
    function setMaxDeposit(uint256) external;
}

struct CentrifugeCollateralValues {
    // MIP21 addresses
    address GEM_JOIN;
    address GEM;
    address OPERATOR;       // MGR
    address INPUT_CONDUIT;  // MGR
    address OUTPUT_CONDUIT; // MGR
    address URN;

    // Centrifuge addresses
    address DROP;
    address OWNER;
    address POOL;
    address TRANCHE;
    address ROOT;

    // Changelog keys
    bytes32 gemID;
    bytes32 joinID;
    bytes32 urnID;
    bytes32 inputConduitID;
    bytes32 outputConduitID;
    bytes32 pipID;

    // Misc
    bytes32 ilk;
    string  ilkString;
    string  ilkRegistryName;
    uint256 RATE;
    uint256 CEIL;
    uint256 PRICE;
    uint256 MAT;
    uint48  TAU;
    string  DOC;
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
    uint256 internal constant ONE_PCT_RATE      = 1000000000315522921573372069;
    uint256 internal constant TWO_FIVE_PCT_RATE = 1000000000782997609082909351;
    uint256 internal constant FOUR_PCT_RATE     = 1000000001243680656318820312;

    // --- MATH ---
    uint256 internal constant MILLION = 10 ** 6;
    uint256 internal constant WAD     = 10 ** 18;
    uint256 internal constant RAY     = 10 ** 27;

    uint256 internal constant PSM_TEN_BASIS_POINTS = 10 * WAD / 10000;

    function _sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    address internal immutable DAI            = DssExecLib.dai();
    address internal immutable DAI_JOIN       = DssExecLib.daiJoin();
    address internal immutable END            = DssExecLib.end();
    address internal immutable JUG            = DssExecLib.jug();
    address internal immutable SPOTTER        = DssExecLib.spotter();
    address internal immutable VAT            = DssExecLib.vat();
    address internal immutable VOW            = DssExecLib.vow();
    address internal immutable ILK_REG        = DssExecLib.getChangelogAddress("ILK_REGISTRY");
    address internal immutable MCD_PSM_GUSD_A = DssExecLib.getChangelogAddress("MCD_PSM_GUSD_A");
    address internal immutable MCD_PSM_PAX_A  = DssExecLib.getChangelogAddress("MCD_PSM_PAX_A");
    address internal immutable ORACLE         = DssExecLib.getChangelogAddress("MIP21_LIQUIDATION_ORACLE");
    address internal immutable STARKNET_DAI_BRIDGE = DssExecLib.getChangelogAddress("STARKNET_DAI_BRIDGE");

    // --- Ilk Registry ---
    uint256 internal constant REG_RWA_CLASS = 3;

    // --- DEPLOYED COLLATERAL ADDRESSES ---
    address internal constant GNO                     = 0x86Bc432064d7F933184909975a384C7E4c9d0977;
    address internal constant PIP_GNO                 = 0xf15221A159A4e7ba01E0d6e72111F0Ddff8Fa8Da;
    address internal constant MCD_JOIN_GNO_A          = 0x05a3b9D5F8098e558aF33c6b83557484f840055e;
    address internal constant MCD_CLIP_GNO_A          = 0x8274F3badD42C61B8bEa78Df941813D67d1942ED;
    address internal constant MCD_CLIP_CALC_GNO_A     = 0x08Ae3e0C0CAc87E1B4187D53F0231C97B5b4Ab3E;

    address internal constant MCD_JOIN_RWA010_A       = 0xeBAfcf1E0B1A6D0F91f41cD77d760AC56B431F05;
    address internal constant RWA010                  = 0x003DD0D987a315C7AEe2611B9b753b383B7a35bF;
    address internal constant RWA010_A_URN            = 0x59417853EA7B47017c1e2C644C848e8Ef99Afa51;
    address internal constant RWA010_A_OPERATOR       = 0x8828D2B96fa09864851244a8a2434C5A9a7B7AbD; // Tinlake Manager
    address internal constant RWA010_A_INPUT_CONDUIT  = 0x8828D2B96fa09864851244a8a2434C5A9a7B7AbD; // Tinlake Manager
    address internal constant RWA010_A_OUTPUT_CONDUIT = 0x8828D2B96fa09864851244a8a2434C5A9a7B7AbD; // Tinlake Manager
    string  internal constant RWA010_A_DOC            = "QmRqsQRnLfaRuhFr5wCfDQZKzNo7FRVUyTJPhS76nfz6nX";

    address internal constant MCD_JOIN_RWA011_A       = 0xfc1b3879B259C3561F4E654759D2Fd6Ba3C995de;
    address internal constant RWA011                  = 0x480e01A3621f557D99c75C4394Ac17238304e88C;
    address internal constant RWA011_A_URN            = 0x5A704B28d65a61E1070662B8cA353D260f36332E;
    address internal constant RWA011_A_OPERATOR       = 0xcBd44c9Ec0D2b9c466887e700eD88D302281E098; // Tinlake Manager
    address internal constant RWA011_A_INPUT_CONDUIT  = 0xcBd44c9Ec0D2b9c466887e700eD88D302281E098; // Tinlake Manager
    address internal constant RWA011_A_OUTPUT_CONDUIT = 0xcBd44c9Ec0D2b9c466887e700eD88D302281E098; // Tinlake Manager
    string  internal constant RWA011_A_DOC            = "QmRqsQRnLfaRuhFr5wCfDQZKzNo7FRVUyTJPhS76nfz6nX";

    address internal constant MCD_JOIN_RWA012_A       = 0x0D9a5a31f16164e256E4f8b616c9C57F9d5C12d7;
    address internal constant RWA012                  = 0x2E4378eF2A6822cfB0d154BA497B351e31C3B89b;
    address internal constant RWA012_A_URN            = 0xa35F51d91311F60C904a02E1b0493Fc256A3F6e3;
    address internal constant RWA012_A_OPERATOR       = 0xaef64c80712d5959f240BE1339aa639CDFA858Ff; // Tinlake Manager
    address internal constant RWA012_A_INPUT_CONDUIT  = 0xaef64c80712d5959f240BE1339aa639CDFA858Ff; // Tinlake Manager
    address internal constant RWA012_A_OUTPUT_CONDUIT = 0xaef64c80712d5959f240BE1339aa639CDFA858Ff; // Tinlake Manager
    string  internal constant RWA012_A_DOC            = "QmRqsQRnLfaRuhFr5wCfDQZKzNo7FRVUyTJPhS76nfz6nX";

    address internal constant MCD_JOIN_RWA013_A       = 0xD67131c06e93eDF3839C3ec5Bd92FF5D93A1e3df;
    address internal constant RWA013                  = 0xc5Ac8B809a8De11D94b7Aa63b28b8fbBDF86Ea86;
    address internal constant RWA013_A_URN            = 0xdC47d203753D3B5fb4fcD5900EBd96b0eC6761B6;
    address internal constant RWA013_A_OPERATOR       = 0xc5A1418aC32B5f978460f1211B76B5D44e69B530; // Tinlake Manager
    address internal constant RWA013_A_INPUT_CONDUIT  = 0xc5A1418aC32B5f978460f1211B76B5D44e69B530; // Tinlake Manager
    address internal constant RWA013_A_OUTPUT_CONDUIT = 0xc5A1418aC32B5f978460f1211B76B5D44e69B530; // Tinlake Manager
    string  internal constant RWA013_A_DOC            = "QmRqsQRnLfaRuhFr5wCfDQZKzNo7FRVUyTJPhS76nfz6nX";

    function actions() public override {

        // Delegate Compensation - November 2022
        // https://forum.makerdao.com/t/recognized-delegate-compensation-november-2022/19012
        // NOT ON GOERLI


        // Tech-Ops MKR Transfer
        // https://mips.makerdao.com/mips/details/MIP40c3SP54
        // NOT ON GOERLI


        // MOMC Parameter Changes
        // https://vote.makerdao.com/polling/QmVXj9cW

        // Increase WSTETH-A line from 150 million DAI to 500 million DAI
        // Reduce WSTETH-A gap from 30 million DAI to 15 million DAI
        DssExecLib.setIlkAutoLineParameters("WSTETH-A", 500 * MILLION, 15 * MILLION, 6 hours);
        // Increase WSTETH-B line from 200 million DAI to 500 million DAI
        // Reduce WSTETH-B gap from 30 million DAI to 15 million DAI
        DssExecLib.setIlkAutoLineParameters("WSTETH-B", 500 * MILLION, 15 * MILLION, 8 hours);
        // Reduce ETH-B line from 500 million to 250 million DAI
        DssExecLib.setIlkAutoLineDebtCeiling("ETH-B", 250 * MILLION);
        // Reduce WBTC-A line from 2 billion DAI to 500 million DAI
        // Reduce WBTC-A gap from 80 million DAI to 20 million DAI
        // Increase WBTC-A ttl from 6 hours to 24 hours
        DssExecLib.setIlkAutoLineParameters("WBTC-A", 500 * MILLION, 20 * MILLION, 24 hours);
        // Reduce WBTC-B line from 500 million DAI to 250 million DAI
        // Reduce WBTC-B gap from 30 million DAI to 10 million DAI
        // Increase WBTC-B ttl from 8 hours to 24 hours
        DssExecLib.setIlkAutoLineParameters("WBTC-B", 250 * MILLION, 10 * MILLION, 24 hours);
        // Reduce WBTC-C line from 1 billion DAI to 500 million DAI
        // Reduce WBTC-C gap from 100 million DAI to 20 million DAI
        // Increase WBTC-C ttl from 8 hours to 24 hours
        DssExecLib.setIlkAutoLineParameters("WBTC-C", 500 * MILLION, 20 * MILLION, 24 hours);
        // Reduce MANA-A line from 1 million DAI to 0 DAI
        bytes32 _ilk = "MANA-A";
        DssExecLib.removeIlkFromAutoLine(_ilk);
        (,,, uint256 _line,) = VatLike(VAT).ilks(_ilk);
        DssExecLib.setValue(VAT, _ilk, "line", 0);
        DssExecLib.setValue(VAT, "Line", _sub(VatLike(VAT).Line(), _line));
        // Reduce GUNIV3DAIUSDC1-A line from 1 billion DAI to 100 million DAI
        DssExecLib.setIlkAutoLineDebtCeiling("GUNIV3DAIUSDC1-A", 100 * MILLION);
        // Reduce GUNIV3DAIUSDC2-A line from 1.25 billion DAI to 100 million DAI
        DssExecLib.setIlkAutoLineDebtCeiling("GUNIV3DAIUSDC2-A", 100 * MILLION);
        // Reduce the UNIV2DAIUSDC-A line from 300 million DAI to 100 million DAI
        DssExecLib.setIlkAutoLineDebtCeiling("UNIV2DAIUSDC-A", 100 * MILLION);
        // Reduce the PSM-USDP-A line from 500 million DAI to 450 million DAI
        DssExecLib.setIlkAutoLineDebtCeiling("PSM-PAX-A", 450 * MILLION);
        // Reduce LINK-A gap from 7 million DAI to 2.5 million DAI
        DssExecLib.setIlkAutoLineParameters("LINK-A", 5 * MILLION, 2_500_000, 8 hours);
        // Reduce YFI-A gap from 7 million DAI to 1.5 million DAI
        DssExecLib.setIlkAutoLineParameters("YFI-A", 3 * MILLION, 1_500_000, 8 hours);


        // PSM tin increases
        // Increase PSM-USDP-A tin from 0% to 0.1%
        DssExecLib.setValue(MCD_PSM_PAX_A, "tin", PSM_TEN_BASIS_POINTS);
        // Increase PSM-GUSD-A tin from 0% to 0.1%
        DssExecLib.setValue(MCD_PSM_GUSD_A, "tin", PSM_TEN_BASIS_POINTS);

        // PSM tout decrease
        // Reduce PSM-GUSD-A tout from 0.2% to 0.1%
        DssExecLib.setValue(MCD_PSM_GUSD_A, "tout", PSM_TEN_BASIS_POINTS);


        // DSR Adjustment
        // https://vote.makerdao.com/polling/914#vote-breakdown
        // Increase the DSR to 1%
        DssExecLib.setDSR(ONE_PCT_RATE, true);

        // ----------------------------- Collateral onboarding -----------------------------
        //  Add GNO-A as a new Vault Type
        //  Poll Link:   https://vote.makerdao.com/polling/QmUBoGiu
        //  Forum Post:  https://forum.makerdao.com/t/gno-collateral-onboarding-risk-evaluation/18820

        DssExecLib.addNewCollateral(
            CollateralOpts({
                ilk:                  "GNO-A",
                gem:                  GNO,
                join:                 MCD_JOIN_GNO_A,
                clip:                 MCD_CLIP_GNO_A,
                calc:                 MCD_CLIP_CALC_GNO_A,
                pip:                  PIP_GNO,
                isLiquidatable:       true,
                isOSM:                true,
                whitelistOSM:         true,
                ilkDebtCeiling:       3_000_000,         // line starts at IAM gap value
                minVaultAmount:       100_000,           // debt floor - dust in DAI
                maxLiquidationAmount: 2_000_000,
                liquidationPenalty:   13_00,             // 13% penalty on liquidation
                ilkStabilityFee:      TWO_FIVE_PCT_RATE, // 2.50% stability fee
                startingPriceFactor:  120_00,            // Auction price begins at 120% of oracle price
                breakerTolerance:     50_00,             // Allows for a 50% hourly price drop before disabling liquidation
                auctionDuration:      8400,
                permittedDrop:        25_00,             // 25% price drop before reset
                liquidationRatio:     350_00,            // 350% collateralization
                kprFlatReward:        250,               // 250 DAI tip - flat fee per kpr
                kprPctReward:         10                 // 0.1% chip - per kpr
            })
        );

        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_GNO_A, 60 seconds, 99_00);
        DssExecLib.setIlkAutoLineParameters("GNO-A", 5_000_000, 3_000_000, 8 hours);

        // -------------------- Changelog Update ---------------------

        DssExecLib.setChangelogAddress("GNO",                 GNO);
        DssExecLib.setChangelogAddress("PIP_GNO",             PIP_GNO);
        DssExecLib.setChangelogAddress("MCD_JOIN_GNO_A",      MCD_JOIN_GNO_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_GNO_A",      MCD_CLIP_GNO_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_GNO_A", MCD_CLIP_CALC_GNO_A);


        // RWA-010 Onboarding
        // https://vote.makerdao.com/polling/QmNucsGt
        _addCentrifugeCollateral(CentrifugeCollateralValues({
            GEM_JOIN:        MCD_JOIN_RWA010_A,
            GEM:             RWA010,
            URN:             RWA010_A_URN,
            OPERATOR:        RWA010_A_OPERATOR,
            INPUT_CONDUIT:   RWA010_A_INPUT_CONDUIT,
            OUTPUT_CONDUIT:  RWA010_A_OUTPUT_CONDUIT,
            DROP:            0xd7943e68bD284dAd75A59d07Fab7708a21B8a95E,
            OWNER:           0xa78F096D4cfc32637513e02Ddf020EFb3fFf4df1, // Tinlake Clerk
            POOL:            0xd7BD4F27302aBDB8292F534BF52e7d10dDf6A112, // Tinlake Operator
            TRANCHE:         0xe12c278c7e6c8B64E322d9cce66E2C9177051FeD, // Tinlake Tranche
            ROOT:            0xD128CB475D0716044A35866a6779CCc14E91b7b6, // Tinlake Root
            gemID:           "RWA010",
            joinID:          "MCD_JOIN_RWA010_A",
            urnID:           "RWA010_A_URN",
            inputConduitID:  "RWA010_A_INPUT_CONDUIT",
            outputConduitID: "RWA010_A_OUTPUT_CONDUIT",
            pipID:           "PIP_RWA010",
            ilk:             "RWA010-A",
            ilkString:       "RWA010",
            ilkRegistryName: "RWA010-A: Centrifuge: BlockTower Credit (I)",
            RATE:            FOUR_PCT_RATE,
            CEIL:            20_000_000,
            PRICE:           24_333_058 * WAD,
            MAT:             100_00, // Liquidation ratio
            TAU:             0,      // Remediation period
            DOC:             RWA010_A_DOC
        }));


        // RWA-011 Onboarding
        // https://vote.makerdao.com/polling/QmNucsGt
        _addCentrifugeCollateral(CentrifugeCollateralValues({
            GEM_JOIN:        MCD_JOIN_RWA011_A,
            GEM:             RWA011,
            URN:             RWA011_A_URN,
            OPERATOR:        RWA011_A_OPERATOR,
            INPUT_CONDUIT:   RWA011_A_INPUT_CONDUIT,
            OUTPUT_CONDUIT:  RWA011_A_OUTPUT_CONDUIT,
            DROP:            0xA586bB77069739Bb9Cb8608c51a21C18AF87Fb2E,
            OWNER:           0xd08822CBEfd0DD61fEc36E252311c8e08c418109, // Tinlake Clerk
            POOL:            0x747a07346f97D14A1B97f9Fee739EF99A875e716, // Tinlake Operator
            TRANCHE:         0xB4FFc4f9e70f783346eE0Bb247a2a966DA430A2F, // Tinlake Tranche
            ROOT:            0x0b55da7112dD417Fe7a900ee8e346F17E504292c, // Tinlake Root
            gemID:           "RWA011",
            joinID:          "MCD_JOIN_RWA011_A",
            urnID:           "RWA011_A_URN",
            inputConduitID:  "RWA011_A_INPUT_CONDUIT",
            outputConduitID: "RWA011_A_OUTPUT_CONDUIT",
            pipID:           "PIP_RWA011",
            ilk:             "RWA011-A",
            ilkString:       "RWA011",
            ilkRegistryName: "RWA011-A: Centrifuge: BlockTower Credit (II)",
            RATE:            FOUR_PCT_RATE,
            CEIL:            30_000_000,
            PRICE:           36_499_587 * WAD,
            MAT:             100_00, // Liquidation ratio
            TAU:             0,      // Remediation period
            DOC:             RWA011_A_DOC
        }));


        // RWA-012 Onboarding
        // https://vote.makerdao.com/polling/QmNucsGt
        _addCentrifugeCollateral(CentrifugeCollateralValues({
            GEM_JOIN:        MCD_JOIN_RWA012_A,
            GEM:             RWA012,
            URN:             RWA012_A_URN,
            OPERATOR:        RWA012_A_OPERATOR,
            INPUT_CONDUIT:   RWA012_A_INPUT_CONDUIT,
            OUTPUT_CONDUIT:  RWA012_A_OUTPUT_CONDUIT,
            DROP:            0x82b84166f7CB140A6a66308da10728a3DB3A73A4,
            OWNER:           0xEcefa3ABe2c68952627EB138dcD5F7b7b29dF999, // Tinlake Clerk
            POOL:            0x3354493615a21D544974e6665dc1851c6A117F9D, // Tinlake Operator
            TRANCHE:         0x47335Eb13a12C126272a04E48eb09FC989135de3, // Tinlake Tranche
            ROOT:            0x60b71e9DCEeDAAC275c377630E054bc60a21A02B, // Tinlake Root
            gemID:           "RWA012",
            joinID:          "MCD_JOIN_RWA012_A",
            urnID:           "RWA012_A_URN",
            inputConduitID:  "RWA012_A_INPUT_CONDUIT",
            outputConduitID: "RWA012_A_OUTPUT_CONDUIT",
            pipID:           "PIP_RWA012",
            ilk:             "RWA012-A",
            ilkString:       "RWA012",
            ilkRegistryName: "RWA012-A: Centrifuge: BlockTower Credit (III)",
            RATE:            FOUR_PCT_RATE,
            CEIL:            30_000_000,
            PRICE:           36_499_587 * WAD,
            MAT:             100_00, // Liquidation ratio
            TAU:             0,      // Remediation period
            DOC:             RWA010_A_DOC
        }));


        // RWA-013 Onboarding
        // https://vote.makerdao.com/polling/QmNucsGt
        _addCentrifugeCollateral(CentrifugeCollateralValues({
            GEM_JOIN:        MCD_JOIN_RWA013_A,
            GEM:             RWA013,
            URN:             RWA013_A_URN,
            OPERATOR:        RWA013_A_OPERATOR,
            INPUT_CONDUIT:   RWA013_A_INPUT_CONDUIT,
            OUTPUT_CONDUIT:  RWA013_A_OUTPUT_CONDUIT,
            DROP:            0x0691FAEa2Eb8eBB2C36Fc24d577cA73AfbDB7Bdd,
            OWNER:           0x116b030167Cc8A82C158f0598f4C4677f575Cc50, // Tinlake Clerk
            POOL:            0x3C05eFC8D0fC042c5686b3989bbDb1E1D29dAec7, // Tinlake Operator
            TRANCHE:         0x6A635Ada2eC663B9b38ca7a3E5c918D5D0B0E99D, // Tinlake Tranche
            ROOT:            0xCd5Cb76a0208eAbdFFC2074f32591878a10686ae, // Tinlake Root
            gemID:           "RWA013",
            joinID:          "MCD_JOIN_RWA013_A",
            urnID:           "RWA013_A_URN",
            inputConduitID:  "RWA013_A_INPUT_CONDUIT",
            outputConduitID: "RWA013_A_OUTPUT_CONDUIT",
            pipID:           "PIP_RWA013",
            ilk:             "RWA013-A",
            ilkString:       "RWA013",
            ilkRegistryName: "RWA013-A: Centrifuge: BlockTower Credit (IV)",
            RATE:            FOUR_PCT_RATE,
            CEIL:            70_000_000,
            PRICE:           85_165_703 * WAD,
            MAT:             100_00, // Liquidation ratio
            TAU:             0,      // Remediation period
            DOC:             RWA013_A_DOC
        }));


        // ----------------------------- Collateral offboarding -----------------------------
        //  Offboard RENBTC-A
        //  Poll Link:   https://vote.makerdao.com/polling/QmTNMDfb#poll-detail
        //  Forum Post:  https://forum.makerdao.com/t/renbtc-a-proposed-offboarding-parameters-context/18864

        DssExecLib.setIlkLiquidationPenalty("RENBTC-A", 0);
        DssExecLib.setKeeperIncentiveFlatRate("RENBTC-A", 0);
        // setIlkLiquidationRatio to 5000%
        // We are using low level methods because DssExecLib only allows setting `mat < 1000%`: https://github.com/makerdao/dss-exec-lib/blob/2afff4373e8a827659df28f6d349feb25f073e59/src/DssExecLib.sol#L733
        DssExecLib.setValue(DssExecLib.spotter(), "RENBTC-A", "mat", 50 * RAY); // 5000%
        DssExecLib.setIlkMaxLiquidationAmount("RENBTC-A", 350_000);
        // PIP_RENBTC `kiss` MCD_CLIP_RENBTC_A. This should not be included in mainnet spell
        DssExecLib.addReaderToWhitelist(DssExecLib.getChangelogAddress("PIP_RENBTC"), DssExecLib.getChangelogAddress("MCD_CLIP_RENBTC_A"));

        // Increase Starknet Bridge Limit from 200,000 DAI to 1,000,000 DAI
        StarknetLike(STARKNET_DAI_BRIDGE).setCeiling(1_000_000 * WAD);
        // Remove Starknet Bridge Deposit Limit
        StarknetLike(STARKNET_DAI_BRIDGE).setMaxDeposit(type(uint256).max);

        // Bump changelog
        DssExecLib.setChangelogVersion("1.14.7");
    }

    function _addCentrifugeCollateral(CentrifugeCollateralValues memory collateral) internal {
        uint256 gemDecimals = GemLike(collateral.GEM).decimals();

        // Sanity checks
        {
            GemJoinLike gemJoin = GemJoinLike(collateral.GEM_JOIN);

            require(gemJoin.vat() == VAT,            "join-vat-not-match");
            require(gemJoin.ilk() == collateral.ilk, "join-ilk-not-match");
            require(gemJoin.gem() == collateral.GEM, "join-gem-not-match");
            require(gemJoin.dec() == gemDecimals,    "join-dec-not-match");

            // Setup the gemjoin
            gemJoin.rely(collateral.URN);
        }

        {
            RwaUrnLike urn = RwaUrnLike(collateral.URN);

            require(urn.vat()           == VAT,                       "urn-vat-not-match");
            require(urn.jug()           == JUG,                       "urn-jug-not-match");
            require(urn.daiJoin()       == DAI_JOIN,                  "urn-daijoin-not-match");
            require(urn.gemJoin()       == collateral.GEM_JOIN,       "urn-gemjoin-not-match");
            require(urn.outputConduit() == collateral.OUTPUT_CONDUIT, "urn-outputconduit-not-match");

            // Set up the urn
            urn.hope(collateral.OPERATOR);
        }

        {
            TinlakeManagerLike mgr = TinlakeManagerLike(collateral.OPERATOR);

            // Constructor params
            require(mgr.dai()     == DAI,                "mgr-dai-not-match");
            require(mgr.daiJoin() == DAI_JOIN,           "mgr-daijoin-not-match");
            require(mgr.vat()     == VAT,                "mgr-vat-not-match");
            require(mgr.gem()     == collateral.DROP,    "mgr-drop-not-match");
            // Fileable constructor params
            require(mgr.vow()     == VOW,                "mgr-vow-not-match");
            require(mgr.end()     == END,                "mgr-end-not-match");
            // Fileable centrifuge-only params
            require(mgr.pool()    == collateral.POOL,    "mgr-pool-not-match");
            require(mgr.tranche() == collateral.TRANCHE, "mgr-tranche-not-match");
            require(mgr.owner()   == collateral.OWNER,   "mgr-owner-not-match");
        }

        // Initialize the liquidation oracle for RWA0XY
        RwaLiquidationLike(ORACLE).init(collateral.ilk, collateral.PRICE, collateral.DOC, collateral.TAU);
        (, address pip, , ) = RwaLiquidationLike(ORACLE).ilks(collateral.ilk);

        // Set price feed for RWA0XY
        DssExecLib.setContract(SPOTTER, collateral.ilk, "pip", pip);

        // Init RWA0XY in Vat
        Initializable(VAT).init(collateral.ilk);

        // Init RWA0XY in Jug
        Initializable(JUG).init(collateral.ilk);

        // Allow RWA0XY_JOIN to modify the Vat registry
        DssExecLib.authorize(VAT, collateral.GEM_JOIN);

        // Set ilk/global DC
        DssExecLib.increaseIlkDebtCeiling(collateral.ilk, collateral.CEIL, /* global = */ true);

        // Set stability fee
        DssExecLib.setIlkStabilityFee(collateral.ilk, collateral.RATE, /* doDrip = */ false);

        // Set liquidation ratio
        DssExecLib.setIlkLiquidationRatio(collateral.ilk, collateral.MAT);

        // Poke the spotter to pull in a price
        DssExecLib.updateCollateralPrice(collateral.ilk);

        // Transfer the RwaToken from DSPauseProxy to the operator and lock it into the urn
        GemLike(collateral.GEM).transfer(collateral.OPERATOR, 1 * WAD);
        TinlakeManagerLike(collateral.OPERATOR).lock(1 * WAD);
        // Set TinlakeManager MIP21 components
        TinlakeManagerLike(collateral.OPERATOR).file("liq", address(ORACLE));
        TinlakeManagerLike(collateral.OPERATOR).file("urn", collateral.URN);
        // Rely Tinlake Root
        DssExecLib.authorize(collateral.OPERATOR, collateral.ROOT);
        // Deny DSPauseProxy
        DssExecLib.deauthorize(collateral.OPERATOR, address(this));

        // Add RWA-00x contracts to the changelog
        DssExecLib.setChangelogAddress(collateral.gemID, collateral.GEM);
        DssExecLib.setChangelogAddress(collateral.pipID, pip);
        DssExecLib.setChangelogAddress(collateral.joinID, collateral.GEM_JOIN);
        DssExecLib.setChangelogAddress(collateral.urnID, collateral.URN);
        DssExecLib.setChangelogAddress(collateral.inputConduitID, collateral.INPUT_CONDUIT);
        DssExecLib.setChangelogAddress(collateral.outputConduitID, collateral.OUTPUT_CONDUIT);

        // Add RWA0XY to the ilk registry
        IlkRegistryLike(ILK_REG).put(
            collateral.ilk,
            collateral.GEM_JOIN,
            collateral.GEM,
            gemDecimals,
            REG_RWA_CLASS,
            pip,
            address(0),
            collateral.ilkRegistryName,
            collateral.ilkString
        );
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
