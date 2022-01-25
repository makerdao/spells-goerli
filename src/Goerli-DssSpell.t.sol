// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Copyright (C) 2021-2022 Dai Foundation
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

contract DssSpellTest is GoerliDssSpellTestBase {

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

    // function testCollateralIntegrations() public {
    //     vote(address(spell));
    //     scheduleWaitAndCast(address(spell));
    //     assertTrue(spell.done());

    //     // Insert new collateral tests here

    //     checkUNILPIntegration(
    //         "GUNIV3DAIUSDC2-A",
    //         GemJoinAbstract(addr.addr("MCD_JOIN_GUNIV3DAIUSDC2_A")),
    //         ClipAbstract(addr.addr("MCD_CLIP_GUNIV3DAIUSDC2_A")),
    //         LPOsmAbstract(addr.addr("PIP_GUNIV3DAIUSDC2")),
    //         addr.addr("PIP_DAI"),
    //         addr.addr("PIP_USDC"),
    //         false,
    //         false,
    //         false
    //     );
    // }

    // function testLerpSurplusBuffer() public {
    //     vote(address(spell));
    //     scheduleWaitAndCast(address(spell));
    //     assertTrue(spell.done());

    //     LerpAbstract lerp = LerpAbstract(lerpFactory.lerps("Increase SB - 20211126"));

    //     uint256 duration = 210 days;
    //     hevm.warp(block.timestamp + duration / 2);
    //     assertEq(vow.hump(), 60 * MILLION * RAD);
    //     lerp.tick();
    //     assertEq(vow.hump(), 75 * MILLION * RAD);
    //     hevm.warp(block.timestamp + duration / 2);
    //     lerp.tick();
    //     assertEq(vow.hump(), 90 * MILLION * RAD);
    //     assertTrue(lerp.done());
    // }


    // function testNewChainlogValues() public {
    //     vote(address(spell));
    //     scheduleWaitAndCast(address(spell));
    //     assertTrue(spell.done());

    //     // Insert new chainlog values tests here
    //     assertEq(chainLog.getAddress("GUNIV3DAIUSDC2"), addr.addr("GUNIV3DAIUSDC2"));
    //     assertEq(chainLog.getAddress("MCD_JOIN_GUNIV3DAIUSDC2_A"), addr.addr("MCD_JOIN_GUNIV3DAIUSDC2_A"));
    //     assertEq(chainLog.getAddress("MCD_CLIP_GUNIV3DAIUSDC2_A"), addr.addr("MCD_CLIP_GUNIV3DAIUSDC2_A"));
    //     assertEq(chainLog.getAddress("MCD_CLIP_CALC_GUNIV3DAIUSDC2_A"), addr.addr("MCD_CLIP_CALC_GUNIV3DAIUSDC2_A"));
    //     assertEq(chainLog.getAddress("PIP_GUNIV3DAIUSDC2"), addr.addr("PIP_GUNIV3DAIUSDC2"));

    //     assertEq(chainLog.version(), "1.9.12");

    // }

    // function testNewIlkRegistryValues() public {
    //     vote(address(spell));
    //     scheduleWaitAndCast(address(spell));
    //     assertTrue(spell.done());

    //     // Insert new ilk registry values tests here
    //     assertEq(reg.pos("GUNIV3DAIUSDC2-A"), 46);
    //     assertEq(reg.join("GUNIV3DAIUSDC2-A"), addr.addr("MCD_JOIN_GUNIV3DAIUSDC2_A"));
    //     assertEq(reg.gem("GUNIV3DAIUSDC2-A"), addr.addr("GUNIV3DAIUSDC2"));
    //     assertEq(reg.dec("GUNIV3DAIUSDC2-A"), DSTokenAbstract(addr.addr("GUNIV3DAIUSDC2")).decimals());
    //     assertEq(reg.class("GUNIV3DAIUSDC2-A"), 1);
    //     assertEq(reg.pip("GUNIV3DAIUSDC2-A"), addr.addr("PIP_GUNIV3DAIUSDC2"));
    //     assertEq(reg.xlip("GUNIV3DAIUSDC2-A"), addr.addr("MCD_CLIP_GUNIV3DAIUSDC2_A"));
    //     assertEq(reg.name("GUNIV3DAIUSDC2-A"), "Gelato Uniswap DAI/USDC LP");
    //     assertEq(reg.symbol("GUNIV3DAIUSDC2-A"), "G-UNI");
    // }


    // function testOneTimePaymentDistributions() public {
    //     uint256 prevSin              = vat.sin(address(vow));
    //     uint256 prevDaiCom           = dai.balanceOf(COM_WALLET);
    //     uint256 prevDaiFlipFlop      = dai.balanceOf(FLIPFLOPFLAP_WALLET);
    //     uint256 prevDaiFeedblack     = dai.balanceOf(FEEDBLACKLOOPS_WALLET);
    //     uint256 prevDaiUltra         = dai.balanceOf(ULTRASCHUPPI_WALLET);
    //     uint256 prevDaiField         = dai.balanceOf(FIELDTECHNOLOGIES_WALLET);

    //     uint256 amountCom       = 27_058;
    //     uint256 amountFlipFlop  = 12_000;
    //     uint256 amountFeedblack = 12_000;
    //     uint256 amountUltra     = 8144;
    //     uint256 amountField     = 3690;

    //     uint256 amountTotal     = amountCom + amountFlipFlop + amountFeedblack
    //                             + amountUltra + amountField;

    //     assertEq(vat.can(address(pauseProxy), address(daiJoin)), 1);

    //     vote(address(spell));
    //     spell.schedule();
    //     hevm.warp(spell.nextCastTime());
    //     spell.cast();
    //     assertTrue(spell.done());

    //     assertEq(vat.can(address(pauseProxy), address(daiJoin)), 1);

    //     assertEq(vat.sin(address(vow)) - prevSin, amountTotal * RAD);
    //     assertEq(dai.balanceOf(COM_WALLET) - prevDaiCom, amountCom * WAD);
    //     assertEq(dai.balanceOf(FLIPFLOPFLAP_WALLET) - prevDaiFlipFlop, amountFlipFlop * WAD);
    //     assertEq(dai.balanceOf(FEEDBLACKLOOPS_WALLET) - prevDaiFeedblack, amountFeedblack * WAD);
    //     assertEq(dai.balanceOf(ULTRASCHUPPI_WALLET) - prevDaiUltra, amountUltra * WAD);
    //     assertEq(dai.balanceOf(FIELDTECHNOLOGIES_WALLET) - prevDaiField, amountField * WAD);
    // }

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

    // function test_OSMs() public {
    //     vote(address(spell));
    //     spell.schedule();
    //     hevm.warp(spell.nextCastTime());
    //     spell.cast();
    //     assertTrue(spell.done());

    //     // Track OSM authorizations here

    //     address YEARN_PROXY = 0x208EfCD7aad0b5DD49438E0b6A0f38E951A50E5f;
    //     assertEq(OsmAbstract(addr.addr("PIP_YFI")).bud(YEARN_PROXY), 1);

    //     // Gnosis
    //     address GNOSIS = 0xD5885fbCb9a8a8244746010a3BC6F1C6e0269777;
    //     assertEq(OsmAbstract(addr.addr("PIP_WBTC")).bud(GNOSIS), 1);
    //     assertEq(OsmAbstract(addr.addr("PIP_LINK")).bud(GNOSIS), 1);
    //     assertEq(OsmAbstract(addr.addr("PIP_COMP")).bud(GNOSIS), 1);
    //     assertEq(OsmAbstract(addr.addr("PIP_YFI")).bud(GNOSIS), 1);
    //     assertEq(OsmAbstract(addr.addr("PIP_ZRX")).bud(GNOSIS), 1);

    //     // Instadapp
    //     address INSTADAPP = 0xDF3CDd10e646e4155723a3bC5b1191741DD90333;
    //     assertEq(OsmAbstract(addr.addr("PIP_ETH")).bud(INSTADAPP), 1);
    // }

    // function test_Medianizers() public {
    //     vote(address(spell));
    //     spell.schedule();
    //     hevm.warp(spell.nextCastTime());
    //     spell.cast();
    //     assertTrue(spell.done());

    //     // Track Median authorizations here

    //     address SET_AAVE    = 0x8b1C079f8192706532cC0Bf0C02dcC4fF40d045D;
    //     address AAVEUSD_MED = OsmAbstract(addr.addr("PIP_AAVE")).src();
    //     assertEq(MedianAbstract(AAVEUSD_MED).bud(SET_AAVE), 1);

    //     address SET_LRC     = 0x1D5d9a2DDa0843eD9D8a9Bddc33F1fca9f9C64a0;
    //     address LRCUSD_MED  = OsmAbstract(addr.addr("PIP_LRC")).src();
    //     assertEq(MedianAbstract(LRCUSD_MED).bud(SET_LRC), 1);

    //     address SET_YFI     = 0x1686d01Bd776a1C2A3cCF1579647cA6D39dd2465;
    //     address YFIUSD_MED  = OsmAbstract(addr.addr("PIP_YFI")).src();
    //     assertEq(MedianAbstract(YFIUSD_MED).bud(SET_YFI), 1);

    //     address SET_ZRX     = 0xFF60D1650696238F81BE53D23b3F91bfAAad938f;
    //     address ZRXUSD_MED  = OsmAbstract(addr.addr("PIP_ZRX")).src();
    //     assertEq(MedianAbstract(ZRXUSD_MED).bud(SET_ZRX), 1);

    //     address SET_UNI     = 0x3c3Afa479d8C95CF0E1dF70449Bb5A14A3b7Af67;
    //     address UNIUSD_MED  = OsmAbstract(addr.addr("PIP_UNI")).src();
    //     assertEq(MedianAbstract(UNIUSD_MED).bud(SET_UNI), 1);
    // }

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
}
