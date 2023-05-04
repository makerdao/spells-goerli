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

pragma solidity 0.8.16;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";
import "dss-interfaces/dss/IlkRegistryAbstract.sol";
import "dss-interfaces/dss/GemJoinAbstract.sol";
import "dss-interfaces/ERC/GemAbstract.sol";

interface Initializable {
    function init(bytes32) external;
}

interface RwaLiquidationLike {
    function ilks(bytes32) external view returns (string memory, address, uint48, uint48);
    function init(bytes32, uint256, string calldata, uint48) external;
}

interface RwaUrnLike {
    function lock(uint256) external;
    function vat() external view returns (address);
    function jug() external view returns (address);
    function gemJoin() external view returns (address);
    function daiJoin() external view returns (address);
    function outputConduit() external view returns (address);
    function hope(address) external;
}

interface RwaJarLike {
    function chainlog() external view returns (address);
    function dai() external view returns (address);
    function daiJoin() external view returns (address);
}

interface RwaInputConduitLike {
    function dai() external view returns(address);
    function gem() external view returns(address);
    function psm() external view returns(address);
    function to() external view returns(address);
    function mate(address) external;
    function file(bytes32 what, address data) external;
}

interface RwaOutputConduitLike {
    function dai() external view returns (address);
    function gem() external view returns (address);
    function psm() external view returns (address);
    function file(bytes32 what, address data) external;
    function hope(address) external;
    function mate(address) external;
    function kiss(address) external;
}

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Turn office hours off
    function officeHours() public pure override returns (bool) {
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
    // uint256 internal constant X_PCT_RATE      = ;

    uint256 internal constant ZERO_PT_SEVENTY_FIVE_PCT_RATE  = 1000000000236936036262880196;
    uint256 internal constant ONE_PCT_RATE                   = 1000000000315522921573372069;
    uint256 internal constant ONE_PT_SEVENTY_FIVE_PCT_RATE   = 1000000000550121712943459312;
    uint256 internal constant THREE_PT_TWENTY_FIVE_PCT_RATE  = 1000000001014175731521720677;

    uint256 internal constant WAD                            = 10 ** 18;
    uint256 internal constant MILLION                        = 10 ** 6;

    // -- RWA014 MIP21 components --
    address internal constant RWA014                         = 0x22a7440DCfF0E8881Ec93cE519c34C15feB2A09a;
    address internal constant MCD_JOIN_RWA014_A              = 0xc7Ba0aBa8512199c816834351CC978cf684D7fD9;
    address internal constant RWA014_A_URN                   = 0xb475F63163aE3b0D5f6e30Dd914F5aA7204B1169;
    address internal constant RWA014_A_JAR                   = 0x398E36Ed3c6bEf85f78b03d08b1980c6c3dd5357;
    address internal constant RWA014_A_INPUT_CONDUIT_URN     = 0x3b749869f62694804B0411DA77F13e816C49A25F;
    address internal constant RWA014_A_INPUT_CONDUIT_JAR     = 0xa9C909eDD4ee06D625EaDD546CccDB1BB3e02D02;
    address internal constant RWA014_A_OUTPUT_CONDUIT        = 0x563c3CD928DB7cAf5B9872bFa2dd0E4F31158256;
    // TODO: IPFS link
    string  internal constant RWA014_DOC                     = "TODO";
    uint256 internal constant RWA014_A_INITIAL_PRICE         = 500_000_000 * WAD;
    uint48  internal constant RWA014_A_TAU                   = 0;
    // Ilk registry params
    uint256 internal constant RWA014_REG_CLASS_RWA           = 3;
    // Remaining params
    uint256 internal constant RWA014_A_LINE                  = 500_000_000;
    uint256 internal constant RWA014_A_MAT                   = 100_00;
    // Operator address
    address internal constant RWA014_A_OPERATOR              = address(0); // TODO
    // Custody address
    address internal constant RWA014_A_COINBASE_CUSTODY      = address(0); // TODO
    // -- RWA014 END --

    address internal immutable REGISTRY                      = DssExecLib.reg();
    address internal immutable MIP21_LIQUIDATION_ORACLE      = DssExecLib.getChangelogAddress("MIP21_LIQUIDATION_ORACLE");
    address internal immutable MCD_PSM_USDC_A                = DssExecLib.getChangelogAddress("MCD_PSM_USDC_A");
    address internal immutable MCD_VAT                       = DssExecLib.vat();
    address internal immutable MCD_JUG                       = DssExecLib.jug();
    address internal immutable MCD_SPOT                      = DssExecLib.spotter();
    address internal immutable MCD_JOIN_DAI                  = DssExecLib.daiJoin();

    function onboardRWA014() internal {
        bytes32 ilk      = "RWA014-A";
        uint256 decimals = GemAbstract(RWA014).decimals();

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_RWA014_A).vat()                             == MCD_VAT,                                    "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA014_A).ilk()                             == ilk,                                        "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA014_A).gem()                             == RWA014,                                     "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA014_A).dec()                             == decimals,                                   "join-dec-not-match");

        require(RwaUrnLike(RWA014_A_URN).vat()                                       == MCD_VAT,                                    "urn-vat-not-match");
        require(RwaUrnLike(RWA014_A_URN).jug()                                       == MCD_JUG,                                    "urn-jug-not-match");
        require(RwaUrnLike(RWA014_A_URN).daiJoin()                                   == MCD_JOIN_DAI,                               "urn-daijoin-not-match");
        require(RwaUrnLike(RWA014_A_URN).gemJoin()                                   == MCD_JOIN_RWA014_A,                          "urn-gemjoin-not-match");
        require(RwaUrnLike(RWA014_A_URN).outputConduit()                             == RWA014_A_OUTPUT_CONDUIT,                    "urn-outputconduit-not-match");
        
        require(RwaJarLike(RWA014_A_JAR).chainlog()                                  == DssExecLib.LOG,                             "jar-chainlog-not-match");
        require(RwaJarLike(RWA014_A_JAR).dai()                                       == DssExecLib.dai(),                           "jar-dai-not-match");
        require(RwaJarLike(RWA014_A_JAR).daiJoin()                                   == MCD_JOIN_DAI,                               "jar-daijoin-not-match");

        require(RwaOutputConduitLike(RWA014_A_OUTPUT_CONDUIT).dai()                  == DssExecLib.dai(),                           "output-conduit-dai-not-match");
        require(RwaOutputConduitLike(RWA014_A_OUTPUT_CONDUIT).gem()                  == DssExecLib.getChangelogAddress("USDC"),     "output-conduit-gem-not-match");
        require(RwaOutputConduitLike(RWA014_A_OUTPUT_CONDUIT).psm()                  == MCD_PSM_USDC_A,                             "output-conduit-psm-not-match");
        
        require(RwaInputConduitLike(RWA014_A_INPUT_CONDUIT_URN).psm()                == MCD_PSM_USDC_A,                             "input-conduit-urn-psm-not-match");
        require(RwaInputConduitLike(RWA014_A_INPUT_CONDUIT_URN).to()                 == RWA014_A_URN,                               "input-conduit-urn-to-not-match");
        require(RwaInputConduitLike(RWA014_A_INPUT_CONDUIT_URN).dai()                == DssExecLib.dai(),                           "input-conduit-urn-dai-not-match");
        require(RwaInputConduitLike(RWA014_A_INPUT_CONDUIT_URN).gem()                == DssExecLib.getChangelogAddress("USDC"),     "input-conduit-urn-gem-not-match");

        require(RwaInputConduitLike(RWA014_A_INPUT_CONDUIT_JAR).psm()                == MCD_PSM_USDC_A,                             "input-conduit-jar-psm-not-match");
        require(RwaInputConduitLike(RWA014_A_INPUT_CONDUIT_JAR).to()                 == RWA014_A_JAR,                               "input-conduit-jar-to-not-match");
        require(RwaInputConduitLike(RWA014_A_INPUT_CONDUIT_JAR).dai()                == DssExecLib.dai(),                           "input-conduit-jar-dai-not-match");
        require(RwaInputConduitLike(RWA014_A_INPUT_CONDUIT_JAR).gem()                == DssExecLib.getChangelogAddress("USDC"),     "input-conduit-jar-gem-not-match");


        // Init the RwaLiquidationOracle
        RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).init(ilk, RWA014_A_INITIAL_PRICE, RWA014_DOC, RWA014_A_TAU);
        (, address pip, , ) = RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).ilks(ilk);

        // Init RWA014 in Vat
        Initializable(MCD_VAT).init(ilk);
        // Init RWA014 in Jug
        Initializable(MCD_JUG).init(ilk);

        // Allow RWA014 Join to modify Vat registry
        DssExecLib.authorize(MCD_VAT, MCD_JOIN_RWA014_A);

        // 1m debt ceiling
        DssExecLib.increaseIlkDebtCeiling(ilk, RWA014_A_LINE, /* _global = */ true);

        // Set price feed for RWA014
        DssExecLib.setContract(MCD_SPOT, ilk, "pip", pip);

        // Set collateralization ratio
        DssExecLib.setIlkLiquidationRatio(ilk, RWA014_A_MAT);

        // Poke the spotter to pull in a price
        DssExecLib.updateCollateralPrice(ilk);

        // Give the urn permissions on the join adapter
        DssExecLib.authorize(MCD_JOIN_RWA014_A, RWA014_A_URN);

        // MCD_PAUSE_PROXY and Monetalis permission on URN
        RwaUrnLike(RWA014_A_URN).hope(address(this));
        RwaUrnLike(RWA014_A_URN).hope(address(RWA014_A_OPERATOR));

        // MCD_PAUSE_PROXY and Monetalis permission on RWA014_A_OUTPUT_CONDUIT
        RwaOutputConduitLike(RWA014_A_OUTPUT_CONDUIT).hope(address(this));
        RwaOutputConduitLike(RWA014_A_OUTPUT_CONDUIT).mate(address(this));
        RwaOutputConduitLike(RWA014_A_OUTPUT_CONDUIT).hope(RWA014_A_OPERATOR);
        RwaOutputConduitLike(RWA014_A_OUTPUT_CONDUIT).mate(RWA014_A_OPERATOR);
        // Coinbase custody whitelist for URN destination address
        RwaOutputConduitLike(RWA014_A_OUTPUT_CONDUIT).kiss(address(RWA014_A_COINBASE_CUSTODY));
        // Set "quitTo" address for RWA014_A_OUTPUT_CONDUIT
        RwaOutputConduitLike(RWA014_A_OUTPUT_CONDUIT).file("quitTo", RWA014_A_URN);

        // MCD_PAUSE_PROXY and Monetalis permission on RWA014_A_INPUT_CONDUIT_URN
        RwaInputConduitLike(RWA014_A_INPUT_CONDUIT_URN).mate(address(this));
        RwaInputConduitLike(RWA014_A_INPUT_CONDUIT_URN).mate(RWA014_A_OPERATOR);
        // Set "quitTo" address for RWA014_A_INPUT_CONDUIT_URN
        RwaInputConduitLike(RWA014_A_INPUT_CONDUIT_URN).file("quitTo", RWA014_A_COINBASE_CUSTODY);

        // MCD_PAUSE_PROXY and Monetalis permission on RWA014_A_INPUT_CONDUIT_JAR
        RwaInputConduitLike(RWA014_A_INPUT_CONDUIT_JAR).mate(address(this));
        RwaInputConduitLike(RWA014_A_INPUT_CONDUIT_JAR).mate(RWA014_A_OPERATOR);
        // Set "quitTo" address for RWA014_A_INPUT_CONDUIT_JAR
        RwaInputConduitLike(RWA014_A_INPUT_CONDUIT_JAR).file("quitTo", RWA014_A_COINBASE_CUSTODY);

        // Add RWA014 contract to the changelog
        DssExecLib.setChangelogAddress("RWA014",                     RWA014);
        DssExecLib.setChangelogAddress("PIP_RWA014",                 pip);
        DssExecLib.setChangelogAddress("MCD_JOIN_RWA014_A",          MCD_JOIN_RWA014_A);
        DssExecLib.setChangelogAddress("RWA014_A_URN",               RWA014_A_URN);
        DssExecLib.setChangelogAddress("RWA014_A_JAR",               RWA014_A_JAR);
        DssExecLib.setChangelogAddress("RWA014_A_INPUT_CONDUIT_URN", RWA014_A_INPUT_CONDUIT_URN);
        DssExecLib.setChangelogAddress("RWA014_A_INPUT_CONDUIT_JAR", RWA014_A_INPUT_CONDUIT_JAR);
        DssExecLib.setChangelogAddress("RWA014_A_OUTPUT_CONDUIT",    RWA014_A_OUTPUT_CONDUIT);

        // Add RWA014 to ILK REGISTRY
        IlkRegistryAbstract(REGISTRY).put(
            ilk,
            MCD_JOIN_RWA014_A,
            RWA014,
            decimals,
            RWA014_REG_CLASS_RWA,
            pip,
            address(0),
            "RWA014-A: Coinbase Custody",
            GemAbstract(RWA014).symbol()
        );
    }

    function actions() public override {

        // ---------- RWA014-A Onboarding ----------
        // Poll: https://vote.makerdao.com/polling/QmdRELY7#poll-detail
        // Forum: https://forum.makerdao.com/t/coinbase-custody-legal-assessment/20384

        onboardRWA014();
        // Lock RWA014 Token in the URN
        GemAbstract(RWA014).approve(RWA014_A_URN, 1 * WAD);
        RwaUrnLike(RWA014_A_URN).lock(1 * WAD);

        // ---------- Risk Parameters Changes (Stability Fee & DC-IAM) ----------
        // Poll: https://vote.makerdao.com/polling/QmYFfRuR#poll-detail
        // Forum: https://forum.makerdao.com/t/out-of-scope-proposed-risk-parameters-changes-stability-fee-dc-iam/20564

        // Increase ETH-A Stability Fee by 0.25% from 1.5% to 1.75%.
        DssExecLib.setIlkStabilityFee("ETH-A", ONE_PT_SEVENTY_FIVE_PCT_RATE, true);

        // Increase ETH-B Stability Fee by 0.25% from 3% to 3.25%.
        DssExecLib.setIlkStabilityFee("ETH-B", THREE_PT_TWENTY_FIVE_PCT_RATE, true);

        // Increase ETH-C Stability Fee by 0.25% from 0.75% to 1%.
        DssExecLib.setIlkStabilityFee("ETH-C", ONE_PCT_RATE, true);

        // Increase WSTETH-A Stability Fee by 0.25% from 1.5% to 1.75%.
        DssExecLib.setIlkStabilityFee("WSTETH-A", ONE_PT_SEVENTY_FIVE_PCT_RATE, true);

        // Increase WSTETH-B Stability Fee by 0.25% from 0.75% to 1%.
        DssExecLib.setIlkStabilityFee("WSTETH-B", ONE_PCT_RATE, true);

        // Increase RETH-A Stability Fee by 0.25% from 0.5% to 0.75%.
        DssExecLib.setIlkStabilityFee("RETH-A", ZERO_PT_SEVENTY_FIVE_PCT_RATE, true);

        // Increase CRVV1ETHSTETH-A Stability Fee by 0.25% from 1.5% to 1.75%.
        // NOTE: ignore in goerli
        // DssExecLib.setIlkStabilityFee("CRVV1ETHSTETH-A", ONE_SEVENTY_FIVE_PCT_RATE, true);


        // Increase the WSTETH-A gap by 15 million DAI from 15 million DAI to 30 million DAI.
        // Increase the WSTETH-A ttl by 21,600 seconds from 21,600 seconds to 43,200 seconds
        DssExecLib.setIlkAutoLineParameters("WSTETH-A", 500 * MILLION, 30 * MILLION, 12 hours);

        // Increase the WSTETH-B gap by 15 million DAI from 15 million DAI to 30 million DAI.
        // Increase the WSTETH-B ttl by 28,800 seconds from 28,800 seconds to 57,600 seconds.
        DssExecLib.setIlkAutoLineParameters("WSTETH-B", 500 * MILLION, 30 * MILLION, 16 hours);

        // Reduce the WBTC-A gap by 10 million DAI from 20 million DAI to 10 million DAI.
        DssExecLib.setIlkAutoLineParameters("WBTC-A", 500 * MILLION, 10 * MILLION, 24 hours);

        // Reduce the WBTC-B gap by 5 million DAI from 10 million DAI to 5 million DAI.
        DssExecLib.setIlkAutoLineParameters("WBTC-B", 250 * MILLION, 5 * MILLION, 24 hours);

        // Reduce the WBTC-C gap by 10 million DAI from 20 million DAI to 10 million DAI.
        DssExecLib.setIlkAutoLineParameters("WBTC-C", 500 * MILLION, 10 * MILLION, 24 hours);
        

        // Bump the chainlog
        DssExecLib.setChangelogVersion("1.14.12");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
