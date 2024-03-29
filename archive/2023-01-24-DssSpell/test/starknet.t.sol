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

pragma solidity 0.8.16;

import "../DssSpell.t.base.sol";

contract ConfigStarknet {
    StarknetValues starknetValues;

    struct StarknetValues {
        address core_implementation;
        uint256 dai_bridge_isOpen;
        uint256 dai_bridge_ceiling;
        uint256 dai_bridge_maxDeposit;
        uint256 l2_dai_bridge;
        uint256 l2_gov_relay;
    }

    function setValues() public {
        uint256 WAD = 10 ** 18;
        starknetValues = StarknetValues({
            core_implementation:       0x60C5fA1763cC9CB9c7c25458C6cDDFbc8F125256,
            dai_bridge_isOpen:         1,                     // 1 open, 0 closed
            dai_bridge_ceiling:        1_000_000 * WAD,       // wei
            dai_bridge_maxDeposit:     type(uint256).max,     // wei
            l2_dai_bridge:             0x057b7fe4e59d295de5e7955c373023514ede5b972e872e9aa5dcdf563f5cfacb,
            l2_gov_relay:              0x00275e3f018f7884f449a1fb418b6b1de77e01c74a9fefaed1599cb22322ff74
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
    function l2DaiBridge() external returns (uint256);
}

interface StarknetGovRelayLike {
    function wards(address) external returns (uint256);
    function starkNet() external returns (address);
    function l2GovernanceRelay() external returns (uint256);
}

interface StarknetCoreLike {
    function implementation() external returns (address);
    function isNotFinalized() external returns (bool);
}

interface DaiLike {
    function allowance(address, address) external view returns (uint256);
}

contract StarknetTests is DssSpellTestBase, ConfigStarknet {

    function testStarknet() public {
        setValues();

        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        _checkStarknetEscrowMom();
        _checkStarknetEscrow();
        _checkStarknetDaiBridge();
        _checkStarknetGovRelay();
        _checkStarknetCore();
    }

    function _checkStarknetEscrowMom() internal {
        StarknetEscrowMomLike escrowMom = StarknetEscrowMomLike(addr.addr("STARKNET_ESCROW_MOM"));

        assertEq(escrowMom.owner(),     addr.addr("MCD_PAUSE_PROXY"), "StarknetTest/pause-proxy-not-owner-on-escrow-mom");
        assertEq(escrowMom.authority(), addr.addr("MCD_ADM"),         "StarknetTest/chief-not-authority-on-escrow-mom");
        assertEq(escrowMom.escrow(),    addr.addr("STARKNET_ESCROW"), "StarknetTest/unexpected-escrow-on-escrow-mom");
        assertEq(escrowMom.token(),     addr.addr("MCD_DAI"),         "StarknetTest/unexpected-dai-on-escrow-mom");
    }

    function _checkStarknetEscrow() internal {
        StarknetEscrowLike escrow = StarknetEscrowLike(addr.addr("STARKNET_ESCROW"));

        assertEq(escrow.wards(addr.addr("MCD_PAUSE_PROXY")),     1, "StarknetTest/pause-proxy-not-ward-on-escrow");
        assertEq(escrow.wards(addr.addr("MCD_ESM")),             1, "StarknetTest/esm-not-ward-on-escrow");
        assertEq(escrow.wards(addr.addr("STARKNET_ESCROW_MOM")), 1, "StarknetTest/escrow-mom-not-ward-on-escrow");

        DaiLike dai = DaiLike(addr.addr("MCD_DAI"));

        assertEq(dai.allowance(addr.addr("STARKNET_ESCROW"), addr.addr("STARKNET_DAI_BRIDGE")), type(uint256).max, "StarknetTest/unexpected-escrow-allowance");
    }

    function _checkStarknetDaiBridge() internal {
        StarknetDaiBridgeLike daiBridge = StarknetDaiBridgeLike(addr.addr("STARKNET_DAI_BRIDGE"));

        assertEq(daiBridge.isOpen(),     starknetValues.dai_bridge_isOpen,     "StarknetTestError/dai-bridge-isOpen-unexpected");
        assertEq(daiBridge.ceiling(),    starknetValues.dai_bridge_ceiling,    "StarknetTestError/dai-bridge-ceiling-unexpected");
        assertEq(daiBridge.maxDeposit(), starknetValues.dai_bridge_maxDeposit, "StarknetTestError/dai-bridge-maxDeposit-unexpected");

        assertEq(daiBridge.dai(),      addr.addr("MCD_DAI"),         "StarknetTest/dai-bridge-dai");
        assertEq(daiBridge.starkNet(), addr.addr("STARKNET_CORE"),   "StarknetTest/dai-bridge-core");
        assertEq(daiBridge.escrow(),   addr.addr("STARKNET_ESCROW"), "StarknetTest/dai-bridge-escrow");

        assertEq(daiBridge.wards(addr.addr("MCD_PAUSE_PROXY")), 1, "StarknetTest/pause-proxy-not-ward-on-dai-bridge");
        assertEq(daiBridge.wards(addr.addr("MCD_ESM")),         1, "StarknetTest/esm-not-ward-on-dai-bridge");

        assertEq(daiBridge.l2DaiBridge(), starknetValues.l2_dai_bridge, "StarknetTest/wrong-l2-dai-bridge-on-dai-bridge");
    }

    function _checkStarknetGovRelay() internal {
        StarknetGovRelayLike govRelay = StarknetGovRelayLike(addr.addr("STARKNET_GOV_RELAY"));

        assertEq(govRelay.wards(addr.addr("MCD_PAUSE_PROXY")), 1, "StarknetTest/pause-proxy-not-ward-on-gov-relay");
        assertEq(govRelay.wards(addr.addr("MCD_ESM")),         1, "StarknetTest/esm-not-ward-on-gov-relay");

        assertEq(govRelay.starkNet(), addr.addr("STARKNET_CORE"), "StarknetTest/unexpected-starknet-core-on-gov-relay");
        assertEq(govRelay.l2GovernanceRelay(), starknetValues.l2_gov_relay, "StarknetTest/unexpected-l2-gov-relay-on-gov-relay");
    }

    function _checkStarknetCore() internal {
        StarknetCoreLike core = StarknetCoreLike(addr.addr("STARKNET_CORE"));

        // Starknet Core is currently out of scope.
        // It is updating frequently and the implementation is not ready to be
        //    brought into our simulation tests yet.
        //assertEq(core.implementation(), starknetValues.core_implementation, "StarknetTest/core-implementation");

        assertTrue(core.isNotFinalized());
    }
}
