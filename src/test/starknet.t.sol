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
pragma experimental ABIEncoderV2;

import "../Goerli-DssSpell.t.base.sol";


contract ConfigStarknet {

    StarknetValues starknetValues;

    struct StarknetValues {
        address core_implementation;
        uint256 l2_teleport_gateway;
        uint256 dai_bridge_isOpen;
        uint256 dai_bridge_ceiling;
        uint256 dai_bridge_maxDeposit;
    }

    function setValues() public {
        starknetValues = StarknetValues({
            core_implementation:       0x60C5fA1763cC9CB9c7c25458C6cDDFbc8F125256,
            l2_teleport_gateway:       0x042b46146f0a377e0a028ed44bc1c0567196b8b96f3c7ab469e593ca497e2a83,
            dai_bridge_isOpen:         1,        // 1 open, 0 closed
            dai_bridge_ceiling:        200_000,  // Whole Dai Units
            dai_bridge_maxDeposit:     1000      // Whole Dai Units
        });
    }
}

interface StarknetEscrowMomLike {
    function owner() external returns (address);
    function authority() external returns (address);
    function escrow() external returns (address);
    function token() external returns (address);
}

interface StarknetEscrowLike {
    function wards(address) external returns(uint256);
}

interface StarknetDaiBridgeLike {
    function wards(address) external returns(uint256);
    function isOpen() external returns (uint256);
    function ceiling() external returns (uint256);
    function maxDeposit() external returns (uint256);
    function dai() external returns (address);
    function starkNet() external returns (address);
    function escrow() external returns (address);
}

interface StarknetGovRelayLike {
    function wards(address) external returns (uint256);
    function starkNet() external returns (address);
}

interface StarknetCoreLike {
    function implementation() external returns (address);
    function isNotFinalized() external returns (bool);
}

interface DaiLike {
    function allowance(address, address) external view returns (uint256);
}

interface StarknetTeleportBridgeLike {
    function starkNet() external view returns (address);
    function dai() external view returns (address);
    function l2DaiTeleportGateway() external view returns (uint256);
    function escrow() external view returns (address);
    function teleportRouter() external view returns (address);
}


contract StarknetTests is GoerliDssSpellTestBase, ConfigStarknet {

    function testStarknet() public {
        setValues();

        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        checkStarknetEscrowMom();
        checkStarknetEscrow();
        checkStarknetDaiBridge();
        checkStarknetGovRelay();
        checkStarknetCore();
        checkTeleportFW();
    }

    function checkStarknetEscrowMom() public {
        StarknetEscrowMomLike escrowMom = StarknetEscrowMomLike(addr.addr("STARKNET_ESCROW_MOM"));

        assertEq(escrowMom.owner(),     addr.addr("MCD_PAUSE_PROXY"), "StarknetTest/pause-proxy-not-owner-on-escrow-mom");
        assertEq(escrowMom.authority(), addr.addr("MCD_ADM"),         "StarknetTest/chief-not-authority-on-escrow-mom");
        assertEq(escrowMom.escrow(),    addr.addr("STARKNET_ESCROW"), "StarknetTest/unexpected-escrow-on-escrow-mom");
        assertEq(escrowMom.token(),     addr.addr("MCD_DAI"),         "StarknetTest/unexpected-dai-on-escrow-mom");
    }

    function checkStarknetEscrow() public {
        StarknetEscrowLike escrow = StarknetEscrowLike(addr.addr("STARKNET_ESCROW"));

        assertEq(escrow.wards(addr.addr("MCD_PAUSE_PROXY")),     1, "StarknetTest/pause-proxy-not-ward-on-escrow");
        assertEq(escrow.wards(addr.addr("MCD_ESM")),             1, "StarknetTest/esm-not-ward-on-escrow");
        assertEq(escrow.wards(addr.addr("STARKNET_ESCROW_MOM")), 1, "StarknetTest/escrow-mom-not-ward-on-escrow");

        DaiLike dai = DaiLike(addr.addr("MCD_DAI"));

        assertEq(dai.allowance(addr.addr("STARKNET_ESCROW"), addr.addr("STARKNET_DAI_BRIDGE")), uint256(-1), "StarknetTest/unexpected-escrow-allowance");
    }

    function checkStarknetDaiBridge() public {
        StarknetDaiBridgeLike daiBridge = StarknetDaiBridgeLike(addr.addr("STARKNET_DAI_BRIDGE"));

        assertEq(daiBridge.isOpen(),     starknetValues.dai_bridge_isOpen,           "StarknetTestError/dai-bridge-isOpen-unexpected");
        assertEq(daiBridge.ceiling(),    starknetValues.dai_bridge_ceiling * WAD,    "StarknetTestError/dai-bridge-ceiling-unexpected");
        assertEq(daiBridge.maxDeposit(), starknetValues.dai_bridge_maxDeposit * WAD, "StarknetTestError/dai-bridge-maxDeposit-unexpected");

        assertEq(daiBridge.dai(),      addr.addr("MCD_DAI"),         "StarknetTest/dai-bridge-dai");
        assertEq(daiBridge.starkNet(), addr.addr("STARKNET_CORE"),   "StarknetTest/dai-bridge-core");
        assertEq(daiBridge.escrow(),   addr.addr("STARKNET_ESCROW"), "StarknetTest/dai-bridge-escrow");

        assertEq(daiBridge.wards(addr.addr("MCD_PAUSE_PROXY")), 1, "StarknetTest/pause-proxy-not-ward-on-dai-bridge");
        assertEq(daiBridge.wards(addr.addr("MCD_ESM")),         1, "StarknetTest/esm-not-ward-on-dai-bridge");
    }

    function checkStarknetGovRelay() public {
        StarknetGovRelayLike govRelay = StarknetGovRelayLike(addr.addr("STARKNET_GOV_RELAY"));

        assertEq(govRelay.wards(addr.addr("MCD_PAUSE_PROXY")), 1, "StarknetTest/pause-proxy-not-ward-on-gov-relay");
        assertEq(govRelay.wards(addr.addr("MCD_ESM")),         1, "StarknetTest/esm-not-ward-on-gov-relay");

        assertEq(govRelay.starkNet(), addr.addr("STARKNET_CORE"), "StarknetTest/unexpected-starknet-core-on-gov-relay");
    }

    function checkStarknetCore() public {
        StarknetCoreLike core = StarknetCoreLike(addr.addr("STARKNET_CORE"));

        // Starknet Core is currently out of scope.
        // It is updating frequently and the implementation is not ready to be
        //    brought into our simulation tests yet.
        //assertEq(core.implementation(), starknetValues.core_implementation, "StarknetTest/core-implementation");

        assertTrue(core.isNotFinalized());
    }

    function checkTeleportFW() public {

        address router = addr.addr("MCD_ROUTER_TELEPORT_FW_A");
        StarknetTeleportBridgeLike bridge = StarknetTeleportBridgeLike(addr.addr("STARKNET_TELEPORT_BRIDGE"));
        address escrow = addr.addr("STARKNET_ESCROW");

        bytes32 ilk = "TELEPORT-FW-A";
        bytes23 domain = "ETH-GOER-A";

        emit log_address(address(spell));
        emit log_address(addr.addr("STARKNET_TELEPORT_BRIDGE"));
        emit log_address(addr.addr("STARKNET_TELEPORT_FEE"));
        emit log_uint(bridge.l2DaiTeleportGateway());
        emit log_uint(starknetValues.l2_teleport_gateway);

        assertEq(bridge.escrow(), escrow);
        assertEq(bridge.teleportRouter(), address(router));
        assertEq(bridge.dai(), address(dai));
        assertEq(bridge.l2DaiTeleportGateway(), starknetValues.l2_teleport_gateway);

        checkTeleportFWIntegrationInternals(
            "STA-GOER-A",
            domain,
            100_000 * WAD,
            address(bridge),
            addr.addr("STARKNET_TELEPORT_FEE"),
            escrow,
            100 * WAD,
            WAD / 10000,   // 1bps
            30 minutes
        );

    }

    function checkTeleportFWIntegrationInternals(
        bytes32 sourceDomain,
        bytes32 targetDomain,
        uint256 line,
        address gateway,
        address fee,
        address escrow,
        uint256 toMint,
        uint256 expectedFee,
        uint256 expectedTtl
    ) internal {
        TeleportJoinLike join = TeleportJoinLike(addr.addr("MCD_JOIN_TELEPORT_FW_A"));
        TeleportRouterLike router = TeleportRouterLike(addr.addr("MCD_ROUTER_TELEPORT_FW_A"));

        // Sanity checks
        assertEq(join.line(sourceDomain), line);
        assertEq(join.fees(sourceDomain), address(fee));
        assertEq(dai.allowance(escrow, gateway), type(uint256).max);
        assertEq(dai.allowance(gateway, address(router)), type(uint256).max);
        assertEq(TeleportFeeLike(fee).fee(), expectedFee);
        assertEq(TeleportFeeLike(fee).ttl(), expectedTtl);
        assertEq(router.gateways(sourceDomain), gateway);
        assertEq(router.domains(gateway), sourceDomain);

        {
            // NOTE: We are calling the router directly because the bridge code is minimal and unique to each domain
            // This tests the slow path via the router
            hevm.startPrank(gateway);
            router.requestMint(TeleportGUID({
                sourceDomain: sourceDomain,
                targetDomain: targetDomain,
                receiver: bytes32(uint256(uint160(address(this)))),
                operator: bytes32(0),
                amount: uint128(toMint),
                nonce: 0,
                timestamp: uint48(block.timestamp - TeleportFeeLike(fee).ttl())
            }), 0, 0);
            hevm.stopPrank();
            assertEq(dai.balanceOf(address(this)), toMint);
            assertEq(join.debt(sourceDomain), int256(toMint));
        }

        // Check oracle auth mint -- add custom signatures to test
        uint256 _fee = toMint * expectedFee / WAD;
        {
            uint256 prevDai = vat.dai(address(vow));
            oracleAuthRequestMint(sourceDomain, targetDomain, toMint, expectedFee);
            assertEq(dai.balanceOf(address(this)), toMint * 2 - _fee);
            assertEq(join.debt(sourceDomain), int256(toMint * 2));
            assertEq(vat.dai(address(vow)) - prevDai, _fee * RAY);
        }

        // Check settle
        dai.transfer(gateway, toMint * 2 - _fee);
        hevm.startPrank(gateway);
        router.settle(targetDomain, toMint * 2 - _fee);
        hevm.stopPrank();
        assertEq(dai.balanceOf(gateway), 0);
        assertEq(join.debt(sourceDomain), int256(_fee));
    }
}
