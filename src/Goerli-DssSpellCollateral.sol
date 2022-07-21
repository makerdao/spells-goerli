// SPDX-FileCopyrightText: © 2022 Dai Foundation <www.daifoundation.org>
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

import "dss-exec-lib/DssExecLib.sol";
import "dss-interfaces/dapp/DSTokenAbstract.sol";
import "dss-interfaces/dss/ChainlogAbstract.sol";
import "dss-interfaces/dss/GemJoinAbstract.sol";
import "dss-interfaces/dss/IlkRegistryAbstract.sol";
import "dss-interfaces/dss/JugAbstract.sol";
import "dss-interfaces/dss/SpotAbstract.sol";
import "dss-interfaces/dss/VatAbstract.sol";
import "dss-interfaces/ERC/GemAbstract.sol";

interface RwaLiquidationLike {
    function ilks(bytes32) external returns (string memory, address, uint48, uint48);
    function init(bytes32, uint256, string calldata, uint48) external;
}

interface RwaUrnLike {
    function hope(address) external;
    function lock(uint256) external;
}

interface RwaOutputConduitLike {
    function hope(address) external;
    function mate(address) external;
}

interface RwaInputConduitLike {
    function mate(address usr) external;
}

contract DssSpellCollateralAction {
    // --- Rates ---
    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmX2QMoM1SZq2XMoTbMak8pZP86Y2icpgPAKDjQg4r4YHn
    //

    uint256 constant ZERO_PCT_RATE           = 1000000000000000000000000000;
    uint256 constant ZERO_ZERO_FIVE_PCT_RATE = 1000000000015850933588756013;

    // --- Math ---
    uint256 public constant WAD = 10**18;
    uint256 public constant RAY = 10**27;
    uint256 public constant RAD = 10**45;

    // -- RWA008 MIP21 components --
    address constant RWA008                    = 0x30434AA15F85598F45406d08A79dCdD9a79335e9;
    address constant MCD_JOIN_RWA008_A         = 0x4ce65E856f824C2b4a2eeD88E79b839eB366967d;
    address constant RWA008_A_URN              = 0x6351915f840937Edba75656727f20165185FaB83;
    address constant RWA008_A_URN_CLOSE_HELPER = 0xb220461eFFa9c0b1D09047D08Bf116DfbD9814fA;
    address constant RWA008_A_INPUT_CONDUIT    = 0x6298a2498b4E3789bb8220Cf5f5b44f518509e2a;
    address constant RWA008_A_OUTPUT_CONDUIT   = 0x1FE95E519F0CE8eCF1cdC885f4DeA7913e146149;
    // SocGen's wallet
    address constant RWA008_A_OPERATOR         = 0x3F761335890721752476d4F210A7ad9BEf66fb45;
    // DIIS Group wallet
    address constant RWA008_A_MATE             = 0xb9444802F0831A3EB9f90E24EFe5FfA20138d684;

    uint256 constant RWA008_A_INITIAL_DC       = 30_000_000 * RAD;
    uint256 constant RWA008_A_INITIAL_PRICE    = 30_437_069 * WAD;
    uint48 constant  RWA008_A_TAU              = 0;

    uint256 constant RWA008_REG_CLASS_RWA      = 3;

    string constant RWA008_DOC                 = "QmdfzY6p5EpkYMN8wcomF2a1GsJbhkPiRQVRYSPfS4NZtB";
    // -- RWA008 end --

    // -- RWA009 MIP21 components --
    address constant RWA009                  = 0xd2B101854F64Df738bA601840279838568583F39;
    address constant MCD_JOIN_RWA009_A       = 0x7122B934F02A15954282Ed41572Ada539864773a;
    address constant RWA009_A_URN            = 0xD2C8588C72026171Ec3a17369ad0f0734E30915d;
    address constant RWA009_A_JAR            = 0xa484C16D2Ca15706c4B875710d9e80b7F101572B;
    // Goerli: CES Goerli Multisig / Mainnet: Genesis
    address constant RWA009_A_OUTPUT_CONDUIT = 0x7a3D23Dc73F7ead55399597aAE6e525b3DF95A88;

    // MIP21_LIQUIDATION_ORACLE params
    uint256 constant RWA009_A_INITIAL_DC     = 100_000_000 * RAD;
    uint256 constant RWA009_A_INITIAL_PRICE  = 100_000_000 * WAD;
    uint48  constant RWA009_A_TAU            = 0;

    uint256 constant RWA009_REG_CLASS_RWA    = 3;

    string constant RWA009_DOC               = "QmZG31b6iLGGCLGD7ZUn8EDkE9kANPVMcHzEYkvyNWCZpG";
    // -- RWA009 END --

    function onboardRwa008(
        ChainlogAbstract CHANGELOG,
        IlkRegistryAbstract REGISTRY,
        address MIP21_LIQUIDATION_ORACLE,
        address MCD_VAT,
        address MCD_JUG,
        address MCD_SPOT
    ) internal {
        // RWA008-A collateral deploy

        // Set ilk bytes32 variable
        bytes32 ilk = "RWA008-A";

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_RWA008_A).vat() == MCD_VAT, "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA008_A).ilk() == ilk,     "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA008_A).gem() == RWA008,  "join-gem-not-match");
        require(
            GemJoinAbstract(MCD_JOIN_RWA008_A).dec() == DSTokenAbstract(RWA008).decimals(),
            "join-dec-not-match"
        );

        // Init the RwaLiquidationOracle
        RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).init(ilk, RWA008_A_INITIAL_PRICE, RWA008_DOC, RWA008_A_TAU);
        (, address pip, , ) = RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).ilks(ilk);

        // Set price feed for RWA008
        SpotAbstract(MCD_SPOT).file(ilk, "pip", pip);

        // Init RWA008 in Vat
        VatAbstract(MCD_VAT).init(ilk);
        // Init RWA008 in Jug
        JugAbstract(MCD_JUG).init(ilk);

        // Allow RWA008 Join to modify Vat registry
        VatAbstract(MCD_VAT).rely(MCD_JOIN_RWA008_A);

        // Allow RwaLiquidationOracle to modify Vat registry
        VatAbstract(MCD_VAT).rely(MIP21_LIQUIDATION_ORACLE);

        // debt ceiling
        VatAbstract(MCD_VAT).file(ilk, "line", RWA008_A_INITIAL_DC);
        VatAbstract(MCD_VAT).file("Line", VatAbstract(MCD_VAT).Line() + RWA008_A_INITIAL_DC);

        // 0.05% stability fee
        JugAbstract(MCD_JUG).file(ilk, "duty", ZERO_ZERO_FIVE_PCT_RATE);

        // collateralization ratio 100%
        SpotAbstract(MCD_SPOT).file(ilk, "mat", RAY);

        // poke the spotter to pull in a price
        SpotAbstract(MCD_SPOT).poke(ilk);

        // give the urn permissions on the join adapter
        GemJoinAbstract(MCD_JOIN_RWA008_A).rely(RWA008_A_URN);

        // DSS_PAUSE_PROXY permission on URN
        RwaUrnLike(RWA009_A_URN).hope(address(this));
        // Helper contract permisison on URN
        RwaUrnLike(RWA008_A_URN).hope(RWA008_A_URN_CLOSE_HELPER);

        RwaUrnLike(RWA008_A_URN).hope(RWA008_A_OPERATOR);

        // set up output conduit
        RwaOutputConduitLike(RWA008_A_OUTPUT_CONDUIT).hope(RWA008_A_OPERATOR);

        // whitelist DIIS Group in the conduits
        RwaOutputConduitLike(RWA008_A_OUTPUT_CONDUIT).mate(RWA008_A_MATE);
        RwaInputConduitLike(RWA008_A_INPUT_CONDUIT)  .mate(RWA008_A_MATE);

        // whitelist Socgen in the conduits
        RwaOutputConduitLike(RWA008_A_OUTPUT_CONDUIT).mate(RWA008_A_OPERATOR);
        RwaInputConduitLike(RWA008_A_INPUT_CONDUIT)  .mate(RWA008_A_OPERATOR);

        // Add RWA008 contract to the changelog
        CHANGELOG.setAddress("RWA008",                  RWA008);
        CHANGELOG.setAddress("PIP_RWA008",              pip);
        CHANGELOG.setAddress("MCD_JOIN_RWA008_A",       MCD_JOIN_RWA008_A);
        CHANGELOG.setAddress("RWA008_A_URN",            RWA008_A_URN);
        CHANGELOG.setAddress("RWA008_A_INPUT_CONDUIT",  RWA008_A_INPUT_CONDUIT);
        CHANGELOG.setAddress("RWA008_A_OUTPUT_CONDUIT", RWA008_A_OUTPUT_CONDUIT);

        REGISTRY.put(
            "RWA008-A",
            MCD_JOIN_RWA008_A,
            RWA008,
            GemJoinAbstract(MCD_JOIN_RWA008_A).dec(),
            RWA008_REG_CLASS_RWA,
            pip,
            address(0),
            "RWA008-A: SG Forge OFH",
            GemAbstract(RWA008).symbol()
        );
    }

    function onboardRwa009(
        ChainlogAbstract CHANGELOG,
        IlkRegistryAbstract REGISTRY,
        address MIP21_LIQUIDATION_ORACLE,
        address MCD_VAT,
        address MCD_JUG,
        address MCD_SPOT
    ) internal {
        // Set ilk bytes32 variable
        bytes32 ilk = "RWA009-A";

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_RWA009_A).vat() == MCD_VAT, "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA009_A).ilk() == ilk,     "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA009_A).gem() == RWA009,  "join-gem-not-match");
        require(
            GemJoinAbstract(MCD_JOIN_RWA009_A).dec() == DSTokenAbstract(RWA009).decimals(),
            "join-dec-not-match"
        );

        // Init the RwaLiquidationOracle
        RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).init(ilk, RWA009_A_INITIAL_PRICE, RWA009_DOC, RWA009_A_TAU);
        (, address pip, , ) = RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).ilks(ilk);

        // Set price feed for RWA009
        SpotAbstract(MCD_SPOT).file(ilk, "pip", pip);

        // Init RWA009 in Vat
        VatAbstract(MCD_VAT).init(ilk);
        // Init RWA009 in Jug
        JugAbstract(MCD_JUG).init(ilk);

        // Allow RWA009 Join to modify Vat registry
        VatAbstract(MCD_VAT).rely(MCD_JOIN_RWA009_A);

        // Allow RwaLiquidationOracle2 to modify Vat registry
        VatAbstract(MCD_VAT).rely(MIP21_LIQUIDATION_ORACLE);

        // 100m debt ceiling
        VatAbstract(MCD_VAT).file(ilk, "line", RWA009_A_INITIAL_DC);
        VatAbstract(MCD_VAT).file("Line", VatAbstract(MCD_VAT).Line() + RWA009_A_INITIAL_DC);

        // 0% stability fee
        JugAbstract(MCD_JUG).file(ilk, "duty", ZERO_PCT_RATE);

        // collateralization ratio 100%
        SpotAbstract(MCD_SPOT).file(ilk, "mat", RAY);

        // poke the spotter to pull in a price
        SpotAbstract(MCD_SPOT).poke(ilk);

        // give the urn permissions on the join adapter
        GemJoinAbstract(MCD_JOIN_RWA009_A).rely(RWA009_A_URN);

        // Add RWA009 contract to the changelog
        CHANGELOG.setAddress("RWA009",                  RWA009);
        CHANGELOG.setAddress("PIP_RWA009",              pip);
        CHANGELOG.setAddress("MCD_JOIN_RWA009_A",       MCD_JOIN_RWA009_A);
        CHANGELOG.setAddress("RWA009_A_URN",            RWA009_A_URN);
        CHANGELOG.setAddress("RWA009_A_JAR",            RWA009_A_JAR);
        CHANGELOG.setAddress("RWA009_A_OUTPUT_CONDUIT", RWA009_A_OUTPUT_CONDUIT);

        // Add RWA009 to ILK REGISTRY
        REGISTRY.put(
            "RWA009-A",
            MCD_JOIN_RWA009_A,
            RWA009,
            GemJoinAbstract(MCD_JOIN_RWA009_A).dec(),
            RWA009_REG_CLASS_RWA,
            pip,
            address(0),
            "RWA009-A: H. V. Bank",
            GemAbstract(RWA009).symbol()
        );
    }

    function onboardNewCollaterals() internal {
        ChainlogAbstract CHANGELOG       = ChainlogAbstract(DssExecLib.LOG);
        IlkRegistryAbstract REGISTRY     = IlkRegistryAbstract(DssExecLib.reg());
        address MIP21_LIQUIDATION_ORACLE = CHANGELOG.getAddress("MIP21_LIQUIDATION_ORACLE");
        address MCD_VAT                  = CHANGELOG.getAddress("MCD_VAT");
        address MCD_JUG                  = CHANGELOG.getAddress("MCD_JUG");
        address MCD_SPOT                 = CHANGELOG.getAddress("MCD_SPOT");
        // --------------------------- RWA Collateral onboarding ---------------------------

        // Onboard SocGen: https://vote.makerdao.com/polling/QmajCtnG
        onboardRwa008(CHANGELOG, REGISTRY, MIP21_LIQUIDATION_ORACLE, MCD_VAT, MCD_JUG, MCD_SPOT);

        // Onboard HvB: https://vote.makerdao.com/polling/QmQMDasC
        onboardRwa009(CHANGELOG, REGISTRY, MIP21_LIQUIDATION_ORACLE, MCD_VAT, MCD_JUG, MCD_SPOT);
    }

    function offboardCollaterals() internal {}
}
