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

pragma solidity 0.8.16;

import "./DssSpell.t.base.sol";
import {ScriptTools, StdStorage, stdStorage} from "dss-test/DssTest.sol";

import {RootDomain} from "dss-test/domains/RootDomain.sol";
import {OptimismDomain} from "dss-test/domains/OptimismDomain.sol";
import {ArbitrumDomain} from "dss-test/domains/ArbitrumDomain.sol";

interface L2Spell {
    function dstDomain() external returns (bytes32);
    function gateway() external returns (address);
}

interface L2Gateway {
    function validDomains(bytes32) external returns (uint256);
}

interface BridgeLike {
    function l2TeleportGateway() external view returns (address);
}

interface RwaUrnLike {
    function outputConduit() external view returns (address);
    function can(address) external view returns (uint256);
    function draw(uint256) external;
}

interface RwaOutputConduitLike {
    function wards(address) external view returns (uint256);
    function can(address) external view returns (uint256);
    function may(address) external view returns (uint256);
    function pal(address) external view returns (uint256);
    function bud(address) external view returns (uint256);
    function dai() external view returns (address);
    function gem() external view returns (address);
    function mate(address) external;
    function hope(address) external;
    function kiss(address) external;
    function hook(address) external;
    function quitTo() external view returns (address);
    function pick(address) external;
    function push(uint256) external;
    function quit() external;
}

contract DssSpellTest is DssSpellTestBase {
    using stdStorage for StdStorage;

    string         config;
    RootDomain     rootDomain;
    OptimismDomain optimismDomain;
    ArbitrumDomain arbitrumDomain;

    // DO NOT TOUCH THE FOLLOWING TESTS, THEY SHOULD BE RUN ON EVERY SPELL
    function testGeneral() public {
        _testGeneral();
    }

    function testFailWrongDay() public {
        _testFailWrongDay();
    }

    function testFailTooEarly() public {
        _testFailTooEarly();
    }

    function testFailTooLate() public {
        _testFailTooLate();
    }

    function testOnTime() public {
        _testOnTime();
    }

    function testCastCost() public {
        _testCastCost();
    }

    function testDeployCost() public {
        _testDeployCost();
    }

    function testContractSize() public {
        _testContractSize();
    }

    function testNextCastTime() public {
        _testNextCastTime();
    }

    function testFailNotScheduled() public view {
        _testFailNotScheduled();
    }

    function testUseEta() public {
        _testUseEta();
    }

    function testAuth() public {
        _checkAuth(false);
    }

    function testAuthInSources() public {
        _checkAuth(true);
    }

    function testBytecodeMatches() public {
        _testBytecodeMatches();
    }

    function testChainlogValues() public {
        _testChainlogValues();
    }

    function testChainlogVersionBump() public {
        _testChainlogVersionBump();
    }
    // END OF TESTS THAT SHOULD BE RUN ON EVERY SPELL

    function testOsmAuth() private {  // make private to disable
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

        //_vote(address(spell));
        //_scheduleWaitAndCast(address(spell));
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

    function testOracleList() private {  // make private to disable
        // address ORACLE_WALLET01 = 0x4D6fbF888c374D7964D56144dE0C0cFBd49750D3;

        //assertEq(OsmAbstract(0xF15993A5C5BE496b8e1c9657Fd2233b579Cd3Bc6).wards(ORACLE_WALLET01), 0);

        //_vote(address(spell));
        //_scheduleWaitAndCast(address(spell));
        //assertTrue(spell.done());

        //assertEq(OsmAbstract(0xF15993A5C5BE496b8e1c9657Fd2233b579Cd3Bc6).wards(ORACLE_WALLET01), 1);
    }

    // NOTE: not for goerli
    function testRemoveChainlogValues() private { // make private to disable
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // try chainLog.getAddress("RWA015_A_OUTPUT_CONDUIT_LEGACY") {
        //     assertTrue(false);
        // } catch Error(string memory errmsg) {
        //     assertTrue(cmpStr(errmsg, "dss-chain-log/invalid-key"));
        // } catch {
        //     assertTrue(false);
        // }
    }

    function testCollateralIntegrations() private { // make public to enable
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Insert new collateral tests here
        _checkIlkIntegration(
            "GNO-A",
            GemJoinAbstract(addr.addr("MCD_JOIN_GNO_A")),
            ClipAbstract(addr.addr("MCD_CLIP_GNO_A")),
            addr.addr("PIP_GNO"),
            true, /* _isOSM */
            true, /* _checkLiquidations */
            false /* _transferFee */
        );
    }

    function testIlkClipper() private { // make public to enable
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // _checkIlkClipper(
        //     "LINK-A",
        //     GemJoinAbstract(addr.addr("MCD_JOIN_LINK_A")),
        //     ClipAbstract(addr.addr("MCD_CLIP_LINK_A")),
        //     addr.addr("MCD_CLIP_CALC_LINK_A"),
        //     OsmAbstract(addr.addr("PIP_LINK")),
        //     1_000_000 * WAD
        // );

        // _checkIlkClipper(
        //     "MATIC-A",
        //     GemJoinAbstract(addr.addr("MCD_JOIN_MATIC_A")),
        //     ClipAbstract(addr.addr("MCD_CLIP_MATIC_A")),
        //     addr.addr("MCD_CLIP_CALC_MATIC_A"),
        //     OsmAbstract(addr.addr("PIP_MATIC")),
        //     10_000_000 * WAD
        // );

        // _checkIlkClipper(
        //     "YFI-A",
        //     GemJoinAbstract(addr.addr("MCD_JOIN_YFI_A")),
        //     ClipAbstract(addr.addr("MCD_CLIP_YFI_A")),
        //     addr.addr("MCD_CLIP_CALC_YFI_A"),
        //     OsmAbstract(addr.addr("PIP_YFI")),
        //     1_000 * WAD
        // );

        // _checkIlkClipper(
        //     "UNIV2USDCETH-A",
        //     GemJoinAbstract(addr.addr("MCD_JOIN_UNIV2USDCETH_A")),
        //     ClipAbstract(addr.addr("MCD_CLIP_UNIV2USDCETH_A")),
        //     addr.addr("MCD_CLIP_CALC_UNIV2USDCETH_A"),
        //     OsmAbstract(addr.addr("PIP_UNIV2USDCETH")),
        //     1 * WAD
        // );
    }

    function testLerpSurplusBuffer() private { // make private to disable
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Insert new SB lerp tests here

        LerpAbstract lerp = LerpAbstract(lerpFactory.lerps("NAME"));

        uint256 duration = 210 days;
        vm.warp(block.timestamp + duration / 2);
        assertEq(vow.hump(), 60 * MILLION * RAD);
        lerp.tick();
        assertEq(vow.hump(), 75 * MILLION * RAD);
        vm.warp(block.timestamp + duration / 2);
        lerp.tick();
        assertEq(vow.hump(), 90 * MILLION * RAD);
        assertTrue(lerp.done());
    }

    function testNewChainlogValues() public { // make private to disable
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        _checkChainlogKey("PIP_MKR");
        _checkChainlogKey("MCD_FLAP");
        _checkChainlogKey("FLAPPER_MOM");

        _checkChainlogKey("RWA015_A_OUTPUT_CONDUIT");

        _checkChainlogVersion("1.15.0");
    }

    function testNewIlkRegistryValues() private { // make private to disable
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Insert new ilk registry values tests here
        // RWA015
        // (, address pipRwa015,,) = oracle.ilks("RWA015-A");

        // assertEq(reg.pos("RWA015-A"),    62);
        // assertEq(reg.join("RWA015-A"),   addr.addr("MCD_JOIN_RWA015_A"));
        // assertEq(reg.gem("RWA015-A"),    addr.addr("RWA015"));
        // assertEq(reg.dec("RWA015-A"),    GemAbstract(addr.addr("RWA015")).decimals());
        // assertEq(reg.class("RWA015-A"),  3);
        // assertEq(reg.pip("RWA015-A"),    pipRwa015);
        // assertEq(reg.name("RWA015-A"),   "RWA015-A: BlockTower Andromeda");
        // assertEq(reg.symbol("RWA015-A"), GemAbstract(addr.addr("RWA015")).symbol());
    }

    function testOSMs() private { // make private to disable
        address READER = address(0);

        // Track OSM authorizations here
        assertEq(OsmAbstract(addr.addr("PIP_TOKEN")).bud(READER), 0);

        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        assertEq(OsmAbstract(addr.addr("PIP_TOKEN")).bud(READER), 1);
    }

    function testMedianizers() private { // make private to disable
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Track Median authorizations here
        address SET_TOKEN    = address(0);
        address TOKENUSD_MED = OsmAbstract(addr.addr("PIP_TOKEN")).src();
        assertEq(MedianAbstract(TOKENUSD_MED).bud(SET_TOKEN), 1);
    }

    // Leave this test public (for now) as this is acting like a config test
    function testPSMs() public {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        bytes32 _ilk;

        // USDC
        _ilk = "PSM-USDC-A";
        assertEq(addr.addr("MCD_JOIN_PSM_USDC_A"), reg.join(_ilk));
        assertEq(addr.addr("MCD_CLIP_PSM_USDC_A"), reg.xlip(_ilk));
        assertEq(addr.addr("PIP_USDC"), reg.pip(_ilk));
        assertEq(addr.addr("MCD_PSM_USDC_A"), chainLog.getAddress("MCD_PSM_USDC_A"));
        _checkPsmIlkIntegration(
            _ilk,
            GemJoinAbstract(addr.addr("MCD_JOIN_PSM_USDC_A")),
            ClipAbstract(addr.addr("MCD_CLIP_PSM_USDC_A")),
            addr.addr("PIP_USDC"),
            PsmAbstract(addr.addr("MCD_PSM_USDC_A")),
            0,   // tin
            0    // tout
        );

        // GUSD
        _ilk = "PSM-GUSD-A";
        assertEq(addr.addr("MCD_JOIN_PSM_GUSD_A"), reg.join(_ilk));
        assertEq(addr.addr("MCD_CLIP_PSM_GUSD_A"), reg.xlip(_ilk));
        assertEq(addr.addr("PIP_GUSD"), reg.pip(_ilk));
        assertEq(addr.addr("MCD_PSM_GUSD_A"), chainLog.getAddress("MCD_PSM_GUSD_A"));
        _checkPsmIlkIntegration(
            _ilk,
            GemJoinAbstract(addr.addr("MCD_JOIN_PSM_GUSD_A")),
            ClipAbstract(addr.addr("MCD_CLIP_PSM_GUSD_A")),
            addr.addr("PIP_GUSD"),
            PsmAbstract(addr.addr("MCD_PSM_GUSD_A")),
            0,   // tin
            0    // tout
        );

        // USDP
        _ilk = "PSM-PAX-A";
        assertEq(addr.addr("MCD_JOIN_PSM_PAX_A"), reg.join(_ilk));
        assertEq(addr.addr("MCD_CLIP_PSM_PAX_A"), reg.xlip(_ilk));
        assertEq(addr.addr("PIP_PAX"), reg.pip(_ilk));
        assertEq(addr.addr("MCD_PSM_PAX_A"), chainLog.getAddress("MCD_PSM_PAX_A"));
        _checkPsmIlkIntegration(
            _ilk,
            GemJoinAbstract(addr.addr("MCD_JOIN_PSM_PAX_A")),
            ClipAbstract(addr.addr("MCD_CLIP_PSM_PAX_A")),
            addr.addr("PIP_PAX"),
            PsmAbstract(addr.addr("MCD_PSM_PAX_A")),
            0,   // tin
            0    // tout
        );
    }

    // @dev when testing new vest contracts, use the explicit id when testing to assist in
    //      identifying streams later for modification or removal
    function testVestDAI() private { // make private to disable
        // VestAbstract vest = VestAbstract(addr.addr("MCD_VEST_DAI"));

        // All times in GMT
        // uint256 OCT_01_2022 = 1664582400; // Saturday, October   1, 2022 12:00:00 AM
        // uint256 OCT_31_2022 = 1667260799; // Monday,   October  31, 2022 11:59:59 PM

        // assertEq(vest.ids(), 9);

        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // assertEq(vest.ids(), 9 + 1);

        // assertEq(vest.cap(), 1 * MILLION * WAD / 30 days);

        // assertTrue(vest.valid(10)); // check for valid contract
        // _checkDaiVest({
        //     _index:      10,                                             // id
        //     _wallet:     wallets.addr("DAIF_WALLET"),                    // usr
        //     _start:      OCT_01_2022,                                    // bgn
        //     _cliff:      OCT_01_2022,                                    // clf
        //     _end:        OCT_31_2022,                                    // fin
        //     _days:       31 days,                                        // fin
        //     _manager:    address(0),                                     // mgr
        //     _restricted: 1,                                              // res
        //     _reward:     67_863 * WAD,                                   // tot
        //     _claimed:    0                                               // rxd
        // });

        // // Give admin powers to Test contract address and make the vesting unrestricted for testing
        // GodMode.setWard(address(vest), address(this), 1);
        // uint256 prevBalance;

        // vest.unrestrict(10);
        // prevBalance = dai.balanceOf(wallets.addr("DAIF_WALLET"));
        // vm.warp(OCT_01_2022 + 31 days);
        // vest.vest(10);
        // assertEq(dai.balanceOf(wallets.addr("DAIF_WALLET")), prevBalance + 67_863 * WAD);
    }

    function _setupRootDomain() internal {
        vm.makePersistent(address(spell), address(spell.action()));

        string memory root = string.concat(vm.projectRoot(), "/lib/dss-test");
        config = ScriptTools.readInput(root, "integration");

        rootDomain = new RootDomain(config, getRelativeChain("mainnet"));
    }

    function testL2OptimismSpell() private {
        address l2TeleportGateway = BridgeLike(
            chainLog.getAddress("OPTIMISM_TELEPORT_BRIDGE")
        ).l2TeleportGateway();

        _setupRootDomain();

        optimismDomain = new OptimismDomain(config, getRelativeChain("optimism"), rootDomain);
        optimismDomain.selectFork();

        // Check that the L2 Optimism Spell is there and configured
        L2Spell optimismSpell = L2Spell(0xC077Eb64285b40C86B40769e99Eb1E61d682a6B4);

        L2Gateway optimismGateway = L2Gateway(optimismSpell.gateway());
        assertEq(address(optimismGateway), l2TeleportGateway, "l2-optimism-wrong-gateway");

        bytes32 optDstDomain = optimismSpell.dstDomain();
        assertEq(optDstDomain, bytes32("ETH-GOER-A"), "l2-optimism-wrong-dst-domain");

        // Validate pre-spell optimism state
        assertEq(optimismGateway.validDomains(optDstDomain), 1, "l2-optimism-invalid-dst-domain");
        // Cast the L1 Spell
        rootDomain.selectFork();

        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // switch to Optimism domain and relay the spell from L1
        // the `true` keeps us on Optimism rather than `rootDomain.selectFork()
        optimismDomain.relayFromHost(true);

        // Validate post-spell state
        assertEq(optimismGateway.validDomains(optDstDomain), 0, "l2-optimism-invalid-dst-domain");
    }

    function testL2ArbitrumSpell() private {
        // Ensure the Arbitrum Gov Relay has some ETH to pay for the Arbitrum spell
        assertGt(chainLog.getAddress("ARBITRUM_GOV_RELAY").balance, 0);

        address l2TeleportGateway = BridgeLike(
            chainLog.getAddress("ARBITRUM_TELEPORT_BRIDGE")
        ).l2TeleportGateway();

        _setupRootDomain();

        arbitrumDomain = new ArbitrumDomain(config, getRelativeChain("arbitrum_one"), rootDomain);
        arbitrumDomain.selectFork();

        // Check that the L2 Arbitrum Spell is there and configured
        L2Spell arbitrumSpell = L2Spell(0x11Dc6Ed4C08Da38B36709a6C8DBaAC0eAeDD48cA);

        L2Gateway arbitrumGateway = L2Gateway(arbitrumSpell.gateway());
        assertEq(address(arbitrumGateway), l2TeleportGateway, "l2-arbitrum-wrong-gateway");

        bytes32 arbDstDomain = arbitrumSpell.dstDomain();
        assertEq(arbDstDomain, bytes32("ETH-GOER-A"), "l2-arbitrum-wrong-dst-domain");

        // Validate pre-spell arbitrum state
        assertEq(arbitrumGateway.validDomains(arbDstDomain), 1, "l2-arbitrum-invalid-dst-domain");

        // Cast the L1 Spell
        rootDomain.selectFork();

        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // switch to Arbitrum domain and relay the spell from L1
        // the `true` keeps us on Arbitrum rather than `rootDomain.selectFork()
        arbitrumDomain.relayFromHost(true);

        // Validate post-spell state
        assertEq(arbitrumGateway.validDomains(arbDstDomain), 0, "l2-arbitrum-invalid-dst-domain");
    }

    function testFlapperUniV2() public {
        address old_flap = chainLog.getAddress("MCD_FLAP");

        assertEq(vow.flapper(), old_flap);
        assertEq(vat.can(address(vow), old_flap),      1);
        assertEq(vat.can(address(vow), address(flap)), 0);

        // execute spell
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        assertEq(vow.flapper(), address(flap));
        assertEq(vat.can(address(vow), old_flap),      0);
        assertEq(vat.can(address(vow), address(flap)), 1);

        // Create surplus manipulating dai and sin (ONLY FOR GOERLI)
        stdstore.target(address(vat)).sig("dai(address)").with_key(address(vow)).depth(0).checked_write(60_000_000 * RAD);
        stdstore.target(address(vat)).sig("sin(address)").with_key(address(vow)).depth(0).checked_write(5_000_000 * RAD);
        stdstore.target(address(vow)).sig("Sin()").checked_write(3_000_000 * RAD);
        stdstore.target(address(vow)).sig("Ash()").checked_write(2_000_000 * RAD);

        assertEq(flap.gem(), address(gov));
        address pip = flap.pip();
        assertEq(pip, addr.addr("PIP_MKR"));
        address pair = flap.pair();

        // Set liquidity in the pool
        vm.prank(pauseProxy);
        MedianAbstract(pip).kiss(address(this));

        uint256 price = MedianAbstract(pip).read();
        uint256 daiAmt = 1_000_000 * WAD;
        GodMode.setBalance(address(dai), address(pair), daiAmt);
        uint256 mkrAmt = 1_000_000 * WAD * WAD / price;
        GodMode.setBalance(address(gov), address(pair), mkrAmt * 97 / 100); // 3% worse price (should fail)
        vm.expectRevert("FlapperUniV2/insufficient-buy-amount");
        vow.flap();
        GodMode.setBalance(address(gov), address(pair), mkrAmt * 99 / 100); // Leaves just 1% worse price
        //

        uint256 initialLp = GemAbstract(pair).balanceOf(pauseProxy);
        uint256 initialDaiVow = vat.dai(address(vow));
        uint256 initialReserveDai = dai.balanceOf(pair);
        uint256 initialReserveMkr = gov.balanceOf(pair);

        vow.flap();

        assertGt(GemAbstract(pair).balanceOf(pauseProxy), initialLp);
        assertGt(dai.balanceOf(pair), initialReserveDai);
        assertEq(gov.balanceOf(pair), initialReserveMkr);
        assertGt(initialDaiVow - vat.dai(address(vow)), 2 * vow.bump() * 9 / 10);
        assertLt(initialDaiVow - vat.dai(address(vow)), 2 * vow.bump() * 11 / 10);
        assertEq(dai.balanceOf(address(flap)), 0);
        assertEq(gov.balanceOf(address(flap)), 0);

        // Check Mom can increase hop
        assertEq(flap.hop(), 1577 seconds);
        vm.prank(chief.hat());
        flapMom.stop();
        assertEq(flap.hop(), type(uint256).max);
    }

    // RWA tests

    address RWA015_A_OPERATOR = addr.addr("RWA015_A_OPERATOR");
    address RWA015_A_CUSTODY  = addr.addr("RWA015_A_CUSTODY");
    address MCD_PSM_PAX_A     = addr.addr("MCD_PSM_PAX_A");
    address MCD_PSM_GUSD_A    = addr.addr("MCD_PSM_GUSD_A");
    address MCD_PSM_USDC_A    = addr.addr("MCD_PSM_USDC_A");

    RwaUrnLike               rwa015AUrn             = RwaUrnLike(addr.addr("RWA015_A_URN"));
    RwaOutputConduitLike     rwa015AOutputConduit   = RwaOutputConduitLike(addr.addr("RWA015_A_OUTPUT_CONDUIT"));

    function testRWA015_OUTPUT_CONDUIT_DEPLOYMENT_SETUP() public {
        assertEq(rwa015AOutputConduit.dai(), addr.addr("MCD_DAI"), "output-conduit-dai-not-match");
    }

    function testRWA015_INTEGRATION_CONDUITS_SETUP() public {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        assertEq(rwa015AUrn.outputConduit(), address(rwa015AOutputConduit), "RwaUrn/urn-outputconduit-not-match");

        assertEq(rwa015AOutputConduit.wards(pauseProxy),      1, "OutputConduit/ward-pause-proxy-not-set");
        assertEq(rwa015AOutputConduit.wards(address(esm)),    1, "OutputConduit/ward-esm-not-set");
        assertEq(rwa015AOutputConduit.can(pauseProxy),        0, "OutputConduit/pause-proxy-hoped");
        assertEq(rwa015AOutputConduit.can(RWA015_A_OPERATOR), 1, "OutputConduit/operator-not-hope");
        assertEq(rwa015AOutputConduit.may(pauseProxy),        0, "OutputConduit/pause-proxy-mated");
        assertEq(rwa015AOutputConduit.may(RWA015_A_OPERATOR), 1, "OutputConduit/operator-not-mate");
        assertEq(rwa015AOutputConduit.bud(RWA015_A_CUSTODY),  1, "OutputConduit/destination-address-not-whitelisted-for-pick");
        assertEq(rwa015AOutputConduit.pal(MCD_PSM_PAX_A),     1, "OutputConduit/pax-psm-address-not-whitelisted-for-hook");
        assertEq(rwa015AOutputConduit.pal(MCD_PSM_GUSD_A),    1, "OutputConduit/gusd-a-address-not-whitelisted-for-hook");
        assertEq(rwa015AOutputConduit.pal(MCD_PSM_USDC_A),    1, "OutputConduit/usdc-psm-address-not-whitelisted-for-hook");
        assertEq(rwa015AOutputConduit.quitTo(), address(rwa015AUrn), "OutputConduit/quit-to-not-urn");
    }

    function testRWA015_REVOKE_OLD_CONDUITS_PERMISSIONS() public {
        address RWA015_OUTPUT_CONDUIT_PAX = chainLog.getAddress("RWA015_A_OUTPUT_CONDUIT");
        address RWA015_OUTPUT_CONDUIT_USDC = 0xe80420B69106E6993A7df14C191e7813dE3Ed8Db;

        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        assertEq(RwaOutputConduitLike(RWA015_OUTPUT_CONDUIT_PAX).wards(pauseProxy),      0, "OutputConduit/ward-pause-proxy-relied");
        assertEq(RwaOutputConduitLike(RWA015_OUTPUT_CONDUIT_PAX).wards(address(esm)),    0, "OutputConduit/ward-esm-relied");
        assertEq(RwaOutputConduitLike(RWA015_OUTPUT_CONDUIT_PAX).can(RWA015_A_OPERATOR), 0, "OutputConduit/operator-hoped");
        assertEq(RwaOutputConduitLike(RWA015_OUTPUT_CONDUIT_PAX).may(RWA015_A_OPERATOR), 0, "OutputConduit/operator-mated");
        assertEq(RwaOutputConduitLike(RWA015_OUTPUT_CONDUIT_PAX).bud(RWA015_A_CUSTODY),  0, "OutputConduit/destination-address-whitelisted-for-pick");
        assertEq(RwaOutputConduitLike(RWA015_OUTPUT_CONDUIT_PAX).quitTo(), address(0),      "OutputConduit/quit-to-not-zero");

        assertEq(RwaOutputConduitLike(RWA015_OUTPUT_CONDUIT_USDC).wards(pauseProxy),      0, "OutputConduit/ward-pause-proxy-relied");
        assertEq(RwaOutputConduitLike(RWA015_OUTPUT_CONDUIT_USDC).wards(address(esm)),    0, "OutputConduit/ward-esm-relied");
        assertEq(RwaOutputConduitLike(RWA015_OUTPUT_CONDUIT_USDC).can(RWA015_A_OPERATOR), 0, "OutputConduit/operator-hoped");
        assertEq(RwaOutputConduitLike(RWA015_OUTPUT_CONDUIT_USDC).may(RWA015_A_OPERATOR), 0, "OutputConduit/operator-mated");
        assertEq(RwaOutputConduitLike(RWA015_OUTPUT_CONDUIT_USDC).bud(RWA015_A_CUSTODY),  0, "OutputConduit/destination-address-whitelisted-for-pick");
        assertEq(RwaOutputConduitLike(RWA015_OUTPUT_CONDUIT_USDC).quitTo(), address(0),      "OutputConduit/quit-to-not-zero");
    }

    function testRWA015_OPERATOR_DRAW_CONDUIT_PUSH() public {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        uint256 drawAmount = 1_000_000 * WAD;

        // Increas line of RWA015 to be able to draw some DAI
        GodMode.setWard(address(vat), address(this), 1);
        vat.file("RWA015-A", "line", 3_500_000 * RAD);

        // setting address(this) as operator
        vm.store(address(rwa015AUrn), keccak256(abi.encode(address(this), uint256(1))), bytes32(uint256(1)));
        assertEq(rwa015AUrn.can(address(this)), 1);

        // 0 DAI in Output Conduit
        assertEq(dai.balanceOf(address(rwa015AOutputConduit)), 0, "RWA015-A: Dangling Dai in input conduit before draw()");

        // Draw 1m to test output conduit
        rwa015AUrn.draw(drawAmount);

        // DAI in Output Conduit
        assertEq(dai.balanceOf(address(rwa015AOutputConduit)), drawAmount, "RWA015-A: Dai drawn was not send to the recipient");

        // wards
        GodMode.setWard(address(rwa015AOutputConduit), address(this), 1);
        // may
        rwa015AOutputConduit.mate(address(this));
        assertEq(rwa015AOutputConduit.may(address(this)), 1);
        rwa015AOutputConduit.hope(address(this));
        assertEq(rwa015AOutputConduit.can(address(this)), 1);

        rwa015AOutputConduit.kiss(address(this));
        assertEq(rwa015AOutputConduit.bud(address(this)), 1);
        rwa015AOutputConduit.pick(address(this));
        rwa015AOutputConduit.hook(MCD_PSM_USDC_A);

        GemAbstract psmGem = GemAbstract(rwa015AOutputConduit.gem());
        uint256 daiPsmGemDiffDecimals = 10**(18 - uint256(psmGem.decimals()));

        uint256 pushAmount = drawAmount;
        rwa015AOutputConduit.push(pushAmount);
        rwa015AOutputConduit.quit();

        assertEq(dai.balanceOf(address(rwa015AOutputConduit)), 0, "RWA015-A: Output conduit still holds Dai after quit()");
        assertEq(psmGem.balanceOf(address(this)), pushAmount / daiPsmGemDiffDecimals, "RWA015-A: Psm GEM not sent to destination after push()");
        assertEq(dai.balanceOf(address(rwa015AOutputConduit)), drawAmount - pushAmount, "RWA015-A: Dai not sent to destination after push()");
    }

}
