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

interface RwaLiquidationLike {
    function ilks(bytes32) external returns (string memory,address,uint48,uint48);
    function init(bytes32, uint256, string calldata, uint48) external;
}

interface RwaOutputConduitLike {
    function kiss(address) external;
}

contract DssSpellAction is DssAction {

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/TODO -q -O - 2>/dev/null)"
    string public constant override description = "Goerli Spell";

    address constant OPERATOR                 = 0xD23beB204328D7337e3d2Fb9F150501fDC633B0e;
    bytes32 constant ILK                      = "RWA001-A";
    address constant RWA001                   = 0xeb7C7DE82c3b05BD4059f11aE8f43dD7f1595bce;
    address constant MCD_JOIN_RWA001_A        = 0x088D6b3f68Bc4F93F90006A1356A21145EDD96E2;
    address constant RWA001_A_URN             = 0xF1AAB03fc1d3588B5910a960f476DbE88D304b9B;
    address constant RWA001_A_INPUT_CONDUIT   = 0x4145774D007C88392118f32E2c31686faCc9486E;
    address constant RWA001_A_OUTPUT_CONDUIT  = 0x969b3701A17391f2906d8c5E5D816aBcD9D0f199;
    address constant MIP21_LIQUIDATION_ORACLE = 0x362dfE51E4f91a8257B8276435792095EE5d85C3;

    address constant GENESIS_6S = 0xE5C35757c296FD19faA2bFF85e66C6B25AC8b978;

    uint256 constant THREE_PCT = 1000000000937303470807876289;
    uint256 constant MILLION = 10 ** 6;
    uint256 constant WAD     = 10 ** 18;

    uint256 constant RATE  = THREE_PCT;
    uint256 constant LINE  = 15 * MILLION;
    uint256 constant MAT   = 10_000;
    uint48  constant TAU   = 30 days;
    uint256 constant PRICE = 15_913_500 * WAD;
    string  constant DOC   = "QmdmAUTU3sd9VkdfTZNQM6krc9jsKgF2pz7W1qvvfJo1xk";

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {
        address vat = DssExecLib.vat();

        // Add MIP21 Liquidation Oracle key
        DssExecLib.setChangelogAddress("MIP21_LIQUIDATION_ORACLE", MIP21_LIQUIDATION_ORACLE);

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_RWA001_A).vat() == vat, "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA001_A).ilk() == ILK, "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA001_A).gem() == RWA001, "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA001_A).dec() == DSTokenAbstract(RWA001).decimals(), "join-dec-not-match");

        RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).init(
            ILK, PRICE, DOC, TAU
        );
        (,address pip,,) = RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).ilks(ILK);

        // Set price feed for RWA-00x
        DssExecLib.setContract(DssExecLib.spotter(), ILK, "pip", pip);

        // Init RWA-00x in Vat
        Initializable(vat).init(ILK);
        // Init RWA-00x in Jug
        Initializable(DssExecLib.jug()).init(ILK);

        // Allow RWA-00x Join to modify Vat registry
        DssExecLib.authorize(vat, MCD_JOIN_RWA001_A);

        // Set ilk/global DC
        DssExecLib.increaseIlkDebtCeiling(ILK, LINE, true);

        // Set stability fee
        DssExecLib.setIlkStabilityFee(ILK, RATE, false);

        // Set collateralization ratio
        DssExecLib.setIlkLiquidationRatio(ILK, MAT);

        // Poke the spotter to pull in a price
        DssExecLib.updateCollateralPrice(ILK);

        // Set up the urn
        Hopeable(RWA001_A_URN).hope(OPERATOR);

        // Add RWA-001 contract to the changelog
        DssExecLib.setChangelogAddress("RWA001", RWA001);
        DssExecLib.setChangelogAddress("PIP_RWA001", pip);
        DssExecLib.setChangelogAddress("MCD_JOIN_RWA001_A", MCD_JOIN_RWA001_A);
        DssExecLib.setChangelogAddress("RWA001_A_URN", RWA001_A_URN);
        DssExecLib.setChangelogAddress(
            "RWA001_A_INPUT_CONDUIT", RWA001_A_INPUT_CONDUIT
        );
        DssExecLib.setChangelogAddress(
            "RWA001_A_OUTPUT_CONDUIT", RWA001_A_OUTPUT_CONDUIT
        );

        // Add RWA001-A to the ilk registry
        IlkRegistryAbstract(DssExecLib.getChangelogAddress("ILK_REGISTRY")).put(
            ILK,
            MCD_JOIN_RWA001_A,
            RWA001,
            DSTokenAbstract(RWA001).decimals(),
            3,
            pip,
            address(0),
            "RWA001-A: 6s Capital",
            "RWA001"
        );

        // Adds the Genesis broker/dealer address to the output conduit
        RwaOutputConduitLike(RWA001_A_OUTPUT_CONDUIT).kiss(GENESIS_6S);
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
