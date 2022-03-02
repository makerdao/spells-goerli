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

interface DSProxyAbstract {
    function owner() external returns (address owner);
    function execute(address _target, bytes memory _data) external returns (bytes memory response);
}

interface CharterAbstract {
    function getOrCreateProxy(address usr) external returns (address urp);
    function join(address gemJoin, address usr, uint256 amt) external;
    function frob(bytes32 ilk, address u, address v, address w, int256 dink, int256 dart) external;
    function file(bytes32 ilk, address usr, bytes32 what, uint256 data) external;
    function deny(address usr) external;
    function exit(address gemJoin, address usr, uint256 amt) external;
}

contract DssSpellTest is GoerliDssSpellTestBase {

    CharterAbstract charter = CharterAbstract(addr.addr("MCD_CHARTER"));

    address dssProxyActions    = addr.addr("PROXY_ACTIONS_CHARTER");
    address dssProxyActionsEnd = addr.addr("PROXY_ACTIONS_END_CHARTER");

    DSProxyAbstract oazoProxy = DSProxyAbstract(0xDdA54E31B7586153D72A2AC1bAFaC5B9C21fc45C);

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

    function setUline(bytes32 _ilk) public {
        giveAuth(address(charter), address(this));
        (,,, uint256 line,) = vat.ilks(_ilk);
        charter.file(_ilk, address(this), "uline", line);
        charter.deny(address(this));
    }

    function checkCharterIlkIntegration(
        bytes32 _ilk,
        GemJoinManagedAbstract join,
        ClipAbstract clip,
        address pip,
        bool _isOSM,
        bool _checkLiquidations,
        bool _transferFee
    ) public {
        DSTokenAbstract token = DSTokenAbstract(join.gem());
        address proxy = charter.getOrCreateProxy(address(this));

        setUline(_ilk);

        hevm.warp(block.timestamp + 3601); // Avoid OSM delay errors on Görli
        if (_isOSM) OsmAbstract(pip).poke();
        hevm.warp(block.timestamp + 3601);
        if (_isOSM) OsmAbstract(pip).poke();
        spotter.poke(_ilk);

        // Authorization
        assertEq(join.wards(pauseProxy), 1);
        assertEq(vat.wards(address(join)), 1);
        assertEq(clip.wards(address(end)), 1);
        assertEq(clip.wards(address(clipMom)), 1);
        if (_isOSM) {
            assertEq(OsmAbstract(pip).wards(address(osmMom)), 1);
            assertEq(OsmAbstract(pip).bud(address(spotter)), 1);
            assertEq(OsmAbstract(pip).bud(address(clip)), 1);
            assertEq(OsmAbstract(pip).bud(address(clipMom)), 1);
            assertEq(OsmAbstract(pip).bud(address(end)), 1);
            assertEq(MedianAbstract(OsmAbstract(pip).src()).bud(pip), 1);
            assertEq(OsmMomAbstract(osmMom).osms(_ilk), pip);
        }

        (,,,, uint256 dust) = vat.ilks(_ilk);
        dust /= RAY;
        uint256 amount = 2 * dust * 10**token.decimals() / (_isOSM ? getOSMPrice(pip) : uint256(DSValueAbstract(pip).read()));
        uint256 amount18 = token.decimals() == 18 ? amount : amount * 10**(18 - token.decimals());
        giveTokens(token, amount);

        assertEq(token.balanceOf(address(this)), amount);
        assertEq(vat.gem(_ilk, address(this)), 0);

        // Each account that interacts with Charter needs to approve it in the vat
        vat.hope(address(charter));

        token.approve(address(charter), amount);
        charter.join(address(join), address(this), amount);
        assertEq(token.balanceOf(address(this)), 0);
        if (_transferFee) {
            amount = vat.gem(_ilk, address(this));
            assertTrue(amount > 0);
        }
        assertEq(vat.gem(_ilk, proxy), amount18);

        // Tick the fees forward so that art != dai in wad units
        hevm.warp(block.timestamp + 1);
        jug.drip(_ilk);

        // Deposit collateral, generate DAI
        (,uint256 rate,,,) = vat.ilks(_ilk);
        assertEq(vat.dai(address(this)), 0);
        charter.frob(_ilk, address(this), address(this), address(this), int256(amount18), int256(divup(mul(RAY, dust), rate)));
        assertEq(vat.gem(_ilk, proxy), 0);
        assertTrue(vat.dai(address(this)) >= dust * RAY);
        assertTrue(vat.dai(address(this)) <= (dust + 1) * RAY);

        // Payback DAI, withdraw collateral
        charter.frob(_ilk, address(this), address(this), address(this), -int256(amount18), -int256(divup(mul(RAY, dust), rate)));
        assertEq(vat.gem(_ilk, proxy), amount18);
        assertEq(vat.dai(address(this)), 0);

        // Withdraw from adapter
        charter.exit(address(join), address(this), amount);
        if (_transferFee) {
            amount = token.balanceOf(address(this));
        }
        assertEq(token.balanceOf(address(this)), amount);
        assertEq(vat.gem(_ilk, proxy), 0);

        // Generate new DAI to force a liquidation
        token.approve(address(charter), amount);
        charter.join(address(join), address(this), amount);
        if (_transferFee) {
            amount = vat.gem(_ilk, address(this));
        }
        // dart max amount of DAI
        (,,uint256 spot,,) = vat.ilks(_ilk);
        charter.frob(_ilk, address(this), address(this), address(this), int256(amount18), int256(mul(amount18, spot) / rate));
        hevm.warp(block.timestamp + 1);
        jug.drip(_ilk);
        assertEq(clip.kicks(), 0);
        if (_checkLiquidations) {
            dog.bark(_ilk, proxy, address(this));
            assertEq(clip.kicks(), 1);
        }

        // Dump all dai for next run
        vat.move(address(this), address(0x0), vat.dai(address(this)));
    }

    function testCollateralIntegrations() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Insert new collateral tests here
        checkCharterIlkIntegration(
            "INST-ETH-A",
            GemJoinManagedAbstract(addr.addr("MCD_JOIN_INST_ETH_A")),
            ClipAbstract(addr.addr("MCD_CLIP_INST_ETH_A")),
            addr.addr("PIP_ETH"),
            true,
            true,
            false
        );

        checkCharterIlkIntegration(
            "INST-WBTC-A",
            GemJoinManagedAbstract(addr.addr("MCD_JOIN_INST_WBTC_A")),
            ClipAbstract(addr.addr("MCD_CLIP_INST_WBTC_A")),
            addr.addr("PIP_WBTC"),
            true,
            true,
            false
        );

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
    }

    function open(bytes32, address) public returns (uint256 cdp) {
        bytes memory response = oazoProxy.execute(dssProxyActions, msg.data);
        assembly {
            cdp := mload(add(response, 0x20))
        }
    }

    function lockGem(address, uint256, uint256) public {
        oazoProxy.execute(dssProxyActions, msg.data);
    }

    function draw(address, address, uint256, uint256) public {
        oazoProxy.execute(dssProxyActions, msg.data);
    }

    function takeDsProxy(address dsProxy, address target) internal {
        hevm.store(address(dsProxy), bytes32(uint256(1)), bytes32(uint256(uint160(target))));
        assertEq(DSProxyAbstract(dsProxy).owner(), target);
    }

    function checkCharterVault(
        bytes32 _ilk,
        GemJoinManagedAbstract join
    ) public {

        DSTokenAbstract token = DSTokenAbstract(join.gem());
        uint256 amount = 100 * THOUSAND * 10 ** token.decimals();
        giveTokens(token, amount);

        takeDsProxy(address(oazoProxy), address(this));
        uint256 cdp = this.open(_ilk, address(oazoProxy));

        token.approve(address(oazoProxy), amount);
        this.lockGem(address(join), cdp, amount);

        uint256 vowDaiBefore = vat.dai(address(vow));
        this.draw(address(jug), address(daiJoin), cdp, 100_000 ether);
        assertEq(dai.balanceOf(address(this)), 100_000 ether);

        uint256 expectedFee = 1010101010101010101010110000000000000000000000000; // (100_000 / 0.99) * 0.01 * 10^45
        assertEqApprox(vat.dai(address(vow)) - vowDaiBefore, expectedFee, RAY);

        // Dump all dai for next run
        dai.transfer(address(0x0), 100_000 ether);
    }

    function testCharterVaults() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        checkCharterVault("INST-ETH-A",  GemJoinManagedAbstract(addr.addr("MCD_JOIN_INST_ETH_A")));
        checkCharterVault("INST-WBTC-A", GemJoinManagedAbstract(addr.addr("MCD_JOIN_INST_WBTC_A")));
    }

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

    // As Charter is a sneak deployment its contracts are not added to the Chainlog, and therefore checked explicitly.
    function test_wards_charter()  public {
        checkWards(addr.addr("MCD_CHARTER"), "MCD_CHARTER");
        checkWards(addr.addr("PROXY_ACTIONS_CHARTER"), "PROXY_ACTIONS_CHARTER");
        checkWards(addr.addr("PROXY_ACTIONS_END_CHARTER"), "PROXY_ACTIONS_END_CHARTER");
        checkWards(addr.addr("MCD_JOIN_INST_ETH_A"), "MCD_JOIN_INST_ETH_A");
        checkWards(addr.addr("MCD_CLIP_INST_ETH_A"), "MCD_CLIP_INST_ETH_A");
        checkWards(addr.addr("MCD_CLIP_CALC_INST_ETH_A"), "MCD_CLIP_CALC_INST_ETH_A");
        checkWards(addr.addr("MCD_JOIN_INST_WBTC_A"), "MCD_JOIN_INST_WBTC_A");
        checkWards(addr.addr("MCD_CLIP_INST_WBTC_A"), "MCD_CLIP_INST_WBTC_A");
        checkWards(addr.addr("MCD_CLIP_CALC_INST_WBTC_A"), "MCD_CLIP_CALC_INST_WBTC_A");
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
