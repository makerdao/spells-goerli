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

interface RwaUrnLike {
    function can(address) external view returns (uint256);
    function gemJoin() external view returns (GemAbstract);
    function lock(uint256) external;
    function draw(uint256) external;
    function wipe(uint256) external;
    function free(uint256) external;
}

interface WriteableRwaLiquidationLike is RwaLiquidationLike {
    function bump(bytes32 ilk, uint256 val) external;
    function tell(bytes32) external;
    function cure(bytes32) external;
    function cull(bytes32, address) external;
    function good(bytes32) external view returns (bool);
}

interface Root {
    function wards(address) external view returns (uint256);
    function relyContract(address, address) external;
}

interface MemberList {
    function updateMember(address, uint256) external;
}

interface AssessorLike {
    function calcSeniorTokenPrice() external returns (uint256);
}

interface FileLike {
    function file(bytes32 what, address data) external;
}

interface TinlakeManagerLike {
    function gem() external view returns (address);
    function liq() external view returns (address);
    function urn() external view returns (address);
    function wards(address) external view returns (uint256);
    function lock(uint256 wad) external;
    function join(uint256 wad) external;
    function draw(uint256 wad) external;
    function wipe(uint256 wad) external;
    function exit(uint256 wad) external;
    function free(uint256 wad) external;
}

interface DropTokenAbstract is DSTokenAbstract {
    function wards(address) external view returns (uint256);
}

struct CentrifugeCollateralTestValues {
    bytes32 ilk;
    string ilkString;
    address LIQ;
    address DROP;
    address URN;
    address GEM_JOIN;
    uint256 CEIL;
    uint256 PRICE;

    address MGR;
    address ROOT;
    address COORDINATOR;
    address MEMBERLIST;

    bytes32 pipID;
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

        // try chainLog.getAddress("RWA007_A_INPUT_CONDUIT_URN") {
        //     assertTrue(false);
        // } catch Error(string memory errmsg) {
        //     assertTrue(cmpStr(errmsg, "dss-chain-log/invalid-key"));
        // } catch {
        //     assertTrue(false);
        // }
    }

    function testCollateralIntegrations() public { // make public to use
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Insert new collateral tests here
        checkIlkIntegration(
            "GNO-A",
            GemJoinAbstract(addr.addr("MCD_JOIN_GNO_A")),
            ClipAbstract(addr.addr("MCD_CLIP_GNO_A")),
            addr.addr("PIP_GNO"),
            true, /* _isOSM */
            true, /* _checkLiquidations */
            false /* _transferFee */
        );
    }

    function testIlkClipper() public { // make public to use
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // GNO
        checkIlkClipper(
            "GNO-A",
            GemJoinAbstract(addr.addr("MCD_JOIN_GNO_A")),
            ClipAbstract(addr.addr("MCD_CLIP_GNO_A")),
            addr.addr("MCD_CLIP_CALC_GNO_A"),
            OsmAbstract(addr.addr("PIP_GNO")),
            5_000 * WAD
        );

        // renBTC
        checkIlkClipper(
            "RENBTC-A",
            GemJoinAbstract(addr.addr("MCD_JOIN_RENBTC_A")),
            ClipAbstract(addr.addr("MCD_CLIP_RENBTC_A")),
            addr.addr("MCD_CLIP_CALC_RENBTC_A"),
            OsmAbstract(addr.addr("PIP_RENBTC")),
            5 * WAD
        );
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

    function testNewChainlogValues() public { // make private to disable
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        checkChainlogKey("GNO");
        checkChainlogKey("PIP_GNO");
        checkChainlogKey("MCD_JOIN_GNO_A");
        checkChainlogKey("MCD_CLIP_GNO_A");
        checkChainlogKey("MCD_CLIP_CALC_GNO_A");

        checkChainlogKey("RWA010");
        checkChainlogKey("PIP_RWA010");
        checkChainlogKey("MCD_JOIN_RWA010_A");
        checkChainlogKey("RWA010_A_URN");
        checkChainlogKey("RWA010_A_INPUT_CONDUIT");
        checkChainlogKey("RWA010_A_OUTPUT_CONDUIT");

        checkChainlogKey("RWA011");
        checkChainlogKey("PIP_RWA011");
        checkChainlogKey("MCD_JOIN_RWA011_A");
        checkChainlogKey("RWA011_A_URN");
        checkChainlogKey("RWA011_A_INPUT_CONDUIT");
        checkChainlogKey("RWA011_A_OUTPUT_CONDUIT");

        checkChainlogKey("RWA012");
        checkChainlogKey("PIP_RWA012");
        checkChainlogKey("MCD_JOIN_RWA012_A");
        checkChainlogKey("RWA012_A_URN");
        checkChainlogKey("RWA012_A_INPUT_CONDUIT");
        checkChainlogKey("RWA012_A_OUTPUT_CONDUIT");

        checkChainlogKey("RWA013");
        checkChainlogKey("PIP_RWA013");
        checkChainlogKey("MCD_JOIN_RWA013_A");
        checkChainlogKey("RWA013_A_URN");
        checkChainlogKey("RWA013_A_INPUT_CONDUIT");
        checkChainlogKey("RWA013_A_OUTPUT_CONDUIT");

        checkChainlogVersion("1.14.7");
    }

    function testNewIlkRegistryValues() public { // make private to disable
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Insert new ilk registry values tests here
        // GNO-A
        assertEq(reg.pos("GNO-A"),    55);
        assertEq(reg.join("GNO-A"),   addr.addr("MCD_JOIN_GNO_A"));
        assertEq(reg.gem("GNO-A"),    addr.addr("GNO"));
        assertEq(reg.dec("GNO-A"),    GemAbstract(addr.addr("GNO")).decimals());
        assertEq(reg.class("GNO-A"),  1);
        assertEq(reg.pip("GNO-A"),    addr.addr("PIP_GNO"));
        assertEq(reg.name("GNO-A"),   "Gnosis Token");
        assertEq(reg.symbol("GNO-A"), GemAbstract(addr.addr("GNO")).symbol());

        // RWA010-A
        assertEq(reg.pos("RWA010-A"),    56);
        assertEq(reg.join("RWA010-A"),   addr.addr("MCD_JOIN_RWA010_A"));
        assertEq(reg.gem("RWA010-A"),    addr.addr("RWA010"));
        assertEq(reg.dec("RWA010-A"),    GemAbstract(addr.addr("RWA010")).decimals());
        assertEq(reg.class("RWA010-A"),  3);
        assertEq(reg.pip("RWA010-A"),    addr.addr("PIP_RWA010"));
        assertEq(reg.name("RWA010-A"),   "RWA010-A: Centrifuge: BlockTower Credit (I)");
        assertEq(reg.symbol("RWA010-A"), GemAbstract(addr.addr("RWA010")).symbol());

        // RWA011-A
        assertEq(reg.pos("RWA011-A"),    57);
        assertEq(reg.join("RWA011-A"),   addr.addr("MCD_JOIN_RWA011_A"));
        assertEq(reg.gem("RWA011-A"),    addr.addr("RWA011"));
        assertEq(reg.dec("RWA011-A"),    GemAbstract(addr.addr("RWA011")).decimals());
        assertEq(reg.class("RWA011-A"),  3);
        assertEq(reg.pip("RWA011-A"),    addr.addr("PIP_RWA011"));
        assertEq(reg.name("RWA011-A"),   "RWA011-A: Centrifuge: BlockTower Credit (II)");
        assertEq(reg.symbol("RWA011-A"), GemAbstract(addr.addr("RWA011")).symbol());

        // RWA012-A
        assertEq(reg.pos("RWA012-A"),    58);
        assertEq(reg.join("RWA012-A"),   addr.addr("MCD_JOIN_RWA012_A"));
        assertEq(reg.gem("RWA012-A"),    addr.addr("RWA012"));
        assertEq(reg.dec("RWA012-A"),    GemAbstract(addr.addr("RWA012")).decimals());
        assertEq(reg.class("RWA012-A"),  3);
        assertEq(reg.pip("RWA012-A"),    addr.addr("PIP_RWA012"));
        assertEq(reg.name("RWA012-A"),   "RWA012-A: Centrifuge: BlockTower Credit (III)");
        assertEq(reg.symbol("RWA012-A"), GemAbstract(addr.addr("RWA012")).symbol());

        // RWA012-A
        assertEq(reg.pos("RWA013-A"),    59);
        assertEq(reg.join("RWA013-A"),   addr.addr("MCD_JOIN_RWA013_A"));
        assertEq(reg.gem("RWA013-A"),    addr.addr("RWA013"));
        assertEq(reg.dec("RWA013-A"),    GemAbstract(addr.addr("RWA013")).decimals());
        assertEq(reg.class("RWA013-A"),  3);
        assertEq(reg.pip("RWA013-A"),    addr.addr("PIP_RWA013"));
        assertEq(reg.name("RWA013-A"),   "RWA013-A: Centrifuge: BlockTower Credit (IV)");
        assertEq(reg.symbol("RWA013-A"), GemAbstract(addr.addr("RWA013")).symbol());
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

    function testOSMs() private { // make public to use
        address READER = address(0);

        // Track OSM authorizations here
        assertEq(OsmAbstract(addr.addr("PIP_TOKEN")).bud(READER), 0);

        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        assertEq(OsmAbstract(addr.addr("PIP_TOKEN")).bud(READER), 1);
    }

    function testPSMs() public {

        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        bytes32 _ilk = "PSM-PAX-A";
        checkPsmIlkIntegration(
            _ilk,
            GemJoinAbstract(reg.join(_ilk)),
            ClipAbstract(reg.xlip(_ilk)),
            reg.pip(_ilk),
            PsmAbstract(chainLog.getAddress("MCD_PSM_PAX_A")),
            calcPSMRateFromBPS(10),
            calcPSMRateFromBPS(0)
        );

        _ilk = "PSM-GUSD-A";
        checkPsmIlkIntegration(
            _ilk,
            GemJoinAbstract(reg.join(_ilk)),
            ClipAbstract(reg.xlip(_ilk)),
            reg.pip(_ilk),
            PsmAbstract(chainLog.getAddress("MCD_PSM_GUSD_A")),
            calcPSMRateFromBPS(10),
            calcPSMRateFromBPS(10)
        );
    }

    // Use for PSM tin/tout. Calculations are slightly different from elsewhere in MCD
    function calcPSMRateFromBPS(uint256 _bps) internal pure returns (uint256 _amt) {
        return _bps * WAD / 10000;
    }

    function testMedianizers() private { // make public to use
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
        // The DssSpell bytecode is non-deterministic, compare only code size
        DssSpell expectedSpell = new DssSpell();
        assertEq(getExtcodesize(address(spell)), getExtcodesize(address(expectedSpell)), "TestError/spell-codesize");

        // The SpellAction bytecode can be compared after chopping off the metada
        address expectedAction = expectedSpell.action();
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
        assertEq(actualHash, expectedHash);
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
        // VestAbstract vest = VestAbstract(addr.addr("MCD_VEST_DAI"));

        // assertEq(vest.ids(), 0);

        // vote(address(spell));
        // scheduleWaitAndCast(address(spell));
        // assertTrue(spell.done());

        // assertEq(vest.ids(), 1);

        // assertEq(vest.cap(), 1 * MILLION * WAD / 30 days);

        // assertEq(vest.usr(1), address(pauseProxy));
        // assertEq(vest.bgn(1), block.timestamp - 1 days);
        // assertEq(vest.clf(1), block.timestamp - 1 days);
        // assertEq(vest.fin(1), block.timestamp);
        // assertEq(vest.mgr(1), address(0));
        // assertEq(vest.res(1), 0);
        // assertEq(vest.tot(1), WAD);
        // assertEq(vest.rxd(1), 0);

        // uint256 prevBalance = dai.balanceOf(address(pauseProxy));
        // assertTrue(tryVest(address(vest), 1));
        // assertEq(dai.balanceOf(address(pauseProxy)), prevBalance + WAD);

        // assertEq(vest.rxd(1), WAD);
    }

    // ---------------------- Centrifuge-Blocktower Vaults ----------------------

    uint256 constant INITIAL_THIS_DAI_BALANCE  =   1_000_000 * WAD;
    uint256 constant INITIAL_THIS_DROP_BALANCE = 100_000_000 * WAD;
    uint256 constant DAI_DRAW_AMOUNT           =  10_000_000 * WAD;
    uint256 constant DROP_JOIN_AMOUNT          =  20_000_000 * WAD;

    CentrifugeCollateralTestValues[] collaterals;

    function _setupCentrifugeCollaterals() internal {

        // Give 10000 Dai to this contract
        hevm.store(address(dai), keccak256(abi.encode(address(this), uint256(2))), bytes32(uint256(INITIAL_THIS_DAI_BALANCE)));
        assertEq(dai.balanceOf(address(this)), INITIAL_THIS_DAI_BALANCE);

        collaterals.push(CentrifugeCollateralTestValues({
            pipID:       "PIP_RWA010",
            ilk:         "RWA010-A",
            ilkString:   "RWA010",
            LIQ:         addr.addr("MIP21_LIQUIDATION_ORACLE"),
            GEM_JOIN:    addr.addr("MCD_JOIN_RWA010_A"),
            URN:         addr.addr("RWA010_A_URN"),
            CEIL:        20_000_000 * WAD,
            PRICE:       24_333_058 * WAD,
            ROOT:        0xD128CB475D0716044A35866a6779CCc14E91b7b6,
            COORDINATOR: 0x9102D043Cee43484dd9CE7310847ef12C95ac55A,
            DROP:        0xd7943e68bD284dAd75A59d07Fab7708a21B8a95E,
            MEMBERLIST:  0x7442D0bf37bD2598dfBA92023E060862E128ccc0,
            MGR:         0x8828D2B96fa09864851244a8a2434C5A9a7B7AbD
        }));

        collaterals.push(CentrifugeCollateralTestValues({
            pipID:       "PIP_RWA011",
            ilk:         "RWA011-A",
            ilkString:   "RWA011",
            LIQ:         addr.addr("MIP21_LIQUIDATION_ORACLE"),
            GEM_JOIN:    addr.addr("MCD_JOIN_RWA011_A"),
            URN:         addr.addr("RWA011_A_URN"),
            CEIL:        30_000_000 * WAD,
            PRICE:       36_499_587 * WAD,
            ROOT:        0x0b55da7112dD417Fe7a900ee8e346F17E504292c,
            COORDINATOR: 0xB03a063FcBde0d8aE591A12276A26c4BADEc7a40,
            DROP:        0xA586bB77069739Bb9Cb8608c51a21C18AF87Fb2E,
            MEMBERLIST:  0x9b401d3714f41457755a6A0587215E8757Ca4aE0,
            MGR:         0xcBd44c9Ec0D2b9c466887e700eD88D302281E098
        }));

        collaterals.push(CentrifugeCollateralTestValues({
            pipID:       "PIP_RWA012",
            ilk:         "RWA012-A",
            ilkString:   "RWA012",
            LIQ:         addr.addr("MIP21_LIQUIDATION_ORACLE"),
            GEM_JOIN:    addr.addr("MCD_JOIN_RWA012_A"),
            URN:         addr.addr("RWA012_A_URN"),
            CEIL:        30_000_000 * WAD,
            PRICE:       36_499_587 * WAD,
            ROOT:        0x60b71e9DCEeDAAC275c377630E054bc60a21A02B,
            COORDINATOR: 0x3f82851463C172DBDc1229cA06170fF89f5638dC,
            DROP:        0x82b84166f7CB140A6a66308da10728a3DB3A73A4,
            MEMBERLIST:  0xAe9f348Dd245BCdD7D3D6Bbb20346059B2259b71,
            MGR:         0xaef64c80712d5959f240BE1339aa639CDFA858Ff
        }));

        collaterals.push(CentrifugeCollateralTestValues({
            pipID:       "PIP_RWA013",
            ilk:         "RWA013-A",
            ilkString:   "RWA013",
            LIQ:         addr.addr("MIP21_LIQUIDATION_ORACLE"),
            GEM_JOIN:    addr.addr("MCD_JOIN_RWA013_A"),
            URN:         addr.addr("RWA013_A_URN"),
            CEIL:        70_000_000 * WAD,
            PRICE:       85_165_703 * WAD,
            ROOT:        0xCd5Cb76a0208eAbdFFC2074f32591878a10686ae,
            COORDINATOR: 0x3C896EF5d7648Dd11CBDE5EDd6470063a0e780cA,
            DROP:        0x0691FAEa2Eb8eBB2C36Fc24d577cA73AfbDB7Bdd,
            MEMBERLIST:  0xbf78fff127d58f177531045d1E3588a03847Ac4C,
            MGR:         0xc5A1418aC32B5f978460f1211B76B5D44e69B530
        }));

        for (uint256 i = 0; i < collaterals.length; i++) {
            _setupCentrifugeCollateral(collaterals[i]);
        }

        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        for (uint256 i = 0; i < collaterals.length; i++) {
            _tinlakeMgrLock(collaterals[i]);
        }
    }

    function _setupCentrifugeCollateral(CentrifugeCollateralTestValues memory collateral) internal {
        Root root = Root(collateral.ROOT);
        TinlakeManagerLike mgr = TinlakeManagerLike(collateral.MGR);
        DSTokenAbstract drop = DSTokenAbstract(collateral.DROP);
        MemberList memberlist = MemberList(collateral.MEMBERLIST);

        // Welcome to hevm KYC
        hevm.store(collateral.ROOT, keccak256(abi.encode(address(this), uint256(0))), bytes32(uint256(1)));
        assertEq(root.wards(address(this)), 1);

        root.relyContract(collateral.MEMBERLIST, address(this));

        memberlist.updateMember(address(this), type(uint256).max);
        memberlist.updateMember(collateral.MGR, type(uint256).max);

        // Set this contract as `ward` on `mgr`
        hevm.store(collateral.MGR, keccak256(abi.encode(address(this), uint256(0))), bytes32(uint256(1)));
        assertEq(mgr.wards(address(this)), 1);

        // Give some DROP tokens to the test contract
        hevm.store(collateral.DROP, keccak256(abi.encode(address(this), uint256(0))), bytes32(uint256(1)));
        assertEq(DropTokenAbstract(collateral.DROP).wards(address(this)), 1);

        DropTokenAbstract(collateral.DROP).mint(address(this), INITIAL_THIS_DROP_BALANCE);
        assertEq(drop.balanceOf(address(this)), INITIAL_THIS_DROP_BALANCE);

        // Approve the managers
        drop.approve(collateral.MGR, type(uint256).max);
        dai.approve(collateral.MGR, type(uint256).max);
    }

    function _tinlakeMgrLock(CentrifugeCollateralTestValues memory collateral) internal {
        TinlakeManagerLike mgr = TinlakeManagerLike(collateral.MGR);
        uint256 rwaTokenAmount = 1 * WAD;
        mgr.lock(rwaTokenAmount);
    }

    function test_INTEGRATION_SETUP() public {
        _setupCentrifugeCollaterals();

        for (uint256 i = 0; i < collaterals.length; i++) {
            _testIntegrationSetup(collaterals[i]);
        }
    }

    function _testIntegrationSetup(CentrifugeCollateralTestValues memory collateral) internal {
        emit log_named_string("Test integration tinlake mgr setup", collateral.ilkString);

        TinlakeManagerLike mgr = TinlakeManagerLike(collateral.MGR);
        GemJoinAbstract rwaJoin = GemJoinAbstract(collateral.GEM_JOIN);
        RwaUrnLike urn = RwaUrnLike(collateral.URN);

        assertEq(vat.wards(collateral.GEM_JOIN), 1, "Vat/gemjoin-not-ward");

        assertEq(mgr.wards(pauseProxy), 1, "TinlakeManager/pause-proxy-not-ward");
        assertEq(rwaJoin.wards(address(urn)), 1, "Join/ward-urn-not-set");
        assertEq(urn.can(address(mgr)), 1, "Urn/operator-not-hoped");

        assertEq(mgr.liq(), collateral.LIQ, "TinlakeManager/liq-not-match");
        assertEq(mgr.urn(), collateral.URN, "TinlakeManager/urn-not-match");

        RwaLiquidationLike oracle = RwaLiquidationLike(collateral.LIQ);
        (, address pip, ,) = oracle.ilks(collateral.ilk);

        assertTrue(pip != address(0), "RwaLiquidationOracle/ilk-not-init");
        assertEq(pip, addr.addr(collateral.pipID), "RwaLiquidationOracle/pip-not-match");

        (pip, ) = spotter.ilks(collateral.ilk);
        assertEq(pip, addr.addr(collateral.pipID), "Spotter/pip-not-match");
    }

    function test_INTEGRATION_BUMP() public {
        _setupCentrifugeCollaterals();

        for (uint256 i = 0; i < collaterals.length; i++) {
            _testIntegrationBump(collaterals[i]);
        }
    }

    function _testIntegrationBump(CentrifugeCollateralTestValues memory collateral) internal {
        emit log_named_string("Test integration liquidation oracle bump", collateral.ilkString);

        WriteableRwaLiquidationLike oracle = WriteableRwaLiquidationLike(collateral.LIQ);
        giveAuth(address(oracle), address(this));

        (, address pip, , ) = oracle.ilks(collateral.ilk);

        assertEq(DSValueAbstract(pip).read(), bytes32(collateral.PRICE), "Bad initial PIP value");

        oracle.bump(collateral.ilk, collateral.PRICE + 10_000_000 * WAD);

        assertEq(DSValueAbstract(pip).read(), bytes32(collateral.PRICE + 10_000_000 * WAD), "Bad PIP value after bump()");
    }

    function test_INTEGRATION_TELL() public {
        _setupCentrifugeCollaterals();

        for (uint256 i = 0; i < collaterals.length; i++) {
            _testIntegrationTell(collaterals[i]);
        }
    }

    function _testIntegrationTell(CentrifugeCollateralTestValues memory collateral) internal {
        emit log_named_string("Test integration liquidation oracle tell", collateral.ilkString);

        WriteableRwaLiquidationLike oracle = WriteableRwaLiquidationLike(collateral.LIQ);

        giveAuth(address(vat), address(this));
        giveAuth(address(oracle), address(this));

        (, , , uint48 tocPre) = oracle.ilks(collateral.ilk);
        assertEq(uint256(tocPre), 0, "`toc` is not 0 before tell()");
        assertTrue(oracle.good(collateral.ilk), "Oracle not good before tell()");

        vat.file(collateral.ilk, "line", 0);
        oracle.tell(collateral.ilk);

        (, , , uint48 tocPost) = oracle.ilks(collateral.ilk);
        assertGt(uint256(tocPost), 0, "`toc` is not set after tell()");
        assertTrue(!oracle.good(collateral.ilk), "Oracle still good after tell()");
    }

    function test_INTEGRATION_TELL_CURE_GOOD() public {
        _setupCentrifugeCollaterals();

        for (uint256 i = 0; i < collaterals.length; i++) {
            _testIntegrationTellCureGood(collaterals[i]);
        }
    }

    function _testIntegrationTellCureGood(CentrifugeCollateralTestValues memory collateral) internal {
        emit log_named_string("Test integration liquidation oracle is good after tell followed by cure", collateral.ilkString);

        WriteableRwaLiquidationLike oracle = WriteableRwaLiquidationLike(collateral.LIQ);

        giveAuth(address(vat), address(this));
        giveAuth(address(oracle), address(this));

        vat.file(collateral.ilk, "line", 0);
        oracle.tell(collateral.ilk);

        assertTrue(!oracle.good(collateral.ilk), "Oracle still good after tell()");

        oracle.cure(collateral.ilk);

        assertTrue(oracle.good(collateral.ilk), "Oracle not good after cure()");
        (, , , uint48 toc) = oracle.ilks(collateral.ilk);
        assertEq(uint256(toc), 0, "`toc` not zero after cure()");
    }

    function test_INTEGRATION_TELL_CULL() public {
        _setupCentrifugeCollaterals();

        for (uint256 i = 0; i < collaterals.length; i++) {
            _testIntegrationTellCull(collaterals[i]);
        }
    }

    function _testIntegrationTellCull(CentrifugeCollateralTestValues memory collateral) internal {
        emit log_named_string("Test integration liquidation tell followed by cull", collateral.ilkString);

        WriteableRwaLiquidationLike oracle = WriteableRwaLiquidationLike(collateral.LIQ);

        giveAuth(address(vat), address(this));
        giveAuth(address(oracle), address(this));

        assertTrue(oracle.good(collateral.ilk));

        vat.file(collateral.ilk, "line", 0);
        oracle.tell(collateral.ilk);

        assertTrue(!oracle.good(collateral.ilk), "Oracle still good after tell()");

        oracle.cull(collateral.ilk, collateral.URN);

        assertTrue(!oracle.good(collateral.ilk), "Oracle still good after cull()");
        (, address pip, , ) = oracle.ilks(collateral.ilk);
        assertEq(DSValueAbstract(pip).read(), bytes32(0), "Oracle PIP value not set to zero after cull()");
    }

    function test_PAUSE_PROXY_OWNS_RWA_TOKEN_BEFORE_SPELL() public {
        for (uint256 i = 0; i < collaterals.length; i++) {
            _testPauseProxyOwnsRwaTokenBeforeSpell(collaterals[i]);
        }
    }

    function _testPauseProxyOwnsRwaTokenBeforeSpell(CentrifugeCollateralTestValues memory collateral) internal {
        emit log_named_string("Test MCD_PAUSE_PROXY owns the RWA token before the spell", collateral.ilkString);

        GemJoinAbstract gemJoin = GemJoinAbstract(collateral.GEM_JOIN);
        GemAbstract gem = GemAbstract(gemJoin.gem());

        assertEq(gem.balanceOf(pauseProxy), 1 * WAD);
    }

    function test_TINLAKE_MGR_JOIN_DRAW_WIPE_EXIT_FREE() public {
        _setupCentrifugeCollaterals();

        for (uint256 i = 0; i < collaterals.length; i++) {
            _testTinlakeMgrJoinDraw(collaterals[i]);
        }

        // Accrue some stability fees
        hevm.warp(block.timestamp + 10 days);
        for (uint256 i = 0; i < collaterals.length; i++) {
            jug.drip(collaterals[i].ilk);
        }

        for (uint256 i = 0; i < collaterals.length; i++) {
            _testTinlakeMgrWipeExitFree(collaterals[i]);
        }
    }

    function _testTinlakeMgrJoinDraw(CentrifugeCollateralTestValues memory collateral) internal {
        emit log_named_string("Test tinlake mgr join and draw", collateral.ilkString);

        TinlakeManagerLike mgr = TinlakeManagerLike(collateral.MGR);
        DSTokenAbstract drop = DSTokenAbstract(collateral.DROP);
        GemJoinAbstract gemJoin = GemJoinAbstract(collateral.GEM_JOIN);
        GemAbstract gem = GemAbstract(gemJoin.gem());

        uint256 preThisDaiBalance = dai.balanceOf(address(this));
        uint256 preMgrDropBalance = drop.balanceOf(collateral.MGR);
        assertEq(
            drop.balanceOf(address(this)),
            INITIAL_THIS_DROP_BALANCE,
            "Pre-condition: initial address(this) drop balance mismatch"
        );

        // Check if the RWA token is locked into the Urn
        assertEq(gem.balanceOf(address(gemJoin)), 1 * WAD, "Pre-condition: gem not locked into the urn");
        // 0 DAI in mgr
        assertEq(dai.balanceOf(address(mgr)), 0, "Dangling Dai in mgr before draw()");

        mgr.join(DROP_JOIN_AMOUNT);
        mgr.draw(DAI_DRAW_AMOUNT);

        assertEq(
            dai.balanceOf(address(this)),
            preThisDaiBalance + DAI_DRAW_AMOUNT,
            "Post-condition: invalid Dai balance on address(this)"
        );
        assertEq(
            drop.balanceOf(address(this)),
            INITIAL_THIS_DROP_BALANCE - DROP_JOIN_AMOUNT,
            "Post-condition: invalid Drop balance on address(this)"
        );
        assertEq(
            drop.balanceOf(address(mgr)),
            preMgrDropBalance + DROP_JOIN_AMOUNT,
            "Post-condition: invalid Drop balance on mgr"
        );

        (uint256 ink, uint256 art) = vat.urns(collateral.ilk, collateral.URN);
        assertEq(art, DAI_DRAW_AMOUNT, "Post-condition: bad art on vat"); // DAI drawn == art as rate should always be 1 RAY
        assertEq(ink, 1 * WAD, "Post-condition: bad ink on vat"); // Whole unit of collateral is locked
    }

    function _testTinlakeMgrWipeExitFree(CentrifugeCollateralTestValues memory collateral) internal {
        emit log_named_string("Test tinlake mgr wipe and exit", collateral.ilkString);

        TinlakeManagerLike mgr = TinlakeManagerLike(collateral.MGR);
        DSTokenAbstract drop = DSTokenAbstract(collateral.DROP);
        GemJoinAbstract gemJoin = GemJoinAbstract(collateral.GEM_JOIN);
        GemAbstract gem = GemAbstract(gemJoin.gem());

        uint256 preThisDaiBalance = dai.balanceOf(address(this));
        uint256 preThisDropBalance = drop.balanceOf(address(this));
        uint256 preThisGemBalance = gem.balanceOf(address(this));

        uint256 daiToPay = 100 * WAD;
        uint256 dropToExit = 100 * WAD;
        uint256 gemToFree = 1 * WAD / 10**3; // 0.001 RWA

        mgr.wipe(daiToPay);
        mgr.exit(dropToExit);
        mgr.free(gemToFree);

        assertEq(
            dai.balanceOf(address(this)),
            preThisDaiBalance - daiToPay,
            "Post-condition: invalid Dai balance on address(this)"
        );
        assertEq(
            drop.balanceOf(address(this)),
            preThisDropBalance + dropToExit,
            "Post-condition: invalid DROP balance on address(this)"
        );
        assertEq(
            gem.balanceOf(address(mgr)),
            preThisGemBalance + gemToFree,
            "Post-condition: invalid Gem balance on mgr"
        );
    }

    function testFail_DRAW_ABOVE_LINE() public {
        _setupCentrifugeCollaterals();

        // A better way to write this would be to leverage Foundry vm.expectRevert,
        // however since we are still using DappTools compatibility mode, we need a way
        // to assert agains multiple reversions.
        uint256 failCount = 0;
        for (uint256 i = 0; i < collaterals.length; i++) {
            try this._testFailDrawAboveLine(collaterals[i]) {
                emit log_named_string("Able to draw above line", collaterals[i].ilkString);
            } catch {
                failCount++;
            }
        }

        if (failCount == collaterals.length) {
            revert("Draw above line");
        }
    }

    // Needs to be external to be able to use try...catch above.
    function _testFailDrawAboveLine(CentrifugeCollateralTestValues memory collateral) external {
        emit log_named_string("Test tinlake draw above line", collateral.ilkString);

        TinlakeManagerLike mgr = TinlakeManagerLike(collateral.MGR);

        uint256 drawAmount = collateral.CEIL + 100_000_000;

        mgr.join(DROP_JOIN_AMOUNT);
        mgr.draw(drawAmount);
    }

    function test_TINLAKE_MGR_LOCK_DRAW_CAGE() public {
        _setupCentrifugeCollaterals();

        for (uint256 i = 0; i < collaterals.length; i++) {
            _testTinlakeMgrJoinDraw(collaterals[i]);
        }

        // Accrue some stability fees
        hevm.warp(block.timestamp + 10 days);
        for (uint256 i = 0; i < collaterals.length; i++) {
            jug.drip(collaterals[i].ilk);
        }

        // END
        giveAuth(address(end), address(this));
        end.cage();
        hevm.warp(block.timestamp + end.wait());

        for (uint256 i = 0; i < collaterals.length; i++) {
            _testTinlakeMgrCageSkim(collaterals[i]);
        }

        vow.heal(min(vat.dai(address(vow)), sub(sub(vat.sin(address(vow)), vow.Sin()), vow.Ash())));

        // Removing the surplus to allow continuing the execution.
        hevm.store(
            address(vat),
            keccak256(abi.encode(address(vow), uint256(5))),
            bytes32(uint256(0))
        );

        end.thaw();

        for (uint256 i = 0; i < collaterals.length; i++) {
            _testTinlakeMgrPostCageFlow(collaterals[i]);
        }
    }

    function _testTinlakeMgrCageSkim(CentrifugeCollateralTestValues memory collateral) internal {
        emit log_named_string("Test tinlake post-cage skim", collateral.ilkString);

        end.cage(collateral.ilk);
        end.skim(collateral.ilk, collateral.URN);

        (uint256 ink, uint256 art) = vat.urns(collateral.ilk, collateral.URN);
        uint256 skimmedInk = DAI_DRAW_AMOUNT * WAD / collateral.PRICE;
        uint256 remainingInk = 1 * WAD - skimmedInk;
        // Cope with rounding errors
        assertLt(remainingInk - ink, 10**16, "wrong ink in urn after skim");
        assertEq(art, 0, "wrong art in urn after skim");
    }

    function _testTinlakeMgrPostCageFlow(CentrifugeCollateralTestValues memory collateral) internal {
        GemJoinAbstract gemJoin = GemJoinAbstract(collateral.GEM_JOIN);
        GemAbstract gem = GemAbstract(gemJoin.gem());

        end.flow(collateral.ilk);

        giveTokens(address(dai), 1_000_000 * WAD);
        dai.approve(address(daiJoin), 1_000_000 * WAD);
        daiJoin.join(address(this), 1_000_000 * WAD);

        vat.hope(address(end));
        end.pack(1_000_000 * WAD);

        // Check DAI redemption after "cage()"
        assertEq(vat.gem(collateral.ilk, address(this)), 0, "wrong vat gem");
        assertEq(gem.balanceOf(address(this)), 0, "wrong gem balance");
        end.cash(collateral.ilk, 1_000_000 * WAD);
        assertGt(vat.gem(collateral.ilk, address(this)), 0, "wrong vat gem after cash");
        assertEq(gem.balanceOf(address(this)), 0, "wrong gem balance after cash");
        gemJoin.exit(address(this), vat.gem(collateral.ilk, address(this)));
        assertEq(vat.gem(collateral.ilk, address(this)), 0, "wrong vat gem after exit");
        assertGt(gem.balanceOf(address(this)), 0, "wrong gem balance after exit");
    }
}
