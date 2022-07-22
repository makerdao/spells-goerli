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

import "./Goerli-DssSpell.t.base.sol";

interface RwaLiquidationLike {
    function ilks(bytes32) external returns (string memory, address, uint48 toc, uint48 tau);
    function bump(bytes32 ilk, uint256 val) external;
    function tell(bytes32) external;
    function cure(bytes32) external;
    function cull(bytes32, address) external;
    function good(bytes32) external view returns (bool);
}

interface RwaUrnLike {
    function can(address) external view returns (uint256);
    function lock(uint256) external;
    function draw(uint256) external;
    function wipe(uint256) external;
    function free(uint256) external;
}

interface RwaOutputConduitLike {
    function can(address) external view returns (uint256);
    function may(address) external view returns (uint256);
    function pick(address) external;
    function push() external;
}

interface RwaInputConduitLike {
    function may(address) external view returns (uint256);
    function push() external;
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

        // RWA008
        checkChainlogKey("RWA008");
        checkChainlogKey("MCD_JOIN_RWA008_A");
        checkChainlogKey("RWA008_A_URN");
        checkChainlogKey("RWA008_A_OUTPUT_CONDUIT");
        checkChainlogKey("RWA008_A_INPUT_CONDUIT");
        checkChainlogKey("PIP_RWA008");

        // RWA009
        checkChainlogKey("RWA009_A_JAR");
        checkChainlogKey("RWA009");
        checkChainlogKey("MCD_JOIN_RWA009_A");
        checkChainlogKey("RWA009_A_URN");
        checkChainlogKey("RWA009_A_OUTPUT_CONDUIT");
        checkChainlogKey("PIP_RWA009");

        // RWA TOKEN FAB
        checkChainlogKey("RWA_TOKEN_FAB");

        checkChainlogVersion("1.13.3");
    }

    function testNewIlkRegistryValues() public { // make public to use
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // RWA008
        (, address pipRwa008,,) = oracle.ilks("RWA008-A");

        assertEq(reg.pos("RWA008-A"),    50);
        assertEq(reg.join("RWA008-A"),   addr.addr("MCD_JOIN_RWA008_A"));
        assertEq(reg.gem("RWA008-A"),    addr.addr("RWA008"));
        assertEq(reg.dec("RWA008-A"),    DSTokenAbstract(addr.addr("RWA008")).decimals());
        assertEq(reg.class("RWA008-A"),  3);
        assertEq(reg.pip("RWA008-A"),    pipRwa008);
        assertEq(reg.name("RWA008-A"),   "RWA008-A: SG Forge OFH");
        assertEq(reg.symbol("RWA008-A"), "RWA008");

        // RWA009
        (, address pipRwa009,,) = oracle.ilks("RWA009-A");

        assertEq(reg.pos("RWA009-A"),    51);
        assertEq(reg.join("RWA009-A"),   addr.addr("MCD_JOIN_RWA009_A"));
        assertEq(reg.gem("RWA009-A"),    addr.addr("RWA009"));
        assertEq(reg.dec("RWA009-A"),    GemAbstract(addr.addr("RWA009")).decimals());
        assertEq(reg.class("RWA009-A"),  3);
        assertEq(reg.pip("RWA009-A"),    pipRwa009);
        assertEq(reg.name("RWA009-A"),   "RWA009-A: H. V. Bank");
        assertEq(reg.symbol("RWA009-A"), GemAbstract(addr.addr("RWA009")).symbol());
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
            // Fail if the chainlog is the same size but local keys don't match the chainlog.
            for(uint256 i = 0; i < _count; i++) {
                (, address _val) = chainLog.get(i);
                if (_chainlog_addrs[i] != _val) {
                    emit log_named_string("Error", concat("TestError/chainlog-version-not-updated-address-change-", _version));
                    fail();
                    return;
                }
            }
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

    // RWA tests

    RwaLiquidationLike oracle = RwaLiquidationLike(addr.addr("MIP21_LIQUIDATION_ORACLE"));

    address              rwaOperator_008     = 0x3F761335890721752476d4F210A7ad9BEf66fb45;
    DSTokenAbstract      rwagem_008          = DSTokenAbstract(addr.addr("RWA008"));
    GemJoinAbstract      rwajoin_008         = GemJoinAbstract(addr.addr("MCD_JOIN_RWA008_A"));
    RwaUrnLike           rwaurn_008          = RwaUrnLike(addr.addr("RWA008_A_URN"));
    RwaInputConduitLike  rwaconduitin_008    = RwaInputConduitLike(addr.addr("RWA008_A_INPUT_CONDUIT"));
    RwaOutputConduitLike rwaconduitout_008   = RwaOutputConduitLike(addr.addr("RWA008_A_OUTPUT_CONDUIT"));

    DSTokenAbstract      rwagem_009          = DSTokenAbstract(addr.addr("RWA009"));
    GemJoinAbstract      rwajoin_009         = GemJoinAbstract(addr.addr("MCD_JOIN_RWA009_A"));
    RwaUrnLike           rwaurn_009          = RwaUrnLike(addr.addr("RWA009_A_URN"));
    address              RWA009_CES_MULTISIG = addr.addr("RWA009_A_OUTPUT_CONDUIT");

    function testRWA008_INTEGRATION_BUMP() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        giveAuth(address(oracle), address(this));

        (, address pip, , ) = oracle.ilks("RWA008-A");

        assertEq(DSValueAbstract(pip).read(), bytes32(30_437_069 * WAD), "RWA008: Bad initial PIP value");

        oracle.bump("RWA008-A", 40 * MILLION * WAD);

        assertEq(DSValueAbstract(pip).read(), bytes32(40 * MILLION * WAD), "RWA008: Bad PIP value after bump()");
    }

    function testRWA008_INTEGRATION_TELL() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        giveAuth(address(vat), address(this));
        giveAuth(address(oracle), address(this));

        (, , , uint48 tocPre) = oracle.ilks("RWA008-A");
        assertEq(uint256(tocPre), 0, "RWA008: `toc` is not 0 before tell()");
        assertTrue(oracle.good("RWA008-A"), "RWA008: Oracle not good before tell()");

        vat.file("RWA008-A", "line", 0);
        oracle.tell("RWA008-A");

        (, , , uint48 tocPost) = oracle.ilks("RWA008-A");
        assertGt(uint256(tocPost), 0, "RWA008: `toc` is not set after tell()");
        assertTrue(!oracle.good("RWA008-A"), "RWA008: Oracle still good after tell()");
    }

    function testRWA008_INTEGRATION_TELL_CURE_GOOD() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        giveAuth(address(vat), address(this));
        giveAuth(address(oracle), address(this));

        vat.file("RWA008-A", "line", 0);
        oracle.tell("RWA008-A");

        assertTrue(!oracle.good("RWA008-A"), "RWA008: Oracle still good after tell()");

        oracle.cure("RWA008-A");

        assertTrue(oracle.good("RWA008-A"), "RWA008: Oracle not good after cure()");
        (, , , uint48 toc) = oracle.ilks("RWA008-A");
        assertEq(uint256(toc), 0, "RWA008: `toc` not zero after cure()");
    }

    function testFailRWA008_INTEGRATION_CURE_BEFORE_TELL() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        giveAuth(address(oracle), address(this));

        oracle.cure("RWA008-A");
    }

    function testRWA008_INTEGRATION_TELL_CULL() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        giveAuth(address(vat), address(this));
        giveAuth(address(oracle), address(this));

        assertTrue(oracle.good("RWA008-A"));

        vat.file("RWA008-A", "line", 0);
        oracle.tell("RWA008-A");

        assertTrue(!oracle.good("RWA008-A"), "RWA008: Oracle still good after tell()");

        oracle.cull("RWA008-A", addr.addr("RWA008_A_URN"));

        assertTrue(!oracle.good("RWA008-A"), "RWA008: Oracle still good after cull()");
        (, address pip, , ) = oracle.ilks("RWA008-A");
        assertEq(DSValueAbstract(pip).read(), bytes32(0), "RWA008: Oracle PIP value not set to zero after cull()");
    }

    function testRWA008_OPERATOR_GET_RWA008_TOKEN() public {
        assertEq(rwagem_008.balanceOf(rwaOperator_008), 1 * WAD);
    }

    function testRWA008_OPERATOR_LOCK_DRAW_CONDUITS_WIPE_FREE() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // TODO: Figure out why warping here makes this test fail
        // hevm.warp(block.timestamp + 10 days); // Let rate be > 1

        // set the balance of this contract
        hevm.store(address(rwagem_008), keccak256(abi.encode(address(this), uint256(3))), bytes32(uint256(1 * WAD)));
        assertEq(rwagem_008.balanceOf(address(this)), 1 * WAD);
        // setting address(this) as operator
        hevm.store(address(rwaurn_008), keccak256(abi.encode(address(this), uint256(1))), bytes32(uint256(1)));
        assertEq(rwaurn_008.can(address(this)), 1);

        (uint256 preInk, uint256 preArt) = vat.urns("RWA008-A", address(rwaurn_008));

        rwagem_008.approve(address(rwaurn_008), 1 * WAD);
        rwaurn_008.lock(1 * WAD);
        assertEq(dai.balanceOf(address(rwaconduitout_008)), 0, "RWA008: Dangling Dai in input conduit before draw()");
        rwaurn_008.draw(1 * WAD);

        (, uint256 rate, , , ) = vat.ilks("RWA008-A");

        uint256 dustInVat = vat.dai(address(rwaurn_008));

        (uint256 ink, uint256 art) = vat.urns("RWA008-A", address(rwaurn_008));
        assertEq(ink, 1 * WAD + preInk, "RWA008: Bad `ink` after draw()");
        uint256 currArt = ((1 * RAD + dustInVat) / rate) + preArt;
        assertTrue(art >= currArt - 2 && art <= currArt + 2, "RWA008: Bad `art` after draw()"); // approximation for vat rounding
        assertEq(dai.balanceOf(address(rwaconduitout_008)), 1 * WAD, "RWA008: Dai not sent to output conduit after draw()");

        // wards
        giveAuth(address(rwaconduitout_008), address(this));
        // can
        hevm.store(address(rwaconduitout_008), keccak256(abi.encode(address(this), uint256(1))), bytes32(uint256(1)));
        assertEq(rwaconduitout_008.can(address(this)), 1);
        // may
        hevm.store(address(rwaconduitout_008), keccak256(abi.encode(address(this), uint256(6))), bytes32(uint256(1)));
        assertEq(rwaconduitout_008.may(address(this)), 1);

        rwaconduitout_008.pick(address(this));
        rwaconduitout_008.push();

        assertEq(dai.balanceOf(address(rwaconduitout_008)), 0, "RWA008: Output conduit still holds Dai after push()");
        assertEq(dai.balanceOf(address(this)), 1 * WAD, "RWA008: Dai not sent to destination after push()");

        (ink, art) = vat.urns("RWA008-A", address(rwaurn_008));
        assertEq(ink, 1 * WAD + preInk, "RWA008: Bad `ink` after push()");
        currArt = ((1 * RAD + dustInVat) / rate) + preArt;
        assertTrue(art >= currArt - 2 && art <= currArt + 2, "RWA008: Bad `art` after push()"); // approximation for vat rounding

        hevm.warp(block.timestamp + 10 days);
        jug.drip("RWA008-A");

        (, rate, , , ) = vat.ilks("RWA008-A");

        uint256 daiToPay = (art * rate - dustInVat) / RAY + 1; // extra wei rounding

        hevm.store(
            address(vat),
            keccak256(abi.encode(address(this), uint256(5))),
            bytes32(daiToPay * RAY)
        ); // Forcing extra dai balance for addres(this) on the Vat
        vat.hope(address(daiJoin));
        daiJoin.exit(address(this), daiToPay);
        // wards
        giveAuth(address(rwaconduitin_008), address(this));
        // may
        hevm.store(address(rwaconduitin_008), keccak256(abi.encode(address(this), uint256(4))), bytes32(uint256(1)));
        assertEq(rwaconduitin_008.may(address(this)), 1);

        assertEq(dai.balanceOf(address(rwaconduitin_008)), 0, "RWA008: Dangling Dai in input conduit before transfer()");
        dai.transfer(address(rwaconduitin_008), daiToPay);
        assertEq(dai.balanceOf(address(rwaconduitin_008)), daiToPay, "RWA008: Dai not sent to input conduit after transfer()");
        rwaconduitin_008.push();

        assertEq(dai.balanceOf(address(rwaurn_008)), daiToPay, "RWA008: Dai not sent to the urn after push()");
        assertEq(dai.balanceOf(address(rwaconduitin_008)), 0, "RWA008: Dangling Dai in input conduit after push()");

        rwaurn_008.wipe(daiToPay);
        rwaurn_008.free(1 * WAD);

        (ink, art) = vat.urns("RWA008-A", address(rwaurn_008));
        assertEq(ink, preInk, "RWA008: Bad `ink` after free()");
        assertLt(art, 4, "RWA008: Bad `art` - larger than conversion error dust after wipe()"); // wad -> rad conversion in wipe leaves some dust
    }

    function testRWA009_INTEGRATION_BUMP() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        giveAuth(address(oracle), address(this));

        (, address pip, , ) = oracle.ilks("RWA009-A");

        assertEq(DSValueAbstract(pip).read(), bytes32(100 * MILLION * WAD), "RWA009: Bad initial PIP value");

        oracle.bump("RWA009-A", 110 * MILLION * WAD);

        assertEq(DSValueAbstract(pip).read(), bytes32(110 * MILLION * WAD), "RWA009: Bad PIP value after bump()");
    }

    function testRWA009_INTEGRATION_TELL() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        giveAuth(address(vat), address(this));
        giveAuth(address(oracle), address(this));

        (, , , uint48 tocPre) = oracle.ilks("RWA009-A");
        assertEq(uint256(tocPre), 0, "RWA009: `toc` is not 0 before tell()");
        assertTrue(oracle.good("RWA009-A"), "RWA009: Oracle not good before tell()");

        vat.file("RWA009-A", "line", 0);
        oracle.tell("RWA009-A");

        (, , , uint48 tocPost) = oracle.ilks("RWA009-A");
        assertGt(uint256(tocPost), 0, "RWA009: `toc` is not set after tell()");
        assertTrue(!oracle.good("RWA009-A"), "RWA009: Oracle still good after tell()");
    }

    function testRWA009_INTEGRATION_TELL_CURE_GOOD() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        giveAuth(address(vat), address(this));
        giveAuth(address(oracle), address(this));

        vat.file("RWA009-A", "line", 0);
        oracle.tell("RWA009-A");

        assertTrue(!oracle.good("RWA009-A"), "RWA009: Oracle still good after tell()");

        oracle.cure("RWA009-A");

        assertTrue(oracle.good("RWA009-A"), "RWA009: Oracle not good after cure()");
        (, , , uint48 toc) = oracle.ilks("RWA009-A");
        assertEq(uint256(toc), 0, "RWA009: `toc` not zero after cure()");
    }

    function testFailRWA009_INTEGRATION_CURE_BEFORE_TELL() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        giveAuth(address(oracle), address(this));

        oracle.cure("RWA009-A");
    }

    function testRWA009_INTEGRATION_TELL_CULL() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        giveAuth(address(vat), address(this));
        giveAuth(address(oracle), address(this));

        assertTrue(oracle.good("RWA009-A"));

        vat.file("RWA009-A", "line", 0);
        oracle.tell("RWA009-A");

        assertTrue(!oracle.good("RWA009-A"), "RWA009: Oracle still good after tell()");

        oracle.cull("RWA009-A", addr.addr("RWA009_A_URN"));

        assertTrue(!oracle.good("RWA009-A"), "RWA009: Oracle still good after cull()");
        (, address pip, , ) = oracle.ilks("RWA009-A");
        assertEq(DSValueAbstract(pip).read(), bytes32(0), "RWA009: Oracle PIP value not set to zero after cull()");
    }

    function testRWA009_SPELL_OPERATOR_WIPE_FREE() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        uint256 drawAmount = 25_000_000 * WAD;

        // setting address(this) as operator
        hevm.store(address(rwaurn_009), keccak256(abi.encode(address(this), uint256(1))), bytes32(uint256(1)));
        assertEq(rwaurn_009.can(address(this)), 1);

        // Check if spell lock 1 * WAD of RWA009
        assertEq(rwagem_009.balanceOf(address(rwajoin_009)), 1 * WAD, "RWA009: gem not locked into the urn");

        // Check if spell draw 25mm DAI to GENESIS
        assertEq(dai.balanceOf(address(RWA009_CES_MULTISIG)), drawAmount, "RWA009: Dai drawn was not send to the recipient");

        (uint256 ink, uint256 art) = vat.urns("RWA009-A", address(rwaurn_009));
        assertEq(art, drawAmount, "RWA009: bad `art` after spell"); // DAI drawn == art as rate should always be 1 RAY
        assertEq(ink, 1 * WAD, "RWA009: bad `ink` after spell"); // Whole unit of collateral is locked

        hevm.warp(block.timestamp + 10 days);
        jug.drip("RWA009-A");

        (, uint256 rate,,,) = vat.ilks("RWA009-A");
        assertEq(rate, RAY, 'RWA009: bad `rate`'); // rate keeps being 1 RAY

        // as we have SF 0 we need to pay exectly the same amount of DAI we have drawn
        uint256 daiToPay = drawAmount;

        // transfer DAI to the URN
        hevm.store(
            address(vat),
            keccak256(abi.encode(address(this), uint256(5))),
            bytes32(daiToPay * RAY)
        ); // Forcing extra dai balance for addres(this) on the Vat
        vat.hope(address(daiJoin));
        daiJoin.exit(address(this), daiToPay);
        dai.transfer(address(rwaurn_009), daiToPay);
        assertEq(dai.balanceOf(address(rwaurn_009)), daiToPay, "Balance of the URN doesnt match");

        // repay debt and free our collateral
        rwaurn_009.wipe(daiToPay);
        rwaurn_009.free(1 * WAD);

        // check if MCD_PAUSE_PROXY have RWA009 Tokens
        assertEq(rwagem_009.balanceOf(address(this)), 1 * WAD, "RWA009: gem not sent back to the caller");

        // check if we have 0 collateral and outstanding debt in the VAT
        (ink, art) = vat.urns("RWA009-A", address(rwaurn_009));
        assertEq(ink, 0, "RWA009: bad `ink` after free()");
        assertEq(art, 0, "RWA009: bad `art` after wipe()");
    }
}
