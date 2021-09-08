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
import "dss-interfaces/dss/GemJoinAbstract.sol";
import "dss-interfaces/dss/OsmAbstract.sol";
import "dss-interfaces/dss/IlkRegistryAbstract.sol";
import "dss-interfaces/dapp/DSTokenAbstract.sol";

interface Initializable {
    function init(bytes32) external;
}

interface Hopeable {
    function hope(address) external;
}

interface Kissable {
    function kiss(address) external;
}

interface DssVestLike {
    function create(address, uint256, uint256, uint256, uint256, address) external returns (uint256);
    function file(bytes32, uint256) external;
}

interface RwaLiquidationLike {
    function ilks(bytes32) external returns (string memory,address,uint48,uint48);
    function init(bytes32, uint256, string calldata, uint48) external;
}

interface RwaOutputConduitLike {
    function kiss(address) external;
}

struct CentrifugeCollateralValues {
    // mip21 addresses
    address MCD_JOIN;
    address GEM;
    address OPERATOR; // MGR
    address INPUT_CONDUIT; // MGR
    address OUTPUT_CONDUIT; // MGR
    address URN;

    // changelog ids
    bytes32 gemID;
    bytes32 joinID;
    bytes32 urnID;
    bytes32 inputConduitID;
    bytes32 outputConduitID;
    bytes32 pipID;

    // misc
    bytes32 ilk;
    string ilk_string;
    string ilkRegistryName;
    uint256 RATE;
    uint256 CEIL;
    uint256 PRICE;
    uint256 MAT;
    uint48 TAU;
    string DOC;
}

contract DssSpellAction is DssAction {

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/TODO -q -O - 2>/dev/null)"
    string public constant override description = "Goerli Spell";

    address constant MCD_VEST_DAI = 0x59B1a603cAC9e38EA2AC2C479FFE42Ce48123Fd4;
    address constant MCD_VEST_MKR = 0x183bE7a75B8b5F35236270b060e95C65D82f5fF9;

    uint256 constant TWO_PCT            = 1000000000627937192491029810;
    uint256 constant THREE_PT_FIVE_PCT  = 1000000001090862085746321732;
    uint256 constant FOUR_PT_FIVE_PCT   = 1000000001395766281313196627;
    uint256 constant FIVE_PCT           = 1000000001547125957863212448;
    uint256 constant SIX_PCT            = 1000000001847694957439350562;
    uint256 constant SEVEN_PCT          = 1000000002145441671308778766;

    uint256 constant MILLION = 10 ** 6;
    uint256 constant WAD     = 10 ** 18;

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {
        // Setup both DssVest modules
        DssExecLib.authorize(DssExecLib.vat(), MCD_VEST_DAI);
        DssExecLib.authorize(DssExecLib.getChangelogAddress("GOV_GUARD"), MCD_VEST_MKR);
        DssVestLike(MCD_VEST_DAI).file("cap", 1 * MILLION * WAD / 30 days);
        DssVestLike(MCD_VEST_MKR).file("cap", 1_100 * WAD / 365 days);
        DssExecLib.setChangelogAddress("MCD_VEST_DAI", MCD_VEST_DAI);
        DssExecLib.setChangelogAddress("MCD_VEST_MKR", MCD_VEST_MKR);

        // Set testing vestings
        DssVestLike(MCD_VEST_DAI).create(address(this), WAD     , block.timestamp - 1 days, 1 days, 0, address(0));
        DssVestLike(MCD_VEST_MKR).create(address(this), WAD / 10, block.timestamp - 1 days, 1 days, 0, address(0));

        // Add Centrifuge RWA ilks
        CentrifugeCollateralValues memory RWA002 = CentrifugeCollateralValues({
            MCD_JOIN: 0xc0aeE42b5E77e931BAfd98EAdd321e704fD7CA1f,
            GEM: 0x09fE0aE289553010D6EcBdFF98cc9C08030dE3b8,
            OPERATOR: 0x1d3402B809095c3320296f3A77c4be20C3b74d47,
            INPUT_CONDUIT: 0x1d3402B809095c3320296f3A77c4be20C3b74d47,
            OUTPUT_CONDUIT: 0x1d3402B809095c3320296f3A77c4be20C3b74d47,
            URN: 0xD6953949b2B4Ab5Be19ed6283F4ca0AaEDDffec5,
            gemID: "RWA002",
            joinID: "MCD_JOIN_RWA002_A",
            urnID: "RWA002_A_URN",
            inputConduitID: "RWA002_A_INPUT_CONDUIT",
            outputConduitID: "RWA002_A_OUTPUT_CONDUIT",
            pipID: "PIP_RWA002",
            ilk: "RWA002-A",
            ilk_string: "RWA002",
            ilkRegistryName: "RWA002-A: Centrifuge: New Silver",
            RATE: THREE_PT_FIVE_PCT,
            CEIL: 20 * MILLION,
            PRICE: 22_495_725 * WAD,
            MAT: 10_500,
            TAU: 0,
            DOC: "QmdfuQSLmNFHoxvMjXvv8qbJ2NWprrsvp5L3rGr3JHw18E"
        });
        CentrifugeCollateralValues memory RWA003 = CentrifugeCollateralValues({
            MCD_JOIN: 0x83fA1F7c423112aBC6B340e32564460eDcf6AD74,
            GEM: 0x5cf15Cc2710aFc0EaBBD7e045f84F9556B204331,
            OPERATOR: 0x608050Cb6948A9835442E24a5B1964F76fd4acE4,
            INPUT_CONDUIT: 0x608050Cb6948A9835442E24a5B1964F76fd4acE4,
            OUTPUT_CONDUIT: 0x608050Cb6948A9835442E24a5B1964F76fd4acE4,
            URN: 0x438262Eb709d47b0B3d2524E75E63DBa9571962B,
            gemID: "RWA003",
            joinID: "MCD_JOIN_RWA003_A",
            urnID: "RWA003_A_URN",
            inputConduitID: "RWA003_A_INPUT_CONDUIT",
            outputConduitID: "RWA003_A_OUTPUT_CONDUIT",
            pipID: "PIP_RWA003",
            ilk: "RWA003-A",
            ilk_string: "RWA003",
            ilkRegistryName: "RWA003-A: Centrifuge: ConsolFreight",
            RATE: SIX_PCT,
            CEIL: 2 * MILLION,
            PRICE: 2_359_560 * WAD,
            MAT: 10_500,
            TAU: 0,
            DOC: "QmQMNfSbGS8qkJbatQgxMUsz27G8YELWgtXeLs8uFCZoY8"
        });
        CentrifugeCollateralValues memory RWA004 = CentrifugeCollateralValues({
            MCD_JOIN: 0xA74036937413B799b2f620a3b6Ea61ad08F1D354,
            GEM: 0xA7fbA77c4d18e12d1F385E2dcFfb377c9dBD91d2,
            OPERATOR: 0x551837D1C1638944A97a6476ffCD1bE4E1391Fc9,
            INPUT_CONDUIT: 0x551837D1C1638944A97a6476ffCD1bE4E1391Fc9,
            OUTPUT_CONDUIT: 0x551837D1C1638944A97a6476ffCD1bE4E1391Fc9,
            URN: 0x1527A3B844ca194783BDeab8DF4F9264D1A9F529,
            gemID: "RWA004",
            joinID: "MCD_JOIN_RWA004_A",
            urnID: "RWA004_A_URN",
            inputConduitID: "RWA004_A_INPUT_CONDUIT",
            outputConduitID: "RWA004_A_OUTPUT_CONDUIT",
            pipID: "PIP_RWA004",
            ilk: "RWA004-A",
            ilk_string: "RWA004",
            ilkRegistryName: "RWA004-A: Centrifuge: Harbor Trade Credit",
            RATE: SEVEN_PCT,
            CEIL: 7 * MILLION,
            PRICE: 8_815_730 * WAD,
            MAT: 11_000,
            TAU: 0,
            DOC: "QmYR2PXwLpdXS8Vp1yS39SPFT1XhmgbsK6XvZ9ApRpNV8M"
        });
        CentrifugeCollateralValues memory RWA005 = CentrifugeCollateralValues({
            MCD_JOIN: 0xc5052A70e00983ffa6894679f1d9c0cDAFe28416,
            GEM: 0x650d168fC94B79Bb16898CAae773B0Ce1097Cc3F,
            OPERATOR: 0x8347e6e08cAF1FB63428465b76BafD4Cf6fcA2e1,
            INPUT_CONDUIT: 0x8347e6e08cAF1FB63428465b76BafD4Cf6fcA2e1,
            OUTPUT_CONDUIT: 0x8347e6e08cAF1FB63428465b76BafD4Cf6fcA2e1,
            URN: 0x047E68a3c1F22f9BB3fB063b311dC76c6E308404,
            gemID: "RWA005",
            joinID: "MCD_JOIN_RWA005_A",
            urnID: "RWA005_A_URN",
            inputConduitID: "RWA005_A_INPUT_CONDUIT",
            outputConduitID: "RWA005_A_OUTPUT_CONDUIT",
            pipID: "PIP_RWA005",
            ilk: "RWA005-A",
            ilk_string: "RWA005",
            ilkRegistryName: "RWA005-A: Centrifuge: Fortunafi",
            RATE: FOUR_PT_FIVE_PCT,
            CEIL: 15 * MILLION,
            PRICE: 17_199_394 * WAD,
            MAT: 10_500,
            TAU: 0,
            DOC: "QmbgDoPn6UcfSDENDqHLgatMFoqXikC8E8it9WaZXyLXmc"
        });
        CentrifugeCollateralValues memory RWA006 = CentrifugeCollateralValues({
            MCD_JOIN: 0x5b4B7797FC41123578718AD4E3F04d1Bde9685DC,
            GEM: 0xf754FD6611852eE94AC0614c51B8692cAE9fEe9F,
            OPERATOR: 0xd2Ef07535267D17d2314894f7821A43e9700A02e,
            INPUT_CONDUIT: 0xd2Ef07535267D17d2314894f7821A43e9700A02e,
            OUTPUT_CONDUIT: 0xd2Ef07535267D17d2314894f7821A43e9700A02e,
            URN: 0xd0d2Ef46b64C07b5Ce4f2634a82984C1B3804C22,
            gemID: "RWA006",
            joinID: "MCD_JOIN_RWA006_A",
            urnID: "RWA006_A_URN",
            inputConduitID: "RWA006_A_INPUT_CONDUIT",
            outputConduitID: "RWA006_A_OUTPUT_CONDUIT",
            pipID: "PIP_RWA006",
            ilk: "RWA006-A",
            ilk_string: "RWA006",
            ilkRegistryName: "RWA006-A: Centrifuge: Alternative Equity Advisers",
            RATE: TWO_PCT,
            CEIL: 20 * MILLION,
            PRICE: 20_808_000 * WAD,
            MAT: 10_000,
            TAU: 0,
            DOC: ""
        });

        CentrifugeCollateralValues[5] memory collaterals = [RWA002, RWA003, RWA004, RWA005, RWA006];

        // Integrate RWA002-006
        for (uint i = 0; i < collaterals.length; i++) {
            integrateCentrifugeCollateral(collaterals[i]);
        }

        // Other minor stuff done in mainnet
        DssExecLib.setIlkStabilityFee("ETH-B", FIVE_PCT, true);

        DssExecLib.setIlkAutoLineDebtCeiling("LRC-A", 1 * MILLION);

        DssExecLib.setValue(DssExecLib.getChangelogAddress("MCD_PSM_USDC_A"), "tin", 2 * WAD / 1000);

        DssExecLib.setIlkLiquidationRatio("ETH-A", 14500);
        DssExecLib.setIlkLiquidationRatio("WBTC-A", 14500);
        DssExecLib.setIlkLiquidationRatio("ETH-C", 17000);
        DssExecLib.setIlkLiquidationRatio("LINK-A", 16500);
        DssExecLib.setIlkLiquidationRatio("UNIV2DAIETH-A", 12000);
        DssExecLib.setIlkLiquidationRatio("YFI-A", 16500);
        DssExecLib.setIlkLiquidationRatio("UNIV2WBTCETH-A", 14500);
        DssExecLib.setIlkLiquidationRatio("UNIV2UNIETH-A", 16000);
        DssExecLib.setIlkLiquidationRatio("UNIV2USDCETH-A", 12000);
        DssExecLib.setIlkLiquidationRatio("RENBTC-A", 16500);
        DssExecLib.setIlkLiquidationRatio("UNI-A", 16500);
        DssExecLib.setIlkLiquidationRatio("AAVE-A", 16500);
        DssExecLib.setIlkLiquidationRatio("UNIV2WBTCDAI-A", 12000);
        DssExecLib.setIlkLiquidationRatio("BAL-A", 16500);
        DssExecLib.setIlkLiquidationRatio("COMP-A", 16500);

        DssExecLib.increaseIlkDebtCeiling("PSM-PAX-A", 450 * MILLION, true);

        DssExecLib.setValue(DssExecLib.getChangelogAddress("MCD_FLASH"), "toll", 0);
        //

        // Rely Oracles team address in all the medians except MATIC that was created by them
        DssExecLib.authorize(OsmAbstract(DssExecLib.getChangelogAddress("PIP_ETH")).src(),  0x1f42e41A34B71606FcC60b4e624243b365D99745);
        DssExecLib.authorize(OsmAbstract(DssExecLib.getChangelogAddress("PIP_BAT")).src(),  0x1f42e41A34B71606FcC60b4e624243b365D99745);
        DssExecLib.authorize(OsmAbstract(DssExecLib.getChangelogAddress("PIP_WBTC")).src(), 0x1f42e41A34B71606FcC60b4e624243b365D99745);
        DssExecLib.authorize(OsmAbstract(DssExecLib.getChangelogAddress("PIP_ZRX")).src(),  0x1f42e41A34B71606FcC60b4e624243b365D99745);
        DssExecLib.authorize(OsmAbstract(DssExecLib.getChangelogAddress("PIP_KNC")).src(),  0x1f42e41A34B71606FcC60b4e624243b365D99745);
        DssExecLib.authorize(OsmAbstract(DssExecLib.getChangelogAddress("PIP_MANA")).src(), 0x1f42e41A34B71606FcC60b4e624243b365D99745);
        DssExecLib.authorize(OsmAbstract(DssExecLib.getChangelogAddress("PIP_USDT")).src(), 0x1f42e41A34B71606FcC60b4e624243b365D99745);
        DssExecLib.authorize(OsmAbstract(DssExecLib.getChangelogAddress("PIP_COMP")).src(), 0x1f42e41A34B71606FcC60b4e624243b365D99745);
        DssExecLib.authorize(OsmAbstract(DssExecLib.getChangelogAddress("PIP_LRC")).src(),  0x1f42e41A34B71606FcC60b4e624243b365D99745);
        DssExecLib.authorize(OsmAbstract(DssExecLib.getChangelogAddress("PIP_LINK")).src(), 0x1f42e41A34B71606FcC60b4e624243b365D99745);
        DssExecLib.authorize(OsmAbstract(DssExecLib.getChangelogAddress("PIP_BAL")).src(),  0x1f42e41A34B71606FcC60b4e624243b365D99745);
        DssExecLib.authorize(OsmAbstract(DssExecLib.getChangelogAddress("PIP_YFI")).src(),  0x1f42e41A34B71606FcC60b4e624243b365D99745);
        DssExecLib.authorize(OsmAbstract(DssExecLib.getChangelogAddress("PIP_UNI")).src(),  0x1f42e41A34B71606FcC60b4e624243b365D99745);
        DssExecLib.authorize(OsmAbstract(DssExecLib.getChangelogAddress("PIP_AAVE")).src(), 0x1f42e41A34B71606FcC60b4e624243b365D99745);

        // Bump changelog version
        DssExecLib.setChangelogVersion("1.9.5");
    }

    function integrateCentrifugeCollateral(CentrifugeCollateralValues memory collateral) internal {
        address MIP21_LIQUIDATION_ORACLE =
            DssExecLib.getChangelogAddress("MIP21_LIQUIDATION_ORACLE");

        address vat = DssExecLib.vat();

        // Sanity checks
        require(GemJoinAbstract(collateral.MCD_JOIN).vat() == vat, "join-vat-not-match");
        require(GemJoinAbstract(collateral.MCD_JOIN).ilk() == collateral.ilk, "join-ilk-not-match");
        require(GemJoinAbstract(collateral.MCD_JOIN).gem() == collateral.GEM, "join-gem-not-match");
        require(GemJoinAbstract(collateral.MCD_JOIN).dec() == DSTokenAbstract(collateral.GEM).decimals(), "join-dec-not-match");

        RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).init(
            collateral.ilk, collateral.PRICE, collateral.DOC, collateral.TAU
        );
        (,address pip,,) = RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).ilks(collateral.ilk);

        // Set price feed for RWA-00x
        DssExecLib.setContract(DssExecLib.spotter(), collateral.ilk, "pip", pip);

        // Init RWA-00x in Vat
        Initializable(vat).init(collateral.ilk);
        // Init RWA-00x in Jug
        Initializable(DssExecLib.jug()).init(collateral.ilk);

        // Allow RWA-00x Join to modify Vat registry
        DssExecLib.authorize(vat, collateral.MCD_JOIN);

        // Set ilk/global DC
        DssExecLib.increaseIlkDebtCeiling(collateral.ilk, collateral.CEIL, true);

        // Set stability fee
        DssExecLib.setIlkStabilityFee(collateral.ilk, collateral.RATE, false);

        // Set collateralization ratio
        DssExecLib.setIlkLiquidationRatio(collateral.ilk, collateral.MAT);

        // Poke the spotter to pull in a price
        DssExecLib.updateCollateralPrice(collateral.ilk);

        // Set up the urn
        Hopeable(collateral.URN).hope(collateral.OPERATOR);

        // Add RWA-00x contract to the changelog
        DssExecLib.setChangelogAddress(collateral.gemID, collateral.GEM);
        DssExecLib.setChangelogAddress(collateral.pipID, pip);
        DssExecLib.setChangelogAddress(collateral.joinID, collateral.MCD_JOIN);
        DssExecLib.setChangelogAddress(collateral.urnID, collateral.URN);
        DssExecLib.setChangelogAddress(
            collateral.inputConduitID, collateral.INPUT_CONDUIT
        );
        DssExecLib.setChangelogAddress(
            collateral.outputConduitID, collateral.OUTPUT_CONDUIT
        );

        // Add RWA-00x to the ilk registry
        address ILK_REGISTRY = DssExecLib.getChangelogAddress("ILK_REGISTRY");
        IlkRegistryAbstract(ILK_REGISTRY).put(
            collateral.ilk,
            collateral.MCD_JOIN,
            collateral.GEM,
            DSTokenAbstract(collateral.GEM).decimals(),
            3,
            pip,
            address(0),
            collateral.ilkRegistryName,
            collateral.ilk_string
        );
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
