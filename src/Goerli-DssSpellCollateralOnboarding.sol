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

interface RwaUrnLike {
    function hope(address) external;

    function lock(uint256) external;

    function nope(address) external;
}

interface TokenDetailsLike {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);
}

contract DssSpellCollateralOnboardingAction {

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

    // --- Math ---
    uint256 public constant THOUSAND          = 10**3;
    uint256 public constant MILLION           = 10**6;
    uint256 public constant WAD               = 10**18;
    uint256 public constant RAY               = 10**27;
    uint256 public constant RAD               = 10**45;

    // MIP21 components
    address constant RWA009                   = 0x0000000000000000000000000000000000000000;
    address constant MCD_JOIN_RWA009_A        = 0x0000000000000000000000000000000000000000;
    address constant RWA009_A_URN             = 0x0000000000000000000000000000000000000000;
    address constant RWA009_A_JAR             = 0x0000000000000000000000000000000000000000;
    address constant RWA009_A_OUTPUT_CONDUIT  = 0x0000000000000000000000000000000000000000;
    address constant RWA009_A_OPERATOR        = 0x0000000000000000000000000000000000000000;
    address constant RWA009_A_MATE            = 0x0000000000000000000000000000000000000000;

    // MIP21_LIQUIDATION_ORACLE params
    uint256 constant RWA009_A_INITIAL_DC      = 100000000 * RAD; // TODO
    uint256 constant RWA009_A_INITIAL_PRICE   = 100 * MILLION * WAD; // TODO RWA team should provide
    uint48  constant RWA009_A_TAU             = 0;

    uint256 constant REG_CLASS_RWA            = 3;

    address constant RWA_TOKEN_FAB            = 0x0000000000000000000000000000000000000000;

    /**
     * @notice MIP13c3-SP4 Declaration of Intent & Commercial Points -
     *   Off-Chain Asset Backed Lender to onboard Real World Assets
     *   as Collateral for a DAI loan
     *
     * https://ipfs.io/ipfs/QmdmAUTU3sd9VkdfTZNQM6krc9jsKgF2pz7W1qvvfJo1xk
     */
    string constant DOC                       = "IPFS_HASH"; // TODO Reference to a documents which describe deal (should be uploaded to IPFS)


    function onboardNewCollaterals() internal {
        // --------------------------- RWA Collateral onboarding ---------------------------
        ChainlogAbstract CHANGELOG          = ChainlogAbstract(DssExecLib.LOG);
        IlkRegistryAbstract REGISTRY        = IlkRegistryAbstract(DssExecLib.reg());

        address MIP21_LIQUIDATION_ORACLE    = CHANGELOG.getAddress("MIP21_LIQUIDATION_ORACLE");

        address MCD_VAT                     = CHANGELOG.getAddress("MCD_VAT");
        address MCD_JUG                     = CHANGELOG.getAddress("MCD_JUG");
        address MCD_SPOT                    = CHANGELOG.getAddress("MCD_SPOT");

        // RWA009-A collateral deploy

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
        RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).init(ilk, RWA009_A_INITIAL_PRICE, DOC, RWA009_A_TAU);
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

        // 1000 debt ceiling
        VatAbstract(MCD_VAT).file(ilk, "line", RWA009_A_INITIAL_DC);
        VatAbstract(MCD_VAT).file("Line", VatAbstract(MCD_VAT).Line() + RWA009_A_INITIAL_DC);

        // No dust
        // VatAbstract(MCD_VAT).file(ilk, "dust", 0)

        // 0% stability fee
        JugAbstract(MCD_JUG).file(ilk, "duty", ZERO_PCT_RATE);

        // collateralization ratio 100%
        SpotAbstract(MCD_SPOT).file(ilk, "mat", RAY); // TODO Should get from RWA team

        // poke the spotter to pull in a price
        SpotAbstract(MCD_SPOT).poke(ilk);

        // give the urn permissions on the join adapter
        GemJoinAbstract(MCD_JOIN_RWA009_A).rely(RWA009_A_URN);

        // set up the urn
        RwaUrnLike(RWA009_A_URN).hope(RWA009_A_OPERATOR);

        // set up output conduit
        RwaOutputConduitLike(RWA009_A_OUTPUT_CONDUIT).hope(RWA009_A_OPERATOR);

        // whitelist in the conduits
        RwaOutputConduitLike(RWA009_A_OUTPUT_CONDUIT).mate(RWA009_A_MATE);

        // lock RWA009 Token in the URN
        ERC20Like(RWA009).approve(RWA009_A_URN, 1 * WAD);
        RwaUrnLike(RWA009_A_URN).hope(address(this));
        RwaUrnLike(RWA009_A_URN).lock(1 * WAD);
        RwaUrnLike(RWA009_A_URN).nope(address(this));

        // draw DAI to outputConduit // TODO 
        RwaUrnLike(RWA009_A_URN).draw(100 * MILLION * WAD);

        // Add RWA009 contract to the changelog
        CHANGELOG.setAddress("RWA009",                  RWA009);
        CHANGELOG.setAddress("MCD_JOIN_RWA009_A",       MCD_JOIN_RWA009_A);
        CHANGELOG.setAddress("RWA009_A_URN",            RWA009_A_URN);
        CHANGELOG.setAddress("RWA009_A_JAR",            RWA009_A_JAR);
        CHANGELOG.setAddress("RWA009_A_OUTPUT_CONDUIT", RWA009_A_OUTPUT_CONDUIT);

        // Add RWA_TOKEN_FAB to changelog
        CHANGELOG.setAddress("RWA_TOKEN_FAB", RWA_TOKEN_FAB);

        // Add RWA009 to ILK REGISTRY
        REGISTRY.put(
            "RWA009-A",
            MCD_JOIN_RWA009_A,
            RWA009,
            GemJoinAbstract(MCD_JOIN_RWA009_A).dec(),
            REG_CLASS_RWA,
            pip,
            address(0),
            "RWA009-A: H. V. Bank",
            TokenDetailsLike(RWA009).symbol()
        );
    }
}
