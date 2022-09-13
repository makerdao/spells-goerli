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
import "dss-interfaces/dss/ChainlogAbstract.sol";
import "dss-interfaces/dss/GemJoinAbstract.sol";
import "dss-interfaces/dss/IlkRegistryAbstract.sol";
import "dss-interfaces/ERC/GemAbstract.sol";

interface RwaLiquidationLike {
    function ilks(bytes32) external returns (string memory, address, uint48, uint48);
    function init(bytes32, uint256, string calldata, uint48) external;
}

interface RwaUrnLike {
    function vat() external view returns(address);
    function jug() external view returns(address);
    function gemJoin() external view returns(address);
    function daiJoin() external view returns(address);
    function outputConduit() external view returns(address);
    function hope(address) external;
}

interface RwaOutputConduitLike {
    function dai() external view returns(address);
    function psm() external view returns(address);
    function quitTo() external view returns(address);
    function hope(address) external;
    function mate(address) external;
    function kiss(address) external;
}

interface RwaInputConduitLike {
    function dai() external view returns(address);
    function psm() external view returns(address);
    function to() external view returns(address);
    function mate(address usr) external;
    function file(bytes32 what, address data) external;
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

    uint256 constant ZERO_PCT_RATE                  = 1000000000000000000000000000;

    // --- Math ---
    uint256 public constant WAD = 10**18;
    uint256 public constant RAY = 10**27;
    uint256 public constant RAD = 10**45;

    // -- RWA007 MIP21 components --
    address constant RWA007                         = 0x02091C59C92fc5E0575b3B133c3caa4f57D79b0e;
    address constant MCD_JOIN_RWA007_A              = 0xe3BA7B6c922cb4622AfF00C2e2A467fF6A06CA29;
    address constant RWA007_A_URN                   = 0x78D9ccbe652E2aE7B11289B4F202278058aEfeeA;
    address constant RWA007_A_JAR                   = 0xcF8A6445B6e22A8e2Fe9d7bd21410bB7a8b8D054;
    // Goerli: Coinbase / Mainnet: Coinbase
    address constant RWA007_A_OUTPUT_CONDUIT        = 0x9B4Af5F55b23cC2D86f58d7c08cD025bA1901013;
    // Jar and URN Input Conduits
    address constant RWA007_A_INPUT_CONDUIT_URN     = 0xFC80d4037dDadDb380e752AE46Aca262eEb812fC;
    address constant RWA007_A_INPUT_CONDUIT_JAR     = 0x9ca5F7b1F5DCC287657c20547176a6733EB2c046;

    // MIP21_LIQUIDATION_ORACLE params
    string  constant RWA007_DOC                     = "QmRe77P2JsvQWygVr9ZAMs4SHnjUQXz6uawdSboAaj2ryF"; // TODO
    // There is no DssExecLib helper, so WAD precision is used.
    uint256 constant RWA007_A_INITIAL_PRICE         = 250_000_000 * WAD;
    uint48  constant RWA007_A_TAU                   = 0;

    // Ilk registry params
    uint256 constant RWA007_REG_CLASS_RWA           = 3;

    // Remaining params
    uint256 constant RWA007_A_LINE                  = 1_000_000;
    uint256 constant RWA007_A_MAT                   = 100_00; // 100% in basis-points
    uint256 constant RWA007_A_RATE                  = ZERO_PCT_RATE;

    // Monetalis operator address
    address constant RWA007_A_OPERATOR              = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84; // TODO
    // Coinbase custody address
    address constant RWA007_A_COINBASE_CUSTODY      = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84; // TODO
    // Input conduit "quitTo" address
    address constant RWA007_A_INPUT_CONDUIT_QUIT_TO = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84; // TODO

    // -- RWA007 END --

    function onboardRwa007(
        ChainlogAbstract CHANGELOG,
        IlkRegistryAbstract REGISTRY,
        address MIP21_LIQUIDATION_ORACLE,
        address MCD_VAT,
        address MCD_JUG,
        address MCD_SPOT,
        address MCD_JOIN_DAI,
        address MCD_PSM_USDC_A
    ) internal {
        // RWA007-A collateral deploy
        bytes32 ilk      = "RWA007-A";
        uint256 decimals = GemAbstract(RWA007).decimals();

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_RWA007_A).vat()               == MCD_VAT,               "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA007_A).ilk()               == ilk,                     "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA007_A).gem()               == RWA007,                  "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA007_A).dec()               == decimals,                "join-dec-not-match");

        require(RwaUrnLike(RWA007_A_URN).vat()                         == MCD_VAT,               "urn-vat-not-match");
        require(RwaUrnLike(RWA007_A_URN).jug()                         == MCD_JUG,               "urn-jug-not-match");
        require(RwaUrnLike(RWA007_A_URN).daiJoin()                     == MCD_JOIN_DAI,          "urn-daijoin-not-match");
        require(RwaUrnLike(RWA007_A_URN).gemJoin()                     == MCD_JOIN_RWA007_A,       "urn-gemjoin-not-match");
        require(RwaUrnLike(RWA007_A_URN).outputConduit()               == RWA007_A_OUTPUT_CONDUIT, "urn-outputconduit-not-match");

        require(RwaOutputConduitLike(RWA007_A_OUTPUT_CONDUIT).psm()    == MCD_PSM_USDC_A,        "output-conduit-psm-not-match");
        require(RwaOutputConduitLike(RWA007_A_OUTPUT_CONDUIT).quitTo() == RWA007_A_URN,            "output-conduit-quit-to-not-match");

        require(RwaInputConduitLike(RWA007_A_INPUT_CONDUIT_URN).psm()  == MCD_PSM_USDC_A,        "input-conduit-urn-psm-not-match");
        require(RwaInputConduitLike(RWA007_A_INPUT_CONDUIT_URN).to()   == RWA007_A_URN,            "input-conduit-urn-to-not-match");

        require(RwaInputConduitLike(RWA007_A_INPUT_CONDUIT_JAR).psm()  == MCD_PSM_USDC_A,        "input-conduit-jar-psm-not-match");
        require(RwaInputConduitLike(RWA007_A_INPUT_CONDUIT_JAR).to()   == RWA007_A_JAR,            "input-conduit-har-to-not-match");


        // Init the RwaLiquidationOracle
        RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).init(ilk, RWA007_A_INITIAL_PRICE, RWA007_DOC, RWA007_A_TAU);
        (, address pip, , ) = RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).ilks(ilk);

        // Set price feed for RWA007
        DssExecLib.setContract(MCD_SPOT, ilk, "pip", pip);

        // Init RWA007 in Vat
        Initializable(MCD_VAT).init(ilk);
        // Init RWA007 in Jug
        Initializable(MCD_JUG).init(ilk);

        // Allow RWA007 Join to modify Vat registry
        DssExecLib.authorize(MCD_VAT, MCD_JOIN_RWA007_A);

        // 100m debt ceiling
        DssExecLib.increaseIlkDebtCeiling(ilk, RWA007_A_LINE, /* _global = */ true);

        // Set the stability fee
        DssExecLib.setIlkStabilityFee(ilk, RWA007_A_RATE, /* _doDrip = */ false);

        // Set collateralization ratio
        DssExecLib.setIlkLiquidationRatio(ilk, RWA007_A_MAT);

        // Poke the spotter to pull in a price
        DssExecLib.updateCollateralPrice(ilk);

        // Give the urn permissions on the join adapter
        DssExecLib.authorize(MCD_JOIN_RWA007_A, RWA007_A_URN);

        // MCD_PAUSE_PROXY and Monetalis permission on URN
        RwaUrnLike(RWA007_A_URN).hope(address(this));
        RwaUrnLike(RWA007_A_URN).hope(address(RWA007_A_OPERATOR));

        // MCD_PAUSE_PROXY and Monetails permission on RWA007_A_OUTPUT_CONDUIT
        RwaOutputConduitLike(RWA007_A_OUTPUT_CONDUIT).hope(address(this));
        RwaOutputConduitLike(RWA007_A_OUTPUT_CONDUIT).mate(address(this));
        RwaOutputConduitLike(RWA007_A_OUTPUT_CONDUIT).hope(RWA007_A_OPERATOR);
        RwaOutputConduitLike(RWA007_A_OUTPUT_CONDUIT).mate(RWA007_A_OPERATOR);
        // Coinbase custody whitelist for URN destination address
        RwaOutputConduitLike(RWA007_A_OUTPUT_CONDUIT).kiss(address(RWA007_A_COINBASE_CUSTODY));

        // MCD_PAUSE_PROXY and Monetails permission on RWA007_A_INPUT_CONDUIT_URN
        RwaInputConduitLike(RWA007_A_INPUT_CONDUIT_URN).mate(address(this));
        RwaInputConduitLike(RWA007_A_INPUT_CONDUIT_URN).mate(RWA007_A_OPERATOR);
        // Set "quitTo" address for RWA007_A_INPUT_CONDUIT_URN
        RwaInputConduitLike(RWA007_A_INPUT_CONDUIT_URN).file("quitTo", RWA007_A_INPUT_CONDUIT_QUIT_TO);

        // MCD_PAUSE_PROXY and Monetails permission on RWA007_A_INPUT_CONDUIT_JAR
        RwaInputConduitLike(RWA007_A_INPUT_CONDUIT_JAR).mate(address(this));
        RwaInputConduitLike(RWA007_A_INPUT_CONDUIT_JAR).mate(RWA007_A_OPERATOR);
        // Set "quitTo" address for RWA007_A_INPUT_CONDUIT_JAR
        RwaInputConduitLike(RWA007_A_INPUT_CONDUIT_JAR).file("quitTo", RWA007_A_INPUT_CONDUIT_QUIT_TO);

        // Add RWA007 contract to the changelog
        CHANGELOG.setAddress("RWA007",                     RWA007);
        CHANGELOG.setAddress("PIP_RWA007",                 pip);
        CHANGELOG.setAddress("MCD_JOIN_RWA007_A",          MCD_JOIN_RWA007_A);
        CHANGELOG.setAddress("RWA007_A_URN",               RWA007_A_URN);
        CHANGELOG.setAddress("RWA007_A_JAR",               RWA007_A_JAR);
        CHANGELOG.setAddress("RWA007_A_OUTPUT_CONDUIT",    RWA007_A_OUTPUT_CONDUIT);
        CHANGELOG.setAddress("RWA007_A_INPUT_CONDUIT_URN", RWA007_A_INPUT_CONDUIT_URN);
        CHANGELOG.setAddress("RWA007_A_INPUT_CONDUIT_JAR", RWA007_A_INPUT_CONDUIT_JAR);

        // Add RWA007 to ILK REGISTRY
        REGISTRY.put(
            ilk,
            MCD_JOIN_RWA007_A,
            RWA007,
            decimals,
            RWA007_REG_CLASS_RWA,
            pip,
            address(0),
            "RWA007-A: Monetalis",
            GemAbstract(RWA007).symbol()
        );
    }

    function onboardNewCollaterals() internal {
        ChainlogAbstract CHANGELOG       = ChainlogAbstract(DssExecLib.LOG);
        IlkRegistryAbstract REGISTRY     = IlkRegistryAbstract(DssExecLib.reg());
        address MIP21_LIQUIDATION_ORACLE = CHANGELOG.getAddress("MIP21_LIQUIDATION_ORACLE");
        address MCD_PSM_USDC_A           = CHANGELOG.getAddress("MCD_PSM_USDC_A");
        address MCD_VAT                  = DssExecLib.vat();
        address MCD_JUG                  = DssExecLib.jug();
        address MCD_SPOT                 = DssExecLib.spotter();
        address MCD_JOIN_DAI             = DssExecLib.daiJoin();

        // --------------------------- RWA Collateral onboarding ---------------------------

        // Onboard Monetalis: TODO: https://vote.makerdao.com/polling/QmQMDasC
        onboardRwa007(CHANGELOG, REGISTRY, MIP21_LIQUIDATION_ORACLE, MCD_VAT, MCD_JUG, MCD_SPOT, MCD_JOIN_DAI, MCD_PSM_USDC_A);
    }

    function offboardCollaterals() internal {}
}
