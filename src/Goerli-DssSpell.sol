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

interface TeleportJoinLike {
    function rely(address) external;
    function file(bytes32,address) external;
    function file(bytes32,bytes32,address) external;
    function file(bytes32,bytes32,uint256) external;
    function vat() external view returns (address);
    function daiJoin() external view returns (address);
    function ilk() external view returns (bytes32);
    function domain() external view returns (bytes32);
}

interface TeleportRouterLike {
    function rely(address) external;
    function file(bytes32,bytes32,address) external;
    function gateways(bytes32) external view returns (address);
    function domains(address) external view returns (bytes32);
    function dai() external view returns (address);
}

interface TeleportFeeLike {
    function fee() external view returns (uint256);
    function ttl() external view returns (uint256);
}

interface EscrowLike {
    function approve(address,address,uint256) external;
}

interface TeleportBridgeLike {
    function starkNet() external view returns (address);
    function dai() external view returns (address);
    function l2DaiTeleportGateway() external view returns (uint256);
    function escrow() external view returns (address);
    function teleportRouter() external view returns (address);
}

contract DssSpellAction is DssAction, DssSpellCollateralAction {

    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    bytes32 internal constant ILK = "TELEPORT-FW-A";
    bytes32 internal constant DOMAIN_ETH = "ETH-GOER-A";

    bytes32 internal constant DOMAIN_STA = "STA-GOER-A";
    address internal constant TELEPORT_GATEWAY_STA = 0x61A1E227fd6Fdfa93F2bb50703E26637141714AE;
    uint256 internal constant TELEPORT_L2_GATEWAY_STA = 0x03a85abf730fb56410c92841a4439efcf24a2efe0085fb2e7807f0a6f48a1b39;
    address internal constant LINEAR_FEE = 0x95532D5c4e2064e8dC51F4D41C21f24B33c78BBC;
    uint256 internal constant WAD = 10**18;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmVp4mhhbwWGTfbh2BzwQB9eiBrQBKiqcPRZCaAxNUaar6
    //

    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {

        // ------------------ Setup Starknet Teleport Fast Withdrawals -----------------
        // https://vote.makerdao.com/polling/QmZxRgvG
        // https://forum.makerdao.com/t/request-for-poll-starknet-bridge-deposit-limit-and-starknet-teleport-fees/17187

        address escrow = DssExecLib.getChangelogAddress("STARKNET_ESCROW");
        address router = DssExecLib.getChangelogAddress("MCD_ROUTER_TELEPORT_FW_A");
        address join = DssExecLib.getChangelogAddress("MCD_JOIN_TELEPORT_FW_A");
        address starkNet = DssExecLib.getChangelogAddress("STARKNET_CORE");


        address dai = DssExecLib.dai();
        IlkRegistryAbstract ilkRegistry = IlkRegistryAbstract(DssExecLib.reg());

        // Run sanity checks
        require(TeleportBridgeLike(TELEPORT_GATEWAY_STA).escrow() == escrow);
        require(TeleportBridgeLike(TELEPORT_GATEWAY_STA).teleportRouter() == router);
        require(TeleportBridgeLike(TELEPORT_GATEWAY_STA).dai() == dai);
        require(TeleportBridgeLike(TELEPORT_GATEWAY_STA).l2DaiTeleportGateway() == TELEPORT_L2_GATEWAY_STA);
        require(TeleportBridgeLike(TELEPORT_GATEWAY_STA).starkNet() == starkNet);
        require(TeleportFeeLike(LINEAR_FEE).fee() == WAD / 10000);
        require(TeleportFeeLike(LINEAR_FEE).ttl() == 30 minutes); // finalization time on Goerli

        uint256 line = 100_000;
        DssExecLib.increaseIlkDebtCeiling(ILK, line, true);

        TeleportJoinLike(join).file("fees", DOMAIN_STA, LINEAR_FEE);
        TeleportJoinLike(join).file("line", DOMAIN_STA, line * WAD);

        TeleportRouterLike(router).file("gateway", DOMAIN_STA, TELEPORT_GATEWAY_STA);

        EscrowLike(escrow).approve(dai, TELEPORT_GATEWAY_STA, type(uint256).max);

        DssExecLib.setChangelogAddress("STARKNET_TELEPORT_BRIDGE", TELEPORT_GATEWAY_STA);
        DssExecLib.setChangelogAddress("STARKNET_TELEPORT_FEE", LINEAR_FEE);

        // TODO: set changelog version
        DssExecLib.setChangelogVersion("1.14.0");

    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
