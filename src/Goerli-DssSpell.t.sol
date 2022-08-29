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
pragma experimental ABIEncoderV2;

import "./Goerli-DssSpell.t.base.sol";

interface CureLike {
    function tCount() external view returns (uint256);
    function srcs(uint256) external view returns (address);
}

contract DssSpellTest is GoerliDssSpellTestBase {
    function test_OSM_auth() private {  // make public to use
        // address ORACLE_WALLET01 = 0x4D6fbF888c374D7964D56144dE0C0cFBd49750D3;

        // validate the spell does what we told it to
        //bytes32[] memory ilks = reg.list();

        //for(uint256 i = 0; i < ilks.length; i++) {
        //    uint256 class = reg.class(ilks[i]);
        //    if (class != 1) { continue; }

        //    address pip = reg.pip(ilks[i]);
        //    // skip USDC, TUSD, PAXUSD, GUSD
        //    if (pip == 0x838212865E2c2f4F7226fCc0A3EFc3EB139eC661 ||
        //        pip == 0x0ce19eA2C568890e63083652f205554C927a0caa ||
        //        pip == 0xdF8474337c9D3f66C0b71d31C7D3596E4F517457 ||
        //        pip == 0x57A00620Ba1f5f81F20565ce72df4Ad695B389d7) {
        //        continue;
        //    }

        //    assertEq(OsmAbstract(pip).wards(ORACLE_WALLET01), 0);
        //}

        //vote(address(spell));
        //scheduleWaitAndCast(address(spell));
        //assertTrue(spell.done());

        //for(uint256 i = 0; i < ilks.length; i++) {
        //    uint256 class = reg.class(ilks[i]);
        //    if (class != 1) { continue; }

        //    address pip = reg.pip(ilks[i]);
        //    // skip USDC, TUSD, PAXUSD, GUSD
        //    if (pip == 0x838212865E2c2f4F7226fCc0A3EFc3EB139eC661 ||
        //        pip == 0x0ce19eA2C568890e63083652f205554C927a0caa ||
        //        pip == 0xdF8474337c9D3f66C0b71d31C7D3596E4F517457 ||
        //        pip == 0x57A00620Ba1f5f81F20565ce72df4Ad695B389d7) {
        //        continue;
        //    }

        //    assertEq(OsmAbstract(pip).wards(ORACLE_WALLET01), 1);
        //}
    }

    function test_oracle_list() private {  // make public to use
        // address ORACLE_WALLET01 = 0x4D6fbF888c374D7964D56144dE0C0cFBd49750D3;

        //assertEq(OsmAbstract(0xF15993A5C5BE496b8e1c9657Fd2233b579Cd3Bc6).wards(ORACLE_WALLET01), 0);

        //vote(address(spell));
        //scheduleWaitAndCast(address(spell));
        //assertTrue(spell.done());

        //assertEq(OsmAbstract(0xF15993A5C5BE496b8e1c9657Fd2233b579Cd3Bc6).wards(ORACLE_WALLET01), 1);
    }

    function testSpellIsCast_GENERAL() public {
        string memory description = new DssSpell().description();
        assertTrue(bytes(description).length > 0, "TestError/spell-description-length");
        // DS-Test can't handle strings directly, so cast to a bytes32.
        assertEq(stringToBytes32(spell.description()),
                stringToBytes32(description), "TestError/spell-description");

        if(address(spell) != address(spellValues.deployed_spell)) {
            assertEq(spell.expiration(), block.timestamp + spellValues.expiration_threshold, "TestError/spell-expiration");
        } else {
            assertEq(spell.expiration(), spellValues.deployed_spell_created + spellValues.expiration_threshold, "TestError/spell-expiration");

            // If the spell is deployed compare the on-chain bytecode size with the generated bytecode size.
            // extcodehash doesn't match, potentially because it's address-specific, avenue for further research.
            address depl_spell = spellValues.deployed_spell;
            address code_spell = address(new DssSpell());
            assertEq(getExtcodesize(depl_spell), getExtcodesize(code_spell), "TestError/spell-codesize");
        }

        assertTrue(spell.officeHours() == spellValues.office_hours_enabled, "TestError/spell-office-hours");

        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done(), "TestError/spell-not-done");

        checkSystemValues(afterSpell);

        checkCollateralValues(afterSpell);
    }

    function testRemoveChainlogValues() private { // make public to use
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // try chainLog.getAddress("XXX") {
        //     assertTrue(false);
        // } catch Error(string memory errmsg) {
        //     assertTrue(cmpStr(errmsg, "dss-chain-log/invalid-key"));
        // } catch {
        //     assertTrue(false);
        // }

    }

    function testCollateralIntegrations() private {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Insert new collateral tests here
        // checkIlkIntegration(
        //     "TOKEN-X",
        //     GemJoinAbstract(addr.addr("MCD_JOIN_TOKEN_X")),
        //     ClipAbstract(addr.addr("MCD_CLIP_TOKEN_X")),
        //     addr.addr("PIP_TOKEN"),
        //     true,
        //     true,
        //     false
        // );


    }

    function testLerpSurplusBuffer() private { // make public to use
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Insert new SB lerp tests here

        LerpAbstract lerp = LerpAbstract(lerpFactory.lerps("NAME"));

        uint256 duration = 210 days;
        hevm.warp(block.timestamp + duration / 2);
        assertEq(vow.hump(), 60 * MILLION * RAD);
        lerp.tick();
        assertEq(vow.hump(), 75 * MILLION * RAD);
        hevm.warp(block.timestamp + duration / 2);
        lerp.tick();
        assertEq(vow.hump(), 90 * MILLION * RAD);
        assertTrue(lerp.done());
    }

    function testNewChainlogValues() public { // make public to use
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Insert new chainlog values tests here
        checkChainlogKey("MCD_JOIN_TELEPORT_FW_A");
        checkChainlogKey("MCD_ORACLE_AUTH_TELEPORT_FW_A");
        checkChainlogKey("MCD_ROUTER_TELEPORT_FW_A");
        checkChainlogKey("OPTIMISM_TELEPORT_BRIDGE");
        checkChainlogKey("OPTIMISM_TELEPORT_FEE");
        checkChainlogKey("OPTIMISM_DAI_BRIDGE");
        checkChainlogKey("OPTIMISM_ESCROW");
        checkChainlogKey("OPTIMISM_GOV_RELAY");
        checkChainlogKey("ARBITRUM_TELEPORT_BRIDGE");
        checkChainlogKey("ARBITRUM_TELEPORT_FEE");
        checkChainlogKey("ARBITRUM_DAI_BRIDGE");
        checkChainlogKey("ARBITRUM_ESCROW");
        checkChainlogKey("ARBITRUM_GOV_RELAY");
        checkChainlogVersion("1.14.0");
    }

    function testNewIlkRegistryValues() public { // make public to use
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Insert new ilk registry values tests here
        assertEq(reg.pos("TELEPORT-FW-A"), 52);
        assertEq(reg.join("TELEPORT-FW-A"), addr.addr("MCD_JOIN_TELEPORT_FW_A"));
        assertEq(reg.gem("TELEPORT-FW-A"), addr.addr("MCD_DAI"));
        assertEq(reg.dec("TELEPORT-FW-A"), GemAbstract(addr.addr("MCD_DAI")).decimals());
        assertEq(reg.class("TELEPORT-FW-A"), 4);
        assertEq(reg.pip("TELEPORT-FW-A"), address(0));
        assertEq(reg.xlip("TELEPORT-FW-A"), address(0));
        assertEq(reg.name("TELEPORT-FW-A"), "Dai Stablecoin");
        assertEq(reg.symbol("TELEPORT-FW-A"), "DAI");
    }

    function testFailWrongDay() public {
        require(spell.officeHours() == spellValues.office_hours_enabled);
        if (spell.officeHours()) {
            vote(address(spell));
            scheduleWaitAndCastFailDay();
        } else {
            revert("Office Hours Disabled");
        }
    }

    function testFailTooEarly() public {
        require(spell.officeHours() == spellValues.office_hours_enabled);
        if (spell.officeHours()) {
            vote(address(spell));
            scheduleWaitAndCastFailEarly();
        } else {
            revert("Office Hours Disabled");
        }
    }

    function testFailTooLate() public {
        require(spell.officeHours() == spellValues.office_hours_enabled);
        if (spell.officeHours()) {
            vote(address(spell));
            scheduleWaitAndCastFailLate();
        } else {
            revert("Office Hours Disabled");
        }
    }

    function testOnTime() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
    }

    function testCastCost() public {
        vote(address(spell));
        spell.schedule();

        castPreviousSpell();
        hevm.warp(spell.nextCastTime());
        uint256 startGas = gasleft();
        spell.cast();
        uint256 endGas = gasleft();
        uint256 totalGas = startGas - endGas;

        assertTrue(spell.done());
        // Fail if cast is too expensive
        assertTrue(totalGas <= 10 * MILLION);
    }

    // The specific date doesn't matter that much since function is checking for difference between warps
    function test_nextCastTime() public {
        hevm.warp(1606161600); // Nov 23, 20 UTC (could be cast Nov 26)

        vote(address(spell));
        spell.schedule();

        uint256 monday_1400_UTC = 1606744800; // Nov 30, 2020
        uint256 monday_2100_UTC = 1606770000; // Nov 30, 2020

        // Day tests
        hevm.warp(monday_1400_UTC);                                    // Monday,   14:00 UTC
        assertEq(spell.nextCastTime(), monday_1400_UTC);               // Monday,   14:00 UTC

        if (spell.officeHours()) {
            hevm.warp(monday_1400_UTC - 1 days);                       // Sunday,   14:00 UTC
            assertEq(spell.nextCastTime(), monday_1400_UTC);           // Monday,   14:00 UTC

            hevm.warp(monday_1400_UTC - 2 days);                       // Saturday, 14:00 UTC
            assertEq(spell.nextCastTime(), monday_1400_UTC);           // Monday,   14:00 UTC

            hevm.warp(monday_1400_UTC - 3 days);                       // Friday,   14:00 UTC
            assertEq(spell.nextCastTime(), monday_1400_UTC - 3 days);  // Able to cast

            hevm.warp(monday_2100_UTC);                                // Monday,   21:00 UTC
            assertEq(spell.nextCastTime(), monday_1400_UTC + 1 days);  // Tuesday,  14:00 UTC

            hevm.warp(monday_2100_UTC - 1 days);                       // Sunday,   21:00 UTC
            assertEq(spell.nextCastTime(), monday_1400_UTC);           // Monday,   14:00 UTC

            hevm.warp(monday_2100_UTC - 2 days);                       // Saturday, 21:00 UTC
            assertEq(spell.nextCastTime(), monday_1400_UTC);           // Monday,   14:00 UTC

            hevm.warp(monday_2100_UTC - 3 days);                       // Friday,   21:00 UTC
            assertEq(spell.nextCastTime(), monday_1400_UTC);           // Monday,   14:00 UTC

            // Time tests
            uint256 castTime;

            for(uint256 i = 0; i < 5; i++) {
                castTime = monday_1400_UTC + i * 1 days; // Next day at 14:00 UTC
                hevm.warp(castTime - 1 seconds); // 13:59:59 UTC
                assertEq(spell.nextCastTime(), castTime);

                hevm.warp(castTime + 7 hours + 1 seconds); // 21:00:01 UTC
                if (i < 4) {
                    assertEq(spell.nextCastTime(), monday_1400_UTC + (i + 1) * 1 days); // Next day at 14:00 UTC
                } else {
                    assertEq(spell.nextCastTime(), monday_1400_UTC + 7 days); // Next monday at 14:00 UTC (friday case)
                }
            }
        }
    }

    function testFail_notScheduled() public view {
        spell.nextCastTime();
    }

    function test_use_eta() public {
        hevm.warp(1606161600); // Nov 23, 20 UTC (could be cast Nov 26)

        vote(address(spell));
        spell.schedule();

        uint256 castTime = spell.nextCastTime();
        assertEq(castTime, spell.eta());
    }

    function test_Medianizers() private { // make public to use
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Track Median authorizations here
        address SET_TOKEN    = address(0);
        address TOKENUSD_MED = OsmAbstract(addr.addr("PIP_TOKEN")).src();
        assertEq(MedianAbstract(TOKENUSD_MED).bud(SET_TOKEN), 1);
    }

    function test_auth() public {
        checkAuth(false);
    }

    function test_auth_in_sources() public {
        checkAuth(true);
    }

    // Verifies that the bytecode of the action of the spell used for testing
    // matches what we'd expect.
    //
    // Not a complete replacement for Etherscan verification, unfortunately.
    // This is because the DssSpell bytecode is non-deterministic because it
    // deploys the action in its constructor and incorporates the action
    // address as an immutable variable--but the action address depends on the
    // address of the DssSpell which depends on the address+nonce of the
    // deploying address. If we had a way to simulate a contract creation by
    // an arbitrary address+nonce, we could verify the bytecode of the DssSpell
    // instead.
    //
    // Vacuous until the deployed_spell value is non-zero.
    function test_bytecode_matches() public {
        address expectedAction = (new DssSpell()).action();
        address actualAction   = spell.action();
        uint256 expectedBytecodeSize;
        uint256 actualBytecodeSize;
        assembly {
            expectedBytecodeSize := extcodesize(expectedAction)
            actualBytecodeSize   := extcodesize(actualAction)
        }

        uint256 metadataLength = getBytecodeMetadataLength(expectedAction);
        assertTrue(metadataLength <= expectedBytecodeSize);
        expectedBytecodeSize -= metadataLength;

        metadataLength = getBytecodeMetadataLength(actualAction);
        assertTrue(metadataLength <= actualBytecodeSize);
        actualBytecodeSize -= metadataLength;

        assertEq(actualBytecodeSize, expectedBytecodeSize);
        uint256 size = actualBytecodeSize;
        uint256 expectedHash;
        uint256 actualHash;
        assembly {
            let ptr := mload(0x40)

            extcodecopy(expectedAction, ptr, 0, size)
            expectedHash := keccak256(ptr, size)

            extcodecopy(actualAction, ptr, 0, size)
            actualHash := keccak256(ptr, size)
        }
        assertEq(expectedHash, actualHash);
    }

    // Validate addresses in test harness match chainlog
    function test_chainlog_values() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        for(uint256 i = 0; i < chainLog.count(); i++) {
            (bytes32 _key, address _val) = chainLog.get(i);
            assertEq(_val, addr.addr(_key), concat("TestError/chainlog-addr-mismatch-", _key));
        }
    }

    // Ensure version is updated if chainlog changes
    function test_chainlog_version_bump() public {

        uint256                   _count = chainLog.count();
        string    memory        _version = chainLog.version();
        address[] memory _chainlog_addrs = new address[](_count);

        for(uint256 i = 0; i < _count; i++) {
            (, address _val) = chainLog.get(i);
            _chainlog_addrs[i] = _val;
        }

        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        if (keccak256(abi.encodePacked(_version)) == keccak256(abi.encodePacked(chainLog.version()))) {
            // Fail if the version is not updated and the chainlog count has changed
            if (_count != chainLog.count()) {
                emit log_named_string("Error", concat("TestError/chainlog-version-not-updated-count-change-", _version));
                fail();
                return;
            }
            // We are skipping this part of the test because we need to update the chainlog without bumping the version.

            // // Fail if the chainlog is the same size but local keys don't match the chainlog.
            // for(uint256 i = 0; i < _count; i++) {
            //     (, address _val) = chainLog.get(i);
            //     if (_chainlog_addrs[i] != _val) {
            //         emit log_named_string("Error", concat("TestError/chainlog-version-not-updated-address-change-", _version));
            //         fail();
            //         return;
            //     }
            // }
        }
    }

    function tryVest(address vest, uint256 id) internal returns (bool ok) {
        (ok,) = vest.call(abi.encodeWithSignature("vest(uint256)", id));
    }

    function testVestDAI() private { // make public to use
        VestAbstract vest = VestAbstract(addr.addr("MCD_VEST_DAI"));

        assertEq(vest.ids(), 0);

        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        assertEq(vest.ids(), 1);

        assertEq(vest.cap(), 1 * MILLION * WAD / 30 days);

        assertEq(vest.usr(1), address(pauseProxy));
        assertEq(vest.bgn(1), block.timestamp - 1 days);
        assertEq(vest.clf(1), block.timestamp - 1 days);
        assertEq(vest.fin(1), block.timestamp);
        assertEq(vest.mgr(1), address(0));
        assertEq(vest.res(1), 0);
        assertEq(vest.tot(1), WAD);
        assertEq(vest.rxd(1), 0);

        uint256 prevBalance = dai.balanceOf(address(pauseProxy));
        assertTrue(tryVest(address(vest), 1));
        assertEq(dai.balanceOf(address(pauseProxy)), prevBalance + WAD);

        assertEq(vest.rxd(1), WAD);
    }

    function testRWA009_SPELL_DRAW() public {
        address rwaUrn009       = addr.addr("RWA009_A_URN");
        address rwaUrn009Output = addr.addr("RWA009_A_OUTPUT_CONDUIT"); // for goerli, we use the pause proxy

        (uint256 pink, uint256 part) = vat.urns("RWA009-A", address(rwaUrn009));
        uint256 prevBalance = dai.balanceOf(address(rwaUrn009Output));

        assertEq(pink, 1 * WAD, "RWA009/bad-ink-before-spell");

        uint256 drawAmount = 25_000_000 * WAD;

        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Check if spell draw 25mm DAI to Output Conduit (Pause Proxy)
        assertEq(dai.balanceOf(address(rwaUrn009Output)), prevBalance + drawAmount, "RWA009/dai-drawn-was-not-send-to-the-recipient");

        (uint256 ink, uint256 art) = vat.urns("RWA009-A", address(rwaUrn009));
        assertEq(art, part + drawAmount, "RWA009/bad-art-after-spell"); // DAI drawn == art as rate should always be 1 RAY
        assertEq(ink, pink,              "RWA009/bad-ink-after-spell"); // Whole unit of collateral is locked. should not change
    }

    // NOTE: Only executable by forge
    function testTeleportFW() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        TeleportJoinLike join = TeleportJoinLike(addr.addr("MCD_JOIN_TELEPORT_FW_A"));
        TeleportOracleAuthLike oracleAuth = TeleportOracleAuthLike(addr.addr("MCD_ORACLE_AUTH_TELEPORT_FW_A"));
        TeleportRouterLike router = TeleportRouterLike(addr.addr("MCD_ROUTER_TELEPORT_FW_A"));

        bytes32 ilk = "TELEPORT-FW-A";
        bytes23 domain = "ETH-GOER-A";

        // Sanity checks
        assertEq(vat.wards(address(join)), 1);

        assertEq(join.wards(address(oracleAuth)), 1);
        assertEq(join.wards(address(router)), 1);
        assertEq(join.vow(), address(vow));
        assertEq(join.daiJoin(), address(daiJoin));
        assertEq(join.vat(), address(vat));
        assertEq(join.ilk(), ilk);
        assertEq(join.domain(), domain);

        assertEq(oracleAuth.signers(0xC4756A9DaE297A046556261Fa3CD922DFC32Db78), 1);
        assertEq(oracleAuth.signers(0x23ce419DcE1De6b3647Ca2484A25F595132DfBd2), 1);
        assertEq(oracleAuth.signers(0x774D5AA0EeE4897a9a6e65Cbed845C13Ffbc6d16), 1);
        assertEq(oracleAuth.signers(0xb41E8d40b7aC4Eb34064E079C8Eca9d7570EBa1d), 1);
        assertEq(oracleAuth.signers(0x0E0cDcbbE170f6d81f87b45c2227526B6779A083), 1);
        assertEq(oracleAuth.signers(0x73093A55d5703C7A81D7381F7F24FCf432c64652), 1);
        assertEq(oracleAuth.signers(0x2a2b83700c990FDFEFD22968fc7C4A4B80783E60), 1);
        assertEq(oracleAuth.signers(0x1BC7410DD4D18bf8f613F4B6a646FA3953D3A0f2), 1);
        assertEq(oracleAuth.signers(0xE5D5b00cc04596461a5527616b4F88B754879aE8), 1);
        assertEq(oracleAuth.signers(0xA5E6053Fe351883036d13C2219b68102AbdFcBB6), 1);
        assertEq(oracleAuth.signers(0x59524b843866b9686c520fB3d3613A73fe303d30), 1);
        assertEq(oracleAuth.signers(0x794D810a3d524B9E25227bFA22E69CaaC8544EF2), 1);
        assertEq(oracleAuth.signers(0xE85963ACc9A361E13306c6395186aa950f750883), 1);
        assertEq(oracleAuth.signers(0xc65EF2D17B05ADbd8e4968bCB01b325ab799aBd8), 1);
        
        assertEq(oracleAuth.teleportJoin(), address(join));
        assertEq(oracleAuth.threshold(), 1);

        assertEq(router.gateways(domain), address(join));
        assertEq(router.domains(address(join)), domain);
        assertEq(router.dai(), address(dai));
        assertEq(router.numDomains(), 3);

        assertEq(CureLike(cure).srcs(CureLike(cure).tCount() - 1), address(join));

        checkTeleportFWIntegration(
            "OPT-GOER-A",
            domain,
            1_000_000 * WAD,
            addr.addr("OPTIMISM_TELEPORT_BRIDGE"),
            addr.addr("OPTIMISM_TELEPORT_FEE"),
            addr.addr("OPTIMISM_ESCROW"),
            100 * WAD,
            WAD / 10000,   // 1bps
            8 days
        );

        checkTeleportFWIntegration(
            "ARB-GOER-A",
            domain,
            1_000_000 * WAD,
            addr.addr("ARBITRUM_TELEPORT_BRIDGE"),
            addr.addr("ARBITRUM_TELEPORT_FEE"),
            addr.addr("ARBITRUM_ESCROW"),
            100 * WAD,
            WAD / 10000,   // 1bps
            8 days
        );
    }
}
