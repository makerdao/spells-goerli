// SPDX-FileCopyrightText: © 2021-2022 Dai Foundation <www.daifoundation.org>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Copyright (C) 2021-2022 Dai Foundation
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

import "dss-exec-lib/DssExecLib.sol";
import "dss-interfaces/dss/VatAbstract.sol";
import "dss-interfaces/dapp/DSPauseAbstract.sol";
import "dss-interfaces/dss/JugAbstract.sol";
import "dss-interfaces/dss/SpotAbstract.sol";
import "dss-interfaces/dss/GemJoinAbstract.sol";
import "dss-interfaces/dapp/DSTokenAbstract.sol";
import "dss-interfaces/dss/ChainlogAbstract.sol";
import "dss-interfaces/dss/IlkRegistryAbstract.sol";

interface ERC20Like {
    function approve(address, uint256) external returns (bool);
}

interface RwaLiquidationLike {
    function wards(address) external returns (uint256);

    function ilks(bytes32)
        external
        returns (
            string memory,
            address,
            uint48,
            uint48
        );

    function rely(address) external;

    function deny(address) external;

    function init(
        bytes32,
        uint256,
        string calldata,
        uint48
    ) external;

    function tell(bytes32) external;

    function cure(bytes32) external;

    function cull(bytes32) external;

    function good(bytes32) external view;
}

interface RwaUrnLike {
    function hope(address) external;

    function lock(uint256) external;

    function nope(address) external;

    function draw(uint256) external;
}

interface TokenDetailsLike {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);
}

interface RwaOutputConduitLike {
    function wards(address) external returns (uint256);

    function can(address) external returns (uint256);

    function rely(address) external;

    function deny(address) external;

    function hope(address) external;

    function mate(address) external;

    function nope(address) external;

    function bud(address) external returns (uint256);

    function pick(address) external;

    function push() external;
}

interface RwaInputConduitLike {
    function rely(address usr) external;

    function deny(address usr) external;

    function mate(address usr) external;

    function hate(address usr) external;

    function push() external;
}


contract DssSpellCollateralAction {
    address constant RWA_TOKEN_FAB            = 0xb7462C421D7EDF3455003F76125e812a66DdE187;

    // --- Rates ---
    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmTRiQ3GqjCiRhh1ojzKzgScmSsiwQPLyjhgYSxZASQekj
    //

    uint256 constant ZERO_PCT_RATE            = 1000000000000000000000000000;
    uint256 constant ZERO_FIVE_PCT_RATE       = 1000000000015850933588756013;

    // --- Math ---
    uint256 public constant THOUSAND          = 10**3;
    uint256 public constant MILLION           = 10**6;
    uint256 public constant WAD               = 10**18;
    uint256 public constant RAY               = 10**27;
    uint256 public constant RAD               = 10**45;

    // -- RWA009 MIP21 components --
    address constant RWA009                   = 0x2E17564A02D7DA159192959F1AC03b600Bff4B4b;
    address constant MCD_JOIN_RWA009_A        = 0x4ecF6b3adaB86276222b58993b5107Ee1202A29C;
    address constant RWA009_A_URN             = 0x3c471786cFb1e4495E08de76D637762ad3772d4c;
    address constant RWA009_A_JAR             = 0x7AAf3F8d07eF898e6fc55D3B7C88cCCFeb0275fF;
    address constant RWA009_A_OUTPUT_CONDUIT  = 0x7a3D23Dc73F7ead55399597aAE6e525b3DF95A88;

    uint256 constant RWA009_DRAW_AMOUNT       = 25 * MILLION * WAD;

    // MIP21_LIQUIDATION_ORACLE params
    uint256 constant RWA009_A_INITIAL_DC      = 100 * MILLION * RAD;
    uint256 constant RWA009_A_INITIAL_PRICE   = 100 * MILLION * WAD;
    uint48  constant RWA009_A_TAU             = 0;

    uint256 constant RWA009_REG_CLASS_RWA     = 3;

    /**
     * @notice MIP13c3-SP4 Declaration of Intent & Commercial Points -
     *   Off-Chain Asset Backed Lender to onboard Real World Assets
     *   as Collateral for a DAI loan
     *
     * https://ipfs.io/ipfs/QmdmAUTU3sd9VkdfTZNQM6krc9jsKgF2pz7W1qvvfJo1xk
     */
    string constant RWA009_DOC                 = "IPFS_HASH"; // TODO Reference to a documents which describe deal (should be uploaded to IPFS)
    // -- RWA009 END --

    // -- RWA008 MIP21 components --
    address constant RWA_URN_PROXY_ACTIONS      = 0x741A0fc23AB643B1963E77B5136554b12a91f170;

    address constant RWA008                     = 0xAd56c72774abE21bFf16bf32DD8ABf6676532E1C; 
    address constant MCD_JOIN_RWA008_A          = 0x6D1D4ef7b0FF2539DC6565D9244B5C2C963e4dea; 
    address constant RWA008_A_URN               = 0xAeBf8487A6434821702c0792DC7176909F88c7d0; 
    address constant RWA008_A_INPUT_CONDUIT     = 0x8c2B6Ccd0c9A79AB0ca020F1ABB5b0e53a428268; 
    address constant RWA008_A_OUTPUT_CONDUIT    = 0x5A817FDf51Da3e4cfcFe921FB0496228E8a607e2; 
    address constant RWA008_A_OPERATOR          = 0x3F761335890721752476d4F210A7ad9BEf66fb45; 
    address constant RWA008_A_MATE              = 0xb9444802F0831A3EB9f90E24EFe5FfA20138d684; 

    uint256 constant RWA008_A_INITIAL_DC        = 30 * MILLION * RAD;
    uint256 constant RWA008_A_INITIAL_PRICE     = 30_437_069 * WAD;
    uint48 constant  RWA008_A_TAU               = 0;

    uint256 constant RWA008_REG_CLASS_RWA       = 3;

    /**
     * @notice MIP13c3-SP4 Declaration of Intent & Commercial Points -
     *   Off-Chain Asset Backed Lender to onboard Real World Assets
     *   as Collateral for a DAI loan
     *
     * https://ipfs.io/ipfs/QmdmAUTU3sd9VkdfTZNQM6krc9jsKgF2pz7W1qvvfJo1xk
     */
    string constant RWA008_DOC                 = "IPFS_HASH"; // Reference to a documents which describe deal (should be uploaded to IPFS)
    // -- RWA008 end --

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
        require(GemJoinAbstract(MCD_JOIN_RWA009_A).vat() == MCD_VAT,   "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA009_A).ilk() == ilk,       "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA009_A).gem() == RWA009,    "join-gem-not-match");
        require(
            GemJoinAbstract(MCD_JOIN_RWA009_A).dec() == DSTokenAbstract(RWA009).decimals(),
            "join-dec-not-match"
        );

        /*
         * init the RwaLiquidationOracle2
         */
        // TODO: this should be verified with RWA Team (5 min for testing is good)
        RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).init(ilk, RWA009_A_INITIAL_PRICE, RWA009_DOC, RWA009_A_TAU);
        (, address pip, , ) = RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).ilks(ilk);
        CHANGELOG.setAddress("PIP_RWA009", pip);

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

        // No dust
        // VatAbstract(MCD_VAT).file(ilk, "dust", 0)

        // 0% stability fee
        JugAbstract(MCD_JUG).file(ilk, "duty", ZERO_PCT_RATE);

        // collateralization ratio 100%
        SpotAbstract(MCD_SPOT).file(ilk, "mat", RAY);

        // poke the spotter to pull in a price
        SpotAbstract(MCD_SPOT).poke(ilk);

        // give the urn permissions on the join adapter
        GemJoinAbstract(MCD_JOIN_RWA009_A).rely(RWA009_A_URN);

        // DSS_PAUSE_PROXY permission on URN
        RwaUrnLike(RWA009_A_URN).hope(address(this));

        // lock RWA009 Token in the URN
        ERC20Like(RWA009).approve(RWA009_A_URN, 1 * WAD);
        RwaUrnLike(RWA009_A_URN).lock(1 * WAD);

        // draw DAI to genesis address
        RwaUrnLike(RWA009_A_URN).draw(RWA009_DRAW_AMOUNT);

        // Add RWA009 contract to the changelog
        CHANGELOG.setAddress("RWA009",                  RWA009);
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
            TokenDetailsLike(RWA009).symbol()
        );
    }

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
        require(GemJoinAbstract(MCD_JOIN_RWA008_A).ilk() == ilk, "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA008_A).gem() == RWA008, "join-gem-not-match");
        require(
            GemJoinAbstract(MCD_JOIN_RWA008_A).dec() == DSTokenAbstract(RWA008).decimals(),
            "join-dec-not-match"
        );

        /*
         * init the RwaLiquidationOracle2
         */
        // TODO: this should be verified with RWA Team (5 min for testing is good)
        RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).init(ilk, RWA008_A_INITIAL_PRICE, RWA008_DOC, RWA008_A_TAU);
        (, address pip, , ) = RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).ilks(ilk);
        CHANGELOG.setAddress("PIP_RWA008", pip);

        // Set price feed for RWA008
        SpotAbstract(MCD_SPOT).file(ilk, "pip", pip);

        // Init RWA008 in Vat
        VatAbstract(MCD_VAT).init(ilk);
        // Init RWA008 in Jug
        JugAbstract(MCD_JUG).init(ilk);

        // Allow RWA008 Join to modify Vat registry
        VatAbstract(MCD_VAT).rely(MCD_JOIN_RWA008_A);

        // Allow RwaLiquidationOracle2 to modify Vat registry
        VatAbstract(MCD_VAT).rely(MIP21_LIQUIDATION_ORACLE);

        // debt ceiling
        VatAbstract(MCD_VAT).file(ilk, "line", RWA008_A_INITIAL_DC);
        VatAbstract(MCD_VAT).file("Line", VatAbstract(MCD_VAT).Line() + RWA008_A_INITIAL_DC);

        // 0.05% stability fee
        JugAbstract(MCD_JUG).file(ilk, "duty", ZERO_FIVE_PCT_RATE);

        // collateralization ratio 100%
        SpotAbstract(MCD_SPOT).file(ilk, "mat", RAY);

        // poke the spotter to pull in a price
        SpotAbstract(MCD_SPOT).poke(ilk);

        // give the urn permissions on the join adapter
        GemJoinAbstract(MCD_JOIN_RWA008_A).rely(RWA008_A_URN);

        // set up the urn
        RwaUrnLike(RWA008_A_URN).hope(RWA_URN_PROXY_ACTIONS);

        RwaUrnLike(RWA008_A_URN).hope(RWA008_A_OPERATOR);

        // set up output conduit
        RwaOutputConduitLike(RWA008_A_OUTPUT_CONDUIT).hope(RWA008_A_OPERATOR);

        // whitelist DIIS Group in the conduits
        RwaOutputConduitLike(RWA008_A_OUTPUT_CONDUIT).mate(RWA008_A_MATE);
        RwaInputConduitLike(RWA008_A_INPUT_CONDUIT).mate(RWA008_A_MATE);

        // whitelist Socgen in the conduits 
        RwaOutputConduitLike(RWA008_A_OUTPUT_CONDUIT).mate(RWA008_A_OPERATOR);
        RwaInputConduitLike(RWA008_A_INPUT_CONDUIT).mate(RWA008_A_OPERATOR);

        // Add RWA008 contract to the changelog
        CHANGELOG.setAddress("RWA008", RWA008);
        CHANGELOG.setAddress("MCD_JOIN_RWA008_A", MCD_JOIN_RWA008_A);
        CHANGELOG.setAddress("RWA008_A_URN", RWA008_A_URN);
        CHANGELOG.setAddress("RWA008_A_INPUT_CONDUIT", RWA008_A_INPUT_CONDUIT);
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
            TokenDetailsLike(RWA008).symbol()
        );
    }

    function onboardNewCollaterals() internal {
        ChainlogAbstract CHANGELOG                = ChainlogAbstract(DssExecLib.LOG);
        IlkRegistryAbstract REGISTRY              = IlkRegistryAbstract(DssExecLib.reg());
        address MIP21_LIQUIDATION_ORACLE          = CHANGELOG.getAddress("MIP21_LIQUIDATION_ORACLE");
        address MCD_VAT                           = CHANGELOG.getAddress("MCD_VAT");
        address MCD_JUG                           = CHANGELOG.getAddress("MCD_JUG");
        address MCD_SPOT                          = CHANGELOG.getAddress("MCD_SPOT");
        // --------------------------- RWA Collateral onboarding ---------------------------
        
        // Onboard HvB
        onboardRwa009(CHANGELOG, REGISTRY, MIP21_LIQUIDATION_ORACLE, MCD_VAT, MCD_JUG, MCD_SPOT);
        
        // Onboard SocGen
        onboardRwa008(CHANGELOG, REGISTRY, MIP21_LIQUIDATION_ORACLE, MCD_VAT, MCD_JUG, MCD_SPOT);

        // Add RWA_TOKEN_FAB to changelog
        CHANGELOG.setAddress("RWA_TOKEN_FAB", RWA_TOKEN_FAB);
    }

    function offboardCollaterals() internal {}
}
