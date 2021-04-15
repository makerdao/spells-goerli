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

import {Fileable, ChainlogLike} from "dss-exec-lib/DssExecLib.sol";
import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";
import "dss-interfaces/dss/IlkRegistryAbstract.sol";
import "dss-interfaces/dss/VatAbstract.sol";
import "dss-interfaces/dss/GemJoinAbstract.sol";
import "dss-interfaces/dss/JugAbstract.sol";
import "dss-interfaces/dss/SpotAbstract.sol";
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

interface RwaLiquidationLike {
    function ilks(bytes32) external returns (string memory,address,uint48,uint48);
    function init(bytes32, uint256, string calldata, uint48) external;
}

contract DssSpellAction is DssAction {

    string public constant description = "Kovan Spell";

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    address constant RWA002_OPERATOR         = 0x2CfADbd094a4D650049C53832B15842a3c59Db34;
    address constant RWA002_GEM              = 0xea8a2f6DC9236edb3f53744f5019a444e24F4379;
    address constant MCD_JOIN_RWA002_A       = 0x3B3fAD77D6977a19cc7B156143056a3E9C6Ca329;
    address constant RWA002_A_URN            = 0xc615F4188C255445290fB9E6dB5E021fe4CA8ECf;
    address constant RWA002_A_INPUT_CONDUIT  = 0x2CfADbd094a4D650049C53832B15842a3c59Db34;
    address constant RWA002_A_OUTPUT_CONDUIT = 0x2CfADbd094a4D650049C53832B15842a3c59Db34;

    uint256 constant THREE_PT_FIVE_PCT      = 1000000001090862085746321732;

    // precision
    uint256 constant public MILLION  = 10 ** 6;
    uint256 constant public WAD      = 10 ** 18;
    uint256 constant public RAY      = 10 ** 27;
    uint256 constant public RAD      = 10 ** 45;


    function actions() public override {
        // --------------------- Replace MIP22 ---------------------

        // Remove old NS2DRP (now RWA002)
        address MCD_VAT      = DssExecLib.vat();
        address ILK_REGISTRY = DssExecLib.reg();
        ChainlogLike CHANGELOG = ChainlogLike(
            DssExecLib.getChangelogAddress("CHANGELOG")
        );

        bytes32 oldIlk = "NS2DRP-A";

        VatAbstract(MCD_VAT).file(oldIlk, "line", 0);
        VatAbstract(MCD_VAT).deny(
            DssExecLib.getChangelogAddress("MCD_JOIN_NS2DRP_A")
        );

        CHANGELOG.removeAddress("NS2DRP");
        CHANGELOG.removeAddress("MCD_JOIN_NS2DRP_A");
        CHANGELOG.removeAddress("PIP_NS2DRP");
        CHANGELOG.removeAddress("NS2DRP_A_URN");
        CHANGELOG.removeAddress("NS2DRP_A_INPUT_CONDUIT");
        CHANGELOG.removeAddress("NS2DRP_A_OUTPUT_CONDUIT");

        IlkRegistryAbstract(ILK_REGISTRY).removeAuth(oldIlk);

        // Add fixed RWA002
        bytes32 ilk   = "RWA002-A";
        uint256 CEIL  = 5 * MILLION;
        uint256 PRICE = 5_634_804 * WAD;
        uint256 MAT   = 10_500;
        uint48 TAU    = 0;

        // https://ipfs.io/ipfs/QmdfuQSLmNFHoxvMjXvv8qbJ2NWprrsvp5L3rGr3JHw18E
        string memory DOC = "QmdfuQSLmNFHoxvMjXvv8qbJ2NWprrsvp5L3rGr3JHw18E";

        address MIP21_LIQUIDATION_ORACLE =
            DssExecLib.getChangelogAddress("MIP21_LIQUIDATION_ORACLE");

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_RWA002_A).vat() == MCD_VAT, "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA002_A).ilk() == ilk, "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA002_A).gem() == RWA002_GEM, "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA002_A).dec() == DSTokenAbstract(RWA002_GEM).decimals(), "join-dec-not-match");

        RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).init(
            ilk, PRICE, DOC, TAU
        );
        (,address pip,,) = RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).ilks(ilk);

        // Set price feed for RWA002
        DssExecLib.setContract(DssExecLib.spotter(), ilk, "pip", pip);

        // Init RWA-002 in Vat
        Initializable(MCD_VAT).init(ilk);
        // Init RWA-002 in Jug
        Initializable(DssExecLib.jug()).init(ilk);

        // Allow RWA-002 Join to modify Vat registry
        DssExecLib.authorize(MCD_VAT, MCD_JOIN_RWA002_A);

        // Allow RwaLiquidationOracle to modify Vat registry
        // DssExecLib.authorize(MCD_VAT, MIP21_LIQUIDATION_ORACLE);

        // Set the ilk debt ceiling (not increasing global one as we are replacing the collateral)
        DssExecLib.setIlkDebtCeiling(ilk, CEIL);

        // No dust
        // DssExecLib.setIlkMinVaultAmount(ilk, 0);

        // stability fee
        DssExecLib.setIlkStabilityFee(ilk, THREE_PT_FIVE_PCT, false);

        // collateralization ratio
        DssExecLib.setIlkLiquidationRatio(ilk, MAT);

        // poke the spotter to pull in a price
        DssExecLib.updateCollateralPrice(ilk);

        // give the urn permissions on the join adapter
        // DssExecLib.authorize(MCD_JOIN_RWA002_A, RWA002_A_URN);

        // set up the urn
        Hopeable(RWA002_A_URN).hope(RWA002_OPERATOR);

        // set up output conduit
        // Hopeable(RWA002_A_OUTPUT_CONDUIT).hope(RWA002_OPERATOR);

        // Authorize the SC Domain team deployer address on the output conduit
        // during introductory phase. This allows the SC team to assist in the
        // testing of a complete circuit. Once a broker dealer arrangement is
        // established the deployer address should be `deny`ed on the conduit.
        // Kissable(RWA002_A_OUTPUT_CONDUIT).kiss(SC_DOMAIN_DEPLOYER_07);

        // Add collateral in IlkRegistry
        IlkRegistryAbstract(ILK_REGISTRY).put(
            ilk,
            MCD_JOIN_RWA002_A,
            RWA002_GEM,
            18,
            3,
            pip,
            address(0),
            "RWA-002",
            "RWA002"
        );

        // add RWA-002 contract to the changelog
        DssExecLib.setChangelogAddress("RWA002", RWA002_GEM);
        DssExecLib.setChangelogAddress("PIP_RWA002", pip);
        DssExecLib.setChangelogAddress("MCD_JOIN_RWA002_A", MCD_JOIN_RWA002_A);
        DssExecLib.setChangelogAddress("RWA002_A_URN", RWA002_A_URN);
        DssExecLib.setChangelogAddress(
            "RWA002_A_INPUT_CONDUIT", RWA002_A_INPUT_CONDUIT
        );
        DssExecLib.setChangelogAddress(
            "RWA002_A_OUTPUT_CONDUIT", RWA002_A_OUTPUT_CONDUIT
        );
        DssExecLib.setChangelogVersion("1.2.11");

        // --------------------- Remove ESM_BUG ---------------------
        address MCD_ESM          = DssExecLib.getChangelogAddress("MCD_ESM_ATTACK");
        address MCD_ESM_BUG      = DssExecLib.getChangelogAddress("MCD_ESM_BUG");
        address MCD_END          = DssExecLib.end();

        DssExecLib.deauthorize(MCD_END, MCD_ESM_BUG);

        CHANGELOG.removeAddress("MCD_ESM_BUG");
        CHANGELOG.removeAddress("MCD_ESM_ATTACK");
        DssExecLib.setChangelogAddress("MCD_ESM", MCD_ESM);

        DssExecLib.setChangelogVersion("1.3.0");
    }

}

contract DssSpell is DssExec {
    DssSpellAction internal action_ = new DssSpellAction();
    constructor() DssExec(action_.description(), block.timestamp + 30 days, address(action_)) public {}
}
