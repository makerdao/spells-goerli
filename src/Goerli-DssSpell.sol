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
// pragma experimental ABIEncoderV2;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

import { DssSpellCollateralAction } from "./Goerli-DssSpellCollateral.sol";

import {
    VatAbstract,
    JugAbstract,
    CureAbstract
} from "dss-interfaces/Interfaces.sol";

interface TeleportJoinLike {
    function file(bytes32,bytes32,address) external;
    function file(bytes32,bytes32,uint256) external;
}

interface TeleportOracleAuthLike {
    function file(bytes32,uint256) external;
    function addSigners(address[] calldata) external;
}

interface EscrowLike {
    function approve(address,address,uint256) external;
}

contract DssSpellAction is DssAction, DssSpellCollateralAction {

    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    address internal constant TELEPORT_JOIN = 0xAaEf3f1523291aDdaF98a8535c27F25971d823D2;
    address internal constant ORACLE_AUTH = 0xD40ab915cB8232E8188e1a9137E4b5dCB86F0fd8;
    address internal constant ROUTER = 0x75c2D0A33cB245acD1F10798fEdD4a42Be4951a9;
    address internal constant LINEAR_FEE = 0x72Cb460888D401f991AB1a78ffc48EFcDcd155e8;

    bytes32 constant internal ILK = "TELEPORT-FW-A";
    bytes32 constant internal DOMAIN_ETH = "ETH-MAIN-A";

    bytes32 constant internal DOMAIN_OPT = "OPT-MAIN-A";
    address internal constant TELEPORT_GATEWAY_OPT = 0xe57e6b2eEEf91C068849bd6066d1041A00A4F654;
    address internal constant ESCROW_OPT = 0xbc892A208705862273008B2Fb7D01E968be42653;
    address internal constant DAI_BRIDGE_OPT = 0x05a388Db09C2D44ec0b00Ee188cD42365c42Df23;
    address internal constant GOV_RELAY_OPT = 0xD9b2835A5bFC8bD5f54DB49707CF48101C66793a;

    bytes32 constant internal DOMAIN_ARB = "ARB-ONE-A";
    address internal constant TELEPORT_GATEWAY_ARB = 0x3F7Eea7c2D08bc6F249759082360E14c829b2A92;
    address internal constant ESCROW_ARB = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
    address internal constant DAI_BRIDGE_ARB = 0x467194771dAe2967Aef3ECbEDD3Bf9a310C76C65;
    address internal constant GOV_RELAY_ARB = 0x10E6593CDda8c58a1d0f14C5164B376352a55f2F;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmVp4mhhbwWGTfbh2BzwQB9eiBrQBKiqcPRZCaAxNUaar6
    //
    uint256 internal constant ZERO_PCT = 1000000000000000000000000000;

    uint256 internal constant WAD = 10**18;
    uint256 internal constant RAY = 10**27;
    uint256 internal constant RAD = 10**45;

    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {
        // ---------------------------------------------------------------------
        // Includes changes from the DssSpellCollateralAction
        // onboardNewCollaterals();

        // ----------------------------- Setup Teleport Fast Withdrawals -----------------------------
        //

        // Setup new ilk
        VatAbstract vat = DssExecLib.vat();
        JugAbstract jug = DssExecLib.jug();
        CureAbstract cure = DssExecLib.cure();
        address dai = DssExecLib.dai();

        vat.init(ILK);
        jug.init(ILK);

        DssExecLib.increaseGlobalDebtCeiling(2_000_000);
        DssExecLib.setIlkDebtCeiling(ILK, 2_000_000);
        DssExecLib.setIlkStabilityFee(ILK, ZERO_PCT, true);
        vat.file(ILK, "spot", RAY);

        cure.lift(TELEPORT_JOIN);

        vat.rely(TELEPORT_JOIN);

        // Configure TeleportJoin
        // Note: vow already set

        TeleportJoinLike(TELEPORT_JOIN).file("fees", DOMAIN_OPT, LINEAR_FEE);
        TeleportJoinLike(TELEPORT_JOIN).file("line", DOMAIN_OPT, 1_000_000 * WAD);

        TeleportJoinLike(TELEPORT_JOIN).file("fees", DOMAIN_ARB, LINEAR_FEE);
        TeleportJoinLike(TELEPORT_JOIN).file("line", DOMAIN_ARB, 1_000_000 * WAD);

        // Configure TeleportOracleAuth
        TeleportOracleAuthLike(ORACLE_AUTH).file("threshold", 1);
        // TODO add signers

        // Configure TeleportRouter
        // Note: ETH-MAIN-A route already defined

        // Authorize TeleportGateways to use the escrows
        EscrowLike(ESCROW_OPT).approve(dai, TELEPORT_GATEWAY_OPT, type(uint256).max);
        EscrowLike(ESCROW_ARB).approve(dai, TELEPORT_GATEWAY_ARB, type(uint256).max);

        // Configure Chainlog
        DssExecLib.setChangelogAddress("MCD_JOIN_TELEPORT_FW_A", TELEPORT_JOIN);
        DssExecLib.setChangelogAddress("MCD_ORACLE_AUTH_TELEPORT_FW_A", ORACLE_AUTH);
        DssExecLib.setChangelogAddress("MCD_ROUTER_TELEPORT_FW_A", ROUTER);

        // Note: GOERLI-ONLY - missing bridge entries
        DssExecLib.setChangelogAddress("OPTIMISM_DAI_BRIDGE", DAI_BRIDGE_OPT);
        DssExecLib.setChangelogAddress("OPTIMISM_ESCROW", ESCROW_OPT);
        DssExecLib.setChangelogAddress("OPTIMISM_GOV_RELAY", GOV_RELAY_OPT);
        DssExecLib.setChangelogAddress("ARBITRUM_DAI_BRIDGE", DAI_BRIDGE_ARB);
        DssExecLib.setChangelogAddress("ARBITRUM_ESCROW", ESCROW_ARB);
        DssExecLib.setChangelogAddress("ARBITRUM_GOV_RELAY", GOV_RELAY_ARB);

        DssExecLib.setChangelogVersion("1.14.0");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
