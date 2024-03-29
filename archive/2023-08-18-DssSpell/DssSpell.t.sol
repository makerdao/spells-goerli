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

interface RwaLiquidationOracleLike {
    function ilks(bytes32 ilk) external view returns (string memory doc, address pip, uint48 tau, uint48 toc);
    function good(bytes32 ilk) external view returns (bool);
}

interface RwaUrnLike {
    function vat() external view returns (address);
    function jug() external view returns (address);
    function daiJoin() external view returns (address);
    function outputConduit() external view returns (address);
    function wards(address) external view returns (uint256);
    function hope(address) external;
    function can(address) external view returns (uint256);
    function gemJoin() external view returns (address);
    function lock(uint256) external;
    function draw(uint256) external;
    function wipe(uint256) external;
    function free(uint256) external;
}

interface ProxyLike {
    function exec(address target, bytes calldata args) external payable returns (bytes memory out);
}

interface TransferOwnershipLike {
    function owner() external view returns (address);
}

interface ChangeAdminLike {
    function admin() external view returns (address);
}

interface ACLManagerLike {
    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);
    function isEmergencyAdmin(address admin) external view returns (bool);
    function isPoolAdmin(address admin) external view returns (bool);
    function hasRole(bytes32 role, address account) external view returns (bool);
}

interface PoolAddressProviderLike {
    function getACLAdmin() external view returns (address);
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

    function testRemoveChainlogValues() private { // make private to disable
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        try chainLog.getAddress("INSERT_DELETED_CHAINLOG_KEY_HERE") {
            assertTrue(false);
        } catch Error(string memory errmsg) {
            assertTrue(_cmpStr(errmsg, "dss-chain-log/invalid-key"));
        } catch {
            assertTrue(false);
        }
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

    function testNewChainlogValues() private { // make private to disable
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        _checkChainlogKey("INSERT_NEW_CHAINLOG_KEY_HERE");
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

    // RWA tests
    function test_RWA002_Update() public {
        // Read the pip address
        (,address pip,,  ) = liquidationOracle.ilks("RWA002-A");

        // Load RWA002-A output conduit address
        address conduit = addr.addr("RWA002_A_OUTPUT_CONDUIT");

        // Check the conduit balance is 0 before cast
        assertEq(dai.balanceOf(address(conduit)), 0);

        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Read the pip address and spot value after cast, as well as Art and rate
        (uint256 Art, uint256 rate, uint256 spotAfter, uint256 line,) = vat.ilks("RWA002-A");

        // Check the pip and spot values after cast
        assertEq(uint256(DSValueAbstract(pip).read()), 92_899_355_926924134500000000, "RWA002: Bad PIP value after bump()");
        assertEq(spotAfter, 92_899_355_926924134500000000 * (RAY / WAD), "RWA002: Bad spot value after bump()");

        // Test that a draw() can be performed
        address urn = addr.addr("RWA002_A_URN");
        // Give ourselves operator status, noting that setWard() has replaced giveAuth()
        GodMode.setWard(urn, address(this), 1);
        RwaUrnLike(urn).hope(address(this));

        // Calculate how much 'room' we can draw to get close to line
        uint256 room = line - (Art * rate);
        uint256 drawAmt = room / RAY;

        // Correct our draw amount if it is too large
        if ((_divup((drawAmt * RAY), rate) * rate) > room) {
            drawAmt = (room - rate) / RAY;
        }

        // NOTE: only on goerli, remove on mainnet
        // This fix is needed becuause RWA002 was never locked into RwaUrn on Goerli
        GodMode.setBalance(addr.addr("RWA002"), address(this), 1 * WAD);
        GemAbstract(addr.addr("RWA002")).approve(urn, 1 * WAD);
        RwaUrnLike(urn).lock(1 * WAD);

        // Check if RWA002 is locked into the RwaUrn
        (uint256 ink,) = vat.urns("RWA002-A", urn);
        assertEq(ink, 1 * WAD, "RWA002: bad ink in RwaUrn");

        // Perform draw()
        RwaUrnLike(urn).draw(drawAmt);

        // Check the conduit balance after cast
        assertEq(dai.balanceOf(address(conduit)), drawAmt);

        // Read new Art
        (Art,,,,) = vat.ilks("RWA002-A");

        // Assert that we are within 2 `rate` of line
        assertTrue(line - (Art * rate) < (2 * rate));
    }

    // Spark Tests
    function testSparkSpellIsExecuted() public { // make private to disable
        address SPARK_PROXY    = 0x4e847915D8a9f2Ab0cDf2FC2FD0A30428F25665d;
        address SPARK_SPELL    = 0x13176Ad78eC3d2b6E32908B019D0F772EC0b4dFd;

        vm.expectCall(
            SPARK_PROXY,
            /* value = */ 0,
            abi.encodeCall(
                ProxyLike(SPARK_PROXY).exec,
                (SPARK_SPELL, abi.encodeWithSignature("execute()"))
            )
        );

        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());
    }

    function testSparkAdminTransfer() public {
        address SPARK_PROXY                          = 0x4e847915D8a9f2Ab0cDf2FC2FD0A30428F25665d;
        address SPARK_TREASURY_CONTROLLER            = 0x98e6BcBA7d5daFbfa4a92dAF08d3d7512820c30C;
        address SPARK_TREASURY                       = 0x0D56700c90a690D8795D6C148aCD94b12932f4E3;
        address SPARK_TREASURY_DAI                   = 0x44816381990B6613c7A96ca1937f3902D8eA3F5b;
        address SPARK_INCENTIVES                     = 0xF028c2F4b19898718fD0F77b9b881CbfdAa5e8Bb;
        address SPARK_WETH_GATEWAY                   = 0xe6fC577E87F7c977c4393300417dCC592D90acF8;
        address SPARK_ACL_MANAGER                    = 0xb137E7d16564c81ae2b0C8ee6B55De81dd46ECe5;
        address SPARK_POOL_ADDRESS_PROVIDER          = 0x026a5B6114431d8F3eF2fA0E1B2EDdDccA9c540E;
        address SPARK_POOL_ADDRESS_PROVIDER_REGISTRY = 0x1ad570fDEA255a3c1d8Cf56ec76ebA2b7bFDFfea;
        address SPARK_EMISSION_MANAGER               = 0xA7F8A757C4f7696c015B595F51B2901AC0121B18;

        bytes32 defaultAdminRole = ACLManagerLike(SPARK_ACL_MANAGER).DEFAULT_ADMIN_ROLE();

        assertEq(TransferOwnershipLike(SPARK_TREASURY_CONTROLLER).owner(), pauseProxy);

        // Transparent proxy dictates that admin() function is only exposed to the admin
        vm.startPrank(pauseProxy);

        assertEq(ChangeAdminLike(SPARK_TREASURY).admin(),     pauseProxy);
        assertEq(ChangeAdminLike(SPARK_TREASURY_DAI).admin(), pauseProxy);
        assertEq(ChangeAdminLike(SPARK_INCENTIVES).admin(),   pauseProxy);

        vm.stopPrank();

        assertTrue(ACLManagerLike(SPARK_ACL_MANAGER).isEmergencyAdmin(pauseProxy));
        assertTrue(!ACLManagerLike(SPARK_ACL_MANAGER).isEmergencyAdmin(SPARK_PROXY));
        assertTrue(ACLManagerLike(SPARK_ACL_MANAGER).isPoolAdmin(pauseProxy));
        assertTrue(ACLManagerLike(SPARK_ACL_MANAGER).isPoolAdmin(SPARK_PROXY));     // Already added from previous spell
        assertTrue(ACLManagerLike(SPARK_ACL_MANAGER).hasRole(defaultAdminRole, pauseProxy));
        assertTrue(!ACLManagerLike(SPARK_ACL_MANAGER).hasRole(defaultAdminRole, SPARK_PROXY));

        assertEq(TransferOwnershipLike(SPARK_WETH_GATEWAY).owner(),                   pauseProxy);
        assertEq(PoolAddressProviderLike(SPARK_POOL_ADDRESS_PROVIDER).getACLAdmin(),  pauseProxy);
        assertEq(TransferOwnershipLike(SPARK_POOL_ADDRESS_PROVIDER).owner(),          pauseProxy);
        assertEq(TransferOwnershipLike(SPARK_POOL_ADDRESS_PROVIDER_REGISTRY).owner(), pauseProxy);
        assertEq(TransferOwnershipLike(SPARK_EMISSION_MANAGER).owner(),               pauseProxy);

        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        assertEq(TransferOwnershipLike(SPARK_TREASURY_CONTROLLER).owner(), SPARK_PROXY);

        // Transparent proxy dictates that admin() function is only exposed to the admin
        vm.startPrank(SPARK_PROXY);

        assertEq(ChangeAdminLike(SPARK_TREASURY).admin(), SPARK_PROXY);
        assertEq(ChangeAdminLike(SPARK_TREASURY_DAI).admin(), SPARK_PROXY);
        assertEq(ChangeAdminLike(SPARK_INCENTIVES).admin(), SPARK_PROXY);

        vm.stopPrank();

        assertTrue(!ACLManagerLike(SPARK_ACL_MANAGER).isEmergencyAdmin(pauseProxy));
        assertTrue(ACLManagerLike(SPARK_ACL_MANAGER).isEmergencyAdmin(SPARK_PROXY));
        assertTrue(!ACLManagerLike(SPARK_ACL_MANAGER).isPoolAdmin(pauseProxy));
        assertTrue(ACLManagerLike(SPARK_ACL_MANAGER).isPoolAdmin(SPARK_PROXY));
        assertTrue(!ACLManagerLike(SPARK_ACL_MANAGER).hasRole(defaultAdminRole, pauseProxy));
        assertTrue(ACLManagerLike(SPARK_ACL_MANAGER).hasRole(defaultAdminRole, SPARK_PROXY));

        assertEq(TransferOwnershipLike(SPARK_WETH_GATEWAY).owner(),                   SPARK_PROXY);
        assertEq(PoolAddressProviderLike(SPARK_POOL_ADDRESS_PROVIDER).getACLAdmin(),  SPARK_PROXY);
        assertEq(TransferOwnershipLike(SPARK_POOL_ADDRESS_PROVIDER).owner(),          SPARK_PROXY);
        assertEq(TransferOwnershipLike(SPARK_POOL_ADDRESS_PROVIDER_REGISTRY).owner(), SPARK_PROXY);
        assertEq(TransferOwnershipLike(SPARK_EMISSION_MANAGER).owner(),               SPARK_PROXY);
    }
}
