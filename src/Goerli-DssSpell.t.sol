// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.6.12;

import "dss-interfaces/Interfaces.sol";
import {DssSpellTest} from "./test/DssSpellTest.sol";

contract SpellTest is DssSpellTest {

   function setUp() public {
        //
        // Test for spell-specific parameters
        //
        spellValues = SpellValues({
            deployed_spell:                 0x233C6E1E219c39F97069f3a12Ce0c4d70eD7F441,        // populate with deployed spell if deployed
            deployed_spell_created:         1631820195,        // use get-created-timestamp.sh if deployed
            previous_spell:                 address(0), // supply if there is a need to test prior to its cast() function being called on-chain.
            office_hours_enabled:           false,              // true if officehours is expected to be enabled in the spell
            expiration_threshold:           weekly_expiration  // (weekly_expiration,monthly_expiration) if weekly or monthly spell
        });
        testSetUp();
    }

    function testCollateralIntegrations() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Insert new collateral tests here
        checkUNILPIntegration(
            "GUNIV3DAIUSDC1-A",
            GemJoinAbstract(addr.addr("MCD_JOIN_GUNIV3DAIUSDC1_A")),
            ClipAbstract(addr.addr("MCD_CLIP_GUNIV3DAIUSDC1_A")),
            LPOsmAbstract(addr.addr("PIP_GUNIV3DAIUSDC1")),
            0xe7A915f8Db97f0dE219e0cEf60fF7886305a14ef,     // PIP_DAI
            addr.addr("PIP_USDC"),
            false,
            false,
            false
        );
    }

    function testNewChainlogValues() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        ChainlogAbstract chainLog = ChainlogAbstract(addr.addr("CHANGELOG"));
        assertEq(chainLog.getAddress("LERP_FAB"), addr.addr("LERP_FAB"));
        assertEq(chainLog.getAddress("GUNIV3DAIUSDC1"), addr.addr("GUNIV3DAIUSDC1"));
        assertEq(chainLog.getAddress("PIP_GUNIV3DAIUSDC1"), addr.addr("PIP_GUNIV3DAIUSDC1"));
        assertEq(chainLog.getAddress("MCD_JOIN_GUNIV3DAIUSDC1_A"), addr.addr("MCD_JOIN_GUNIV3DAIUSDC1_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_GUNIV3DAIUSDC1_A"), addr.addr("MCD_CLIP_GUNIV3DAIUSDC1_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_GUNIV3DAIUSDC1_A"), addr.addr("MCD_CLIP_CALC_GUNIV3DAIUSDC1_A"));
    }

    function testNewIlkRegistryValues() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        IlkRegistryAbstract ilkRegistry = IlkRegistryAbstract(addr.addr("ILK_REGISTRY"));

        assertEq(ilkRegistry.join("GUNIV3DAIUSDC1-A"), addr.addr("MCD_JOIN_GUNIV3DAIUSDC1_A"));
        assertEq(ilkRegistry.gem("GUNIV3DAIUSDC1-A"), addr.addr("GUNIV3DAIUSDC1"));
        assertEq(ilkRegistry.dec("GUNIV3DAIUSDC1-A"), DSTokenAbstract(addr.addr("GUNIV3DAIUSDC1")).decimals());
        assertEq(ilkRegistry.class("GUNIV3DAIUSDC1-A"), 1);
        assertEq(ilkRegistry.pip("GUNIV3DAIUSDC1-A"), addr.addr("PIP_GUNIV3DAIUSDC1"));
        assertEq(ilkRegistry.xlip("GUNIV3DAIUSDC1-A"), addr.addr("MCD_CLIP_GUNIV3DAIUSDC1_A"));
        assertEq(ilkRegistry.name("GUNIV3DAIUSDC1-A"), "Gelato Uniswap DAI/USDC LP");
        assertEq(ilkRegistry.symbol("GUNIV3DAIUSDC1-A"), "G-UNI");
    }

    function getKNCMat() internal returns (uint256 mat) {
        (, mat) = spotter.ilks("KNC-A");
    }

    function testKNCOffboarding() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        LerpAbstract lerp = LerpAbstract(lerpFactory.lerps("KNC Offboarding"));

        hevm.warp(block.timestamp + 30 days);
        assertEq(getKNCMat(), 175 * RAY / 100);
        lerp.tick();
        assertGt(getKNCMat(), 2000 * RAY / 100);
        assertLt(getKNCMat(), 3000 * RAY / 100);

        hevm.warp(block.timestamp + 60 days);
        lerp.tick();
        assertEq(getKNCMat(), 5000 * RAY / 100);
    }
}
