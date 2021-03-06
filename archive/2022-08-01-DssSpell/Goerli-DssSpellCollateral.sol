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
    function hope(address) external;
    function mate(address) external;
}

interface RwaInputConduitLike {
    function dai() external view returns(address);
    function to() external view returns(address);
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
    address immutable MCD_JOIN_RWA008_A_OLD    = DssExecLib.getChangelogAddress("MCD_JOIN_RWA008_A");

    address constant RWA008                    = 0x9A900f506b88ae6C7F9C5fbEffC5AFEC24A6fAAA;
    address constant MCD_JOIN_RWA008_A         = 0x36fA17FA0b4Be214cDc04faD2587dC85a7c2c086;
    address constant RWA008_A_URN              = 0xF50FE370839c295DADFADFCC5b6DC9b904604F7d;
    address constant RWA008_A_URN_CLOSE_HELPER = 0xAa74C325142a3E7CA84FEaa1b0349F1Fd08B83Dc;
    address constant RWA008_A_INPUT_CONDUIT    = 0x8c4295EF77e503E5fd0c8dE3f73985834bE85DE2;
    address constant RWA008_A_OUTPUT_CONDUIT   = 0x1aA21d2E39EC0da185CA04609c8868bC324d8553;
    // SocGen's wallet
    address constant RWA008_A_OPERATOR         = 0x3F761335890721752476d4F210A7ad9BEf66fb45;
    // DIIS Group wallet
    address constant RWA008_A_MATE             = 0xb9444802F0831A3EB9f90E24EFe5FfA20138d684;

    string  constant RWA008_DOC                = "QmdfzY6p5EpkYMN8wcomF2a1GsJbhkPiRQVRYSPfS4NZtB";
    /**
     * The Future Value of the debt ceiling by the end of the agreement:
     *   - 30,000,00 USD: Debt Ceiling
     *   - 0.05% per year: Stability Fee
     *   - 2.9 years: Duration of the Loan
     *
     *     bc -l <<< 'scale=18; (30000000 * e( l(1.0005) * 2.9 ))'
     */
    uint256 constant RWA008_A_INITIAL_PRICE    = 30_043_520_665599336150000000;
    uint48  constant RWA008_A_TAU              = 0;

    // Ilk registry params
    uint256 constant RWA008_REG_CLASS_RWA      = 3;

    // Remaining params
    uint256 constant RWA008_A_LINE             = 30_000_000;
    uint256 constant RWA008_A_MAT              = 100_00; // 100% in basis-points
    uint256 constant RWA008_A_RATE             = ZERO_ZERO_FIVE_PCT_RATE;
    // -- RWA008 end --

    // -- RWA009 MIP21 components --
    address immutable MCD_JOIN_RWA009_A_OLD   = DssExecLib.getChangelogAddress("MCD_JOIN_RWA009_A");
    address immutable RWA009_A_URN_OLD        = DssExecLib.getChangelogAddress("RWA009_A_URN");

    address constant RWA009                   = 0xfD775125701524461580Bf865f33068E4710591b;
    address constant MCD_JOIN_RWA009_A        = 0xE1ee48D4a7d28078a1BEb6b3C0fe8391669661Fb;
    address constant RWA009_A_URN             = 0xd334bbA9172a6F615Be93d194d1322148fb5222e;
    address constant RWA009_A_JAR             = 0xad4e1696d008A656F810498A974C5D3dC4A6150d;
    // Goerli: DS Pause Proxy / Mainnet: Genesis
    address immutable RWA009_A_OUTPUT_CONDUIT = DssExecLib.getChangelogAddress("MCD_PAUSE_PROXY");

    // MIP21_LIQUIDATION_ORACLE params
    string  constant RWA009_DOC               = "QmZG31b6iLGGCLGD7ZUn8EDkE9kANPVMcHzEYkvyNWCZpG";
    uint256 constant RWA009_A_INITIAL_PRICE   = 100_000_000 * WAD; // No DssExecLib helper, so WAD is required
    uint48  constant RWA009_A_TAU             = 0;

    // Ilk registry params
    uint256 constant RWA009_REG_CLASS_RWA     = 3;

    // Remaining params
    uint256 constant RWA009_A_LINE            = 100_000_000;
    uint256 constant RWA009_A_MAT             = 100_00; // 100% in basis-points
    uint256 constant RWA009_A_RATE            = ZERO_PCT_RATE;

    // -- RWA009 END --

    function onboardRwa008(
        ChainlogAbstract CHANGELOG,
        IlkRegistryAbstract REGISTRY,
        address MIP21_LIQUIDATION_ORACLE,
        address MCD_VAT,
        address MCD_JUG,
        address MCD_SPOT,
        address MCD_JOIN_DAI,
        address MCD_DAI
    ) internal {
        // RWA008-A collateral deploy
        bytes32 ilk      = "RWA008-A";
        uint256 decimals = DSTokenAbstract(RWA008).decimals();

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_RWA008_A).vat() == MCD_VAT,  "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA008_A).ilk() == ilk,      "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA008_A).gem() == RWA008,   "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA008_A).dec() == decimals, "join-dec-not-match");

        require(RwaUrnLike(RWA008_A_URN).vat()           == MCD_VAT,                 "urn-vat-not-match");
        require(RwaUrnLike(RWA008_A_URN).jug()           == MCD_JUG,                 "urn-jug-not-match");
        require(RwaUrnLike(RWA008_A_URN).daiJoin()       == MCD_JOIN_DAI,            "urn-daijoin-not-match");
        require(RwaUrnLike(RWA008_A_URN).gemJoin()       == MCD_JOIN_RWA008_A,       "urn-gemjoin-not-match");
        require(RwaUrnLike(RWA008_A_URN).outputConduit() == RWA008_A_OUTPUT_CONDUIT, "urn-outputconduit-not-match");

        require(RwaInputConduitLike(RWA008_A_INPUT_CONDUIT).dai() == MCD_DAI,      "inputconduit-dai-not-match");
        require(RwaInputConduitLike(RWA008_A_INPUT_CONDUIT).to()  == RWA008_A_URN, "inputconduit-to-not-match");

        require(RwaOutputConduitLike(RWA008_A_OUTPUT_CONDUIT).dai() == MCD_DAI, "outputconduit-dai-not-match");

        // Init the RwaLiquidationOracle
        // RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).init(ilk, RWA008_A_INITIAL_PRICE, RWA008_DOC, RWA008_A_TAU);
        (, address pip, , ) = RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).ilks(ilk);

        // Set price feed for RWA008
        // DssExecLib.setContract(MCD_SPOT, ilk, "pip", pip);

        // Init RWA008 in Vat
        // Initializable(MCD_VAT).init(ilk);
        // Init RWA008 in Jug
        // Initializable(MCD_JUG).init(ilk);

        // Allow RWA008 Join to modify Vat registry
        DssExecLib.authorize(MCD_VAT, MCD_JOIN_RWA008_A);
        // Disallows old RWA008 Join in the Vat
        DssExecLib.deauthorize(MCD_VAT, MCD_JOIN_RWA008_A_OLD);

        // Set the debt ceiling
        // DssExecLib.increaseIlkDebtCeiling(ilk, RWA008_A_LINE, /* _global = */ true);

        // Set the stability fee
        // DssExecLib.setIlkStabilityFee(ilk, RWA008_A_RATE, /* _doDrip = */ false);

        // Set the collateralization ratio
        // DssExecLib.setIlkLiquidationRatio(ilk, RWA008_A_MAT);

        // Poke the spotter to pull in a price
        // DssExecLib.updateCollateralPrice(ilk);

        // Give the urn permissions on the join adapter
        DssExecLib.authorize(MCD_JOIN_RWA008_A, RWA008_A_URN);

        // Helper contract permisison on URN
        RwaUrnLike(RWA008_A_URN).hope(RWA008_A_URN_CLOSE_HELPER);
        RwaUrnLike(RWA008_A_URN).hope(RWA008_A_OPERATOR);

        // Set up output conduit
        RwaOutputConduitLike(RWA008_A_OUTPUT_CONDUIT).hope(RWA008_A_OPERATOR);

        // Whitelist DIIS Group in the conduits
        RwaOutputConduitLike(RWA008_A_OUTPUT_CONDUIT).mate(RWA008_A_MATE);
        RwaInputConduitLike(RWA008_A_INPUT_CONDUIT)  .mate(RWA008_A_MATE);

        // Whitelist Socgen in the conduits as a fallback for DIIS Group
        RwaOutputConduitLike(RWA008_A_OUTPUT_CONDUIT).mate(RWA008_A_OPERATOR);
        RwaInputConduitLike(RWA008_A_INPUT_CONDUIT)  .mate(RWA008_A_OPERATOR);

        // Add RWA008 contract to the changelog
        CHANGELOG.setAddress("RWA008",                  RWA008);
        // CHANGELOG.setAddress("PIP_RWA008",              pip);
        CHANGELOG.setAddress("MCD_JOIN_RWA008_A",       MCD_JOIN_RWA008_A);
        CHANGELOG.setAddress("RWA008_A_URN",            RWA008_A_URN);
        CHANGELOG.setAddress("RWA008_A_INPUT_CONDUIT",  RWA008_A_INPUT_CONDUIT);
        CHANGELOG.setAddress("RWA008_A_OUTPUT_CONDUIT", RWA008_A_OUTPUT_CONDUIT);

        REGISTRY.put(
            ilk,
            MCD_JOIN_RWA008_A,
            RWA008,
            decimals,
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
        address MCD_SPOT,
        address MCD_JOIN_DAI
    ) internal {
        // RWA009-A collateral deploy
        bytes32 ilk      = "RWA009-A";
        uint256 decimals = DSTokenAbstract(RWA009).decimals();

        // Set the output conduit to be the MCD_PAUSE_PROXY
        DssExecLib.setContract(RWA009_A_URN, "outputConduit", RWA009_A_OUTPUT_CONDUIT);

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_RWA009_A).vat() == MCD_VAT,  "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA009_A).ilk() == ilk,      "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA009_A).gem() == RWA009,   "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA009_A).dec() == decimals, "join-dec-not-match");

        require(RwaUrnLike(RWA009_A_URN).vat()           == MCD_VAT,                 "urn-vat-not-match");
        require(RwaUrnLike(RWA009_A_URN).jug()           == MCD_JUG,                 "urn-jug-not-match");
        require(RwaUrnLike(RWA009_A_URN).daiJoin()       == MCD_JOIN_DAI,            "urn-daijoin-not-match");
        require(RwaUrnLike(RWA009_A_URN).gemJoin()       == MCD_JOIN_RWA009_A,       "urn-gemjoin-not-match");
        require(RwaUrnLike(RWA009_A_URN).outputConduit() == RWA009_A_OUTPUT_CONDUIT, "urn-outputconduit-not-match");

        // Init the RwaLiquidationOracle
        // RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).init(ilk, RWA009_A_INITIAL_PRICE, RWA009_DOC, RWA009_A_TAU);
        (, address pip, , ) = RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).ilks(ilk);

        // Set price feed for RWA009
        // DssExecLib.setContract(MCD_SPOT, ilk, "pip", pip);

        // Init RWA009 in Vat
        // Initializable(MCD_VAT).init(ilk);
        // Init RWA009 in Jug
        // Initializable(MCD_JUG).init(ilk);

        // Allow RWA009 Join to modify Vat registry
        DssExecLib.authorize(MCD_VAT, MCD_JOIN_RWA009_A);
        // Disallows old RWA009 Join in the Vat
        DssExecLib.deauthorize(MCD_VAT, MCD_JOIN_RWA009_A_OLD);

        // 100m debt ceiling
        // DssExecLib.increaseIlkDebtCeiling(ilk, RWA009_A_LINE, /* _global = */ true);

        // Set the stability fee
        // DssExecLib.setIlkStabilityFee(ilk, RWA009_A_RATE, /* _doDrip = */ false);

        // Set collateralization ratio
        // DssExecLib.setIlkLiquidationRatio(ilk, RWA009_A_MAT);

        // Poke the spotter to pull in a price
        // DssExecLib.updateCollateralPrice(ilk);

        // Give the urn permissions on the join adapter
        DssExecLib.authorize(MCD_JOIN_RWA009_A, RWA009_A_URN);

        // MCD_PAUSE_PROXY permission on URN
        RwaUrnLike(RWA009_A_URN).hope(address(this));

        // Add RWA009 contract to the changelog
        CHANGELOG.setAddress("RWA009",                  RWA009);
        // CHANGELOG.setAddress("PIP_RWA009",              pip);
        CHANGELOG.setAddress("MCD_JOIN_RWA009_A",       MCD_JOIN_RWA009_A);
        CHANGELOG.setAddress("RWA009_A_URN",            RWA009_A_URN);
        CHANGELOG.setAddress("RWA009_A_JAR",            RWA009_A_JAR);
        CHANGELOG.setAddress("RWA009_A_OUTPUT_CONDUIT", RWA009_A_OUTPUT_CONDUIT);

        // Add RWA009 to ILK REGISTRY
        REGISTRY.put(
            ilk,
            MCD_JOIN_RWA009_A,
            RWA009,
            decimals,
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
        address MCD_VAT                  = DssExecLib.vat();
        address MCD_DAI                  = DssExecLib.dai();
        address MCD_JUG                  = DssExecLib.jug();
        address MCD_SPOT                 = DssExecLib.spotter();
        address MCD_JOIN_DAI             = DssExecLib.daiJoin();

        // --------------------------- RWA Collateral onboarding ---------------------------

        // Add missing authorization on Goerli (this is necessary for all the MIP21 RWAs)
        // It was forgotten to be added since the Kovan => Goerli migration happened
        DssExecLib.authorize(MCD_VAT, MIP21_LIQUIDATION_ORACLE);

        // Onboard SocGen: https://vote.makerdao.com/polling/QmajCtnG
        onboardRwa008(CHANGELOG, REGISTRY, MIP21_LIQUIDATION_ORACLE, MCD_VAT, MCD_JUG, MCD_SPOT, MCD_JOIN_DAI, MCD_DAI);

        // Onboard HvB: https://vote.makerdao.com/polling/QmQMDasC
        onboardRwa009(CHANGELOG, REGISTRY, MIP21_LIQUIDATION_ORACLE, MCD_VAT, MCD_JUG, MCD_SPOT, MCD_JOIN_DAI);
    }

    function offboardCollaterals() internal {}
}
