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
import {ScriptTools} from "dss-test/DssTest.sol";

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

interface ACLManagerLike {
    function isPoolAdmin(address admin) external view returns (bool);
}

interface RwaLiquidationOracleLike {
    function ilks(bytes32) external view returns (string memory, address, uint48 toc, uint48 tau);
    function bump(bytes32 ilk, uint256 val) external;
    function tell(bytes32) external;
    function cure(bytes32) external;
    function cull(bytes32, address) external;
    function good(bytes32) external view returns (bool);
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

interface RwaOutputConduitLike {
    function wards(address) external view returns (uint256);
    function can(address) external view returns (uint256);
    function may(address) external view returns (uint256);
    function dai() external view returns (address);
    function psm() external view returns (address);
    function gem() external view returns (address);
    function bud(address) external view returns (uint256);
    function pick(address) external;
    function push() external;
    function push(uint256) external;
    function quit() external;
    function kiss(address) external;
    function mate(address) external;
    function hope(address) external;
    function quitTo() external view returns (address);
}

interface RwaInputConduitLike {
    function dai() external view returns (address);
    function gem() external view returns (address);
    function psm() external view returns (address);
    function to() external view returns (address);
    function wards(address) external view returns (uint256);
    function may(address) external view returns (uint256);
    function quitTo() external view returns (address);
    function mate(address) external;
    function push() external;
}

interface RwaJarLike {
    function chainlog() external view returns (address);
    function dai() external view returns (address);
    function daiJoin() external view returns (address);
}

interface PoolLike {
    struct ReserveData {
        //stores the reserve configuration
        uint256 configuration;
        //the liquidity index. Expressed in ray
        uint128 liquidityIndex;
        //the current supply rate. Expressed in ray
        uint128 currentLiquidityRate;
        //variable borrow index. Expressed in ray
        uint128 variableBorrowIndex;
        //the current variable borrow rate. Expressed in ray
        uint128 currentVariableBorrowRate;
        //the current stable borrow rate. Expressed in ray
        uint128 currentStableBorrowRate;
        //timestamp of last update
        uint40 lastUpdateTimestamp;
        //the id of the reserve. Represents the position in the list of the active reserves
        uint16 id;
        //aToken address
        address aTokenAddress;
        //stableDebtToken address
        address stableDebtTokenAddress;
        //variableDebtToken address
        address variableDebtTokenAddress;
        //address of the interest rate strategy
        address interestRateStrategyAddress;
        //the current treasury balance, scaled
        uint128 accruedToTreasury;
        //the outstanding unbacked aTokens minted through the bridging feature
        uint128 unbacked;
        //the outstanding debt borrowed against this asset in isolation mode
        uint128 isolationModeTotalDebt;
    }
    function getReserveData(address asset) external view returns (ReserveData memory);
}

contract DssSpellTest is DssSpellTestBase {
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

    function testRemoveChainlogValues() private { // make private to disable
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // try chainLog.getAddress("RWA007_A_INPUT_CONDUIT_URN") {
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

    function testNewChainlogValues() public { // don't disable
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        _checkChainlogKey("EXEC_PROXY_SPARK");


        // RWA015
        _checkChainlogKey("RWA015_A_JAR");
        _checkChainlogKey("RWA015");
        _checkChainlogKey("MCD_JOIN_RWA015_A");
        _checkChainlogKey("RWA015_A_URN");
        _checkChainlogKey("RWA015_A_INPUT_CONDUIT_URN");
        _checkChainlogKey("RWA015_A_INPUT_CONDUIT_JAR");
        _checkChainlogKey("RWA015_A_OUTPUT_CONDUIT");
        _checkChainlogKey("PIP_RWA015");

        _checkChainlogVersion("1.14.13");
    }

    function testNewIlkRegistryValues() public { // make private to disable
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Insert new ilk registry values tests here
        // RWA015
        assertEq(reg.pos("RWA015-A"),    62);
        assertEq(reg.join("RWA015-A"),   addr.addr("MCD_JOIN_RWA015_A"));
        assertEq(reg.gem("RWA015-A"),    addr.addr("RWA015"));
        assertEq(reg.dec("RWA015-A"),    GemAbstract(addr.addr("RWA015")).decimals());
        assertEq(reg.class("RWA015-A"),  3);
        assertEq(reg.pip("RWA015-A"),    addr.addr("PIP_RWA015"));
        assertEq(reg.name("RWA015-A"),   "RWA015-A: BlockTower Andromeda");
        assertEq(reg.symbol("RWA015-A"), GemAbstract(addr.addr("RWA015")).symbol());
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
            1    // tout
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

    function testSparkSpell() public {
        ACLManagerLike SPARK_ACL_MANAGER = ACLManagerLike(0xb137E7d16564c81ae2b0C8ee6B55De81dd46ECe5);
        address SPARK_PROXY = 0x4e847915D8a9f2Ab0cDf2FC2FD0A30428F25665d;
        address RETH = 0x62BC478FFC429161115A6E4090f819CE5C50A5d9;
        PoolLike pool = PoolLike(0x26ca51Af4506DE7a6f0785D20CD776081a05fF6d);

        // Spell is thoroughly checked in Spark repo, but just triple check the spell was cast here
        assertEq(WardsAbstract(SPARK_PROXY).wards(address(esm)), 0);
        assertEq(SPARK_ACL_MANAGER.isPoolAdmin(SPARK_PROXY), false);
        assertTrue(pool.getReserveData(RETH).aTokenAddress == address(0));

        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        assertEq(WardsAbstract(SPARK_PROXY).wards(address(esm)), 1);
        assertEq(SPARK_ACL_MANAGER.isPoolAdmin(SPARK_PROXY), true);
        assertTrue(pool.getReserveData(RETH).aTokenAddress != address(0));
    }

    // TODO Fillout new docs
    string RWA010_OLDDOC      = "QmRqsQRnLfaRuhFr5wCfDQZKzNo7FRVUyTJPhS76nfz6nX";
    string RWA010_NEWDOC      = "QmY382BPa5UQfmpTfi6KhjqQHtqq1fFFg2owBfsD2LKmYU";

    string RWA011_OLDDOC      = "QmRqsQRnLfaRuhFr5wCfDQZKzNo7FRVUyTJPhS76nfz6nX";
    string RWA011_NEWDOC      = "QmY382BPa5UQfmpTfi6KhjqQHtqq1fFFg2owBfsD2LKmYU";

    string RWA012_OLDDOC      = "QmRqsQRnLfaRuhFr5wCfDQZKzNo7FRVUyTJPhS76nfz6nX";
    string RWA012_NEWDOC      = "QmY382BPa5UQfmpTfi6KhjqQHtqq1fFFg2owBfsD2LKmYU";

    string RWA013_OLDDOC      = "QmRqsQRnLfaRuhFr5wCfDQZKzNo7FRVUyTJPhS76nfz6nX";
    string RWA013_NEWDOC      = "QmY382BPa5UQfmpTfi6KhjqQHtqq1fFFg2owBfsD2LKmYU";

    function testRWA010DocChange() public {
        _checkRWADocUpdate("RWA010-A", RWA010_OLDDOC, RWA010_NEWDOC);
    }
    function testRWA011DocChange() public {
        _checkRWADocUpdate("RWA011-A", RWA011_OLDDOC, RWA011_NEWDOC);
    }
    function testRWA012DocChange() public {
        _checkRWADocUpdate("RWA012-A", RWA012_OLDDOC, RWA012_NEWDOC);
    }
    function testRWA013DocChange() public {
        _checkRWADocUpdate("RWA013-A", RWA013_OLDDOC, RWA013_NEWDOC);
    }

    // RWA tests

    address RWA015_A_OPERATOR = addr.addr("RWA015_A_OPERATOR");
    address RWA015_A_CUSTODY  = addr.addr("RWA015_A_CUSTODY");

    RwaLiquidationOracleLike oracle                 = RwaLiquidationOracleLike(addr.addr("MIP21_LIQUIDATION_ORACLE"));
    GemAbstract              rwa015AGem             = GemAbstract(addr.addr("RWA015"));
    GemJoinAbstract          rwa015AJoin            = GemJoinAbstract(addr.addr("MCD_JOIN_RWA015_A"));
    RwaUrnLike               rwa015AUrn             = RwaUrnLike(addr.addr("RWA015_A_URN"));
    RwaJarLike               rwa015AJar             = RwaJarLike(addr.addr("RWA015_A_JAR"));
    RwaOutputConduitLike     rwa015AOutputConduit   = RwaOutputConduitLike(addr.addr("RWA015_A_OUTPUT_CONDUIT"));
    GemAbstract              psmGem                 = GemAbstract(rwa015AOutputConduit.gem());
    RwaInputConduitLike      rwa015AInputConduitUrn = RwaInputConduitLike(addr.addr("RWA015_A_INPUT_CONDUIT_URN"));
    RwaInputConduitLike      rwa015AInputConduitJar = RwaInputConduitLike(addr.addr("RWA015_A_INPUT_CONDUIT_JAR"));

    uint256 daiPsmGemDiffDecimals               = 10 ** (dai.decimals() - psmGem.decimals());

    // Note: This is an exception because of exceeding the `action` size in the spell. Main pattern is to have this checks in the spell itself
    function testRWA015_A_CONTRACT_DEPLOYMENT_SETUP() public {
        assertEq(rwa015AJoin.vat(), addr.addr("MCD_VAT"),  "join-vat-not-match");
        assertEq(rwa015AJoin.ilk(), "RWA015-A",            "join-ilk-not-match");
        assertEq(rwa015AJoin.gem(), address(rwa015AGem),   "join-gem-not-match");
        assertEq(rwa015AJoin.dec(), rwa015AGem.decimals(), "join-dec-not-match");

        assertEq(rwa015AUrn.vat(),           addr.addr("MCD_VAT"),          "urn-vat-not-match");
        assertEq(rwa015AUrn.jug(),           addr.addr("MCD_JUG"),          "urn-jug-not-match");
        assertEq(rwa015AUrn.daiJoin(),       addr.addr("MCD_JOIN_DAI"),     "urn-daijoin-not-match");
        assertEq(rwa015AUrn.gemJoin(),       address(rwa015AJoin),          "urn-gemjoin-not-match");
        assertEq(rwa015AUrn.outputConduit(), address(rwa015AOutputConduit), "urn-outputconduit-not-match");

        assertEq(rwa015AJar.chainlog(), addr.addr("CHANGELOG"),    "jar-chainlog-not-match");
        assertEq(rwa015AJar.dai(),      addr.addr("MCD_DAI"),      "jar-dai-not-match");
        assertEq(rwa015AJar.daiJoin(),  addr.addr("MCD_JOIN_DAI"), "jar-daijoin-not-match");

        assertEq(rwa015AOutputConduit.dai(), addr.addr("MCD_DAI"),        "output-conduit-dai-not-match");
        assertEq(rwa015AOutputConduit.gem(), addr.addr("USDC"),           "output-conduit-gem-not-match");
        assertEq(rwa015AOutputConduit.psm(), addr.addr("MCD_PSM_USDC_A"), "output-conduit-psm-not-match");

        assertEq(rwa015AInputConduitUrn.psm(), addr.addr("MCD_PSM_USDC_A"), "input-conduit-urn-psm-not-match");
        assertEq(rwa015AInputConduitUrn.to(),  address(rwa015AUrn),         "input-conduit-urn-to-not-match");
        assertEq(rwa015AInputConduitUrn.dai(), addr.addr("MCD_DAI"),        "input-conduit-urn-dai-not-match");
        assertEq(rwa015AInputConduitUrn.gem(), addr.addr("USDC"),           "input-conduit-urn-gem-not-match");

        assertEq(rwa015AInputConduitJar.psm(), addr.addr("MCD_PSM_USDC_A"), "input-conduit-jar-psm-not-match");
        assertEq(rwa015AInputConduitJar.to(),  address(rwa015AJar),         "input-conduit-jar-to-not-match");
        assertEq(rwa015AInputConduitJar.dai(), addr.addr("MCD_DAI"),        "input-conduit-jar-dai-not-match");
        assertEq(rwa015AInputConduitJar.gem(), addr.addr("USDC"),           "input-conduit-jar-gem-not-match");
    }

    function testRWA015_A_INTEGRATION_CONDUITS_SETUP() public {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        assertEq(rwa015AOutputConduit.wards(pauseProxy),      1, "OutputConduit/ward-pause-proxy-not-set");
        assertEq(rwa015AOutputConduit.wards(address(esm)),    1, "OutputConduit/ward-esm-not-set");
        assertEq(rwa015AOutputConduit.can(pauseProxy),        0, "OutputConduit/pause-proxy-hoped");
        assertEq(rwa015AOutputConduit.can(RWA015_A_OPERATOR), 1, "OutputConduit/operator-not-hope");
        assertEq(rwa015AOutputConduit.may(pauseProxy),        0, "OutputConduit/pause-proxy-not-mated");
        assertEq(rwa015AOutputConduit.may(RWA015_A_OPERATOR), 1, "OutputConduit/operator-not-mate");
        assertEq(rwa015AOutputConduit.bud(RWA015_A_CUSTODY),  1, "OutputConduit/destination-address-not-whitelisted-for-pick");

        assertEq(rwa015AOutputConduit.quitTo(), address(rwa015AUrn), "OutputConduit/quit-to-not-urn");

        assertEq(rwa015AInputConduitUrn.wards(pauseProxy),      1, "InputConduitUrn/ward-pause-proxy-not-set");
        assertEq(rwa015AInputConduitUrn.wards(address(esm)),    1, "InputConduitUrn/ward-esm-not-set");
        assertEq(rwa015AInputConduitUrn.may(pauseProxy),        0, "InputConduitUrn/pause-proxy-mated");
        assertEq(rwa015AInputConduitUrn.may(RWA015_A_OPERATOR), 1, "InputConduitUrn/operator-not-mate");

        assertEq(rwa015AInputConduitUrn.quitTo(), RWA015_A_CUSTODY, "InputConduitUrn/quit-to-not-set");

        assertEq(rwa015AInputConduitJar.wards(pauseProxy),      1, "InputConduitJar/ward-pause-proxy-not-set");
        assertEq(rwa015AInputConduitJar.wards(address(esm)),    1, "InputConduitJar/ward-esm-not-set");
        assertEq(rwa015AInputConduitJar.may(pauseProxy),        0, "InputConduitJar/pause-proxy-mated");
        assertEq(rwa015AInputConduitJar.may(RWA015_A_OPERATOR), 1, "InputConduitJar/operator-not-mate");

        assertEq(rwa015AInputConduitJar.quitTo(), RWA015_A_CUSTODY, "InputConduitJar/quit-to-not-set");

        assertEq(rwa015AJoin.wards(address(esm)),        1, "Join/ward-esm-not-set");
        assertEq(rwa015AJoin.wards(address(rwa015AUrn)), 1, "Join/ward-urn-not-set");

        assertEq(rwa015AUrn.wards(pauseProxy),      1, "Urn/ward-pause-proxy-not-set");
        assertEq(rwa015AUrn.wards(address(esm)),    1, "Urn/ward-esm-not-set");
        assertEq(rwa015AUrn.can(pauseProxy),        0, "Urn/pause-proxy-hoped");
        assertEq(rwa015AUrn.can(RWA015_A_OPERATOR), 1, "Urn/operator-not-hoped");
    }

    function testRWA015_A_INTEGRATION_BUMP() public {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        GodMode.setWard(address(oracle), address(this), 1);

        (, address pip, , ) = oracle.ilks("RWA015-A");

        assertEq(DSValueAbstract(pip).read(), bytes32(2_500_000 * WAD), "RWA015-A: Bad initial PIP value");

        oracle.bump("RWA015-A", 1_280_000_000 * WAD);

        assertEq(DSValueAbstract(pip).read(), bytes32(1_280_000_000 * WAD), "RWA015-A: Bad PIP value after bump()");
    }

    function testRWA015_A_INTEGRATION_TELL() public {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        GodMode.setWard(address(vat), address(this), 1);
        GodMode.setWard(address(oracle), address(this), 1);

        (, , , uint48 tocPre) = oracle.ilks("RWA015-A");
        assertEq(uint256(tocPre), 0, "RWA015-A: `toc` is not 0 before tell()");
        assertTrue(oracle.good("RWA015-A"), "RWA015-A: Oracle not good before tell()");

        vat.file("RWA015-A", "line", 0);
        oracle.tell("RWA015-A");

        (, , , uint48 tocPost) = oracle.ilks("RWA015-A");
        assertGt(uint256(tocPost), 0, "RWA015-A: `toc` is not set after tell()");
        assertTrue(!oracle.good("RWA015-A"), "RWA015-A: Oracle still good after tell()");
    }

    function testRWA015_A_INTEGRATION_TELL_CURE_GOOD() public {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        GodMode.setWard(address(vat), address(this), 1);
        GodMode.setWard(address(oracle), address(this), 1);

        vat.file("RWA015-A", "line", 0);
        oracle.tell("RWA015-A");

        assertTrue(!oracle.good("RWA015-A"), "RWA015-A: Oracle still good after tell()");

        oracle.cure("RWA015-A");

        assertTrue(oracle.good("RWA015-A"), "RWA015-A: Oracle not good after cure()");
        (, , , uint48 toc) = oracle.ilks("RWA015-A");
        assertEq(uint256(toc), 0, "RWA015-A: `toc` not zero after cure()");
    }

    function testFailRWA015_A_INTEGRATION_CURE_BEFORE_TELL() public {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        GodMode.setWard(address(oracle), address(this), 1);

        oracle.cure("RWA015-A");
    }

    function testRWA015_A_INTEGRATION_TELL_CULL() public {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        GodMode.setWard(address(vat), address(this), 1);
        GodMode.setWard(address(oracle), address(this), 1);

        assertTrue(oracle.good("RWA015-A"));

        vat.file("RWA015-A", "line", 0);
        oracle.tell("RWA015-A");

        assertTrue(!oracle.good("RWA015-A"), "RWA015-A: Oracle still good after tell()");

        oracle.cull("RWA015-A", addr.addr("RWA015_A_URN"));

        assertTrue(!oracle.good("RWA015-A"), "RWA015-A: Oracle still good after cull()");
        (, address pip, , ) = oracle.ilks("RWA015-A");
        assertEq(DSValueAbstract(pip).read(), bytes32(0), "RWA015-A: Oracle PIP value not set to zero after cull()");
    }

    function testRWA015_A_PAUSE_PROXY_OWNS_RWA015_TOKEN_BEFORE_SPELL() public {
        assertEq(rwa015AGem.balanceOf(addr.addr('MCD_PAUSE_PROXY')), 1 * WAD);
    }

    // This test applicable this deal because the lock and draw steps are executed in the spell.
    function testRWA015_A_SPELL_LOCK_OPERATOR_DRAW_WIPE_FREE() private {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        uint256 drawAmount = 2_500_000 * WAD;

        // setting address(this) as operator
        vm.store(address(rwa015AUrn), keccak256(abi.encode(address(this), uint256(1))), bytes32(uint256(1)));
        assertEq(rwa015AUrn.can(address(this)), 1);

        // Check if spell lock 1 * WAD of RWA015
        assertEq(rwa015AGem.balanceOf(addr.addr('MCD_PAUSE_PROXY')), 0, "RWA015-A: gem not transfered from the pause proxy");
        assertEq(rwa015AGem.balanceOf(address(rwa015AJoin)), 1 * WAD, "RWA015-A: gem not locked into the urn");

        // 0 DAI in Output Conduit
        assertEq(dai.balanceOf(address(rwa015AOutputConduit)), 0, "RWA015-A: Dangling Dai in input conduit before draw()");

        // Draw 500mm
        rwa015AUrn.draw(drawAmount);

        // 500mm DAI in Output Conduit
        assertEq(dai.balanceOf(address(rwa015AOutputConduit)), drawAmount, "RWA015-A: Dai drawn was not send to the recipient");

        (uint256 ink, uint256 art) = vat.urns("RWA015-A", address(rwa015AUrn));
        assertEq(art, drawAmount, "RWA015-A: bad `art` after spell"); // DAI drawn == art as rate should always be 1 RAY
        assertEq(ink, 1 * WAD, "RWA015-A: bad `ink` after spell"); // Whole unit of collateral is locked

        vm.warp(block.timestamp + 10 days);
        jug.drip("RWA015-A");

        (, uint256 rate,,,) = vat.ilks("RWA015-A");
        assertEq(rate, RAY, 'RWA015-A: bad `rate`'); // rate keeps being 1 RAY

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

        uint256 pushAmount = 100 * WAD; // We push only 100 DAI on Görli
        // uint256 pushAmount = drawAmount; // We push all on Mainnet
        rwa015AOutputConduit.push(pushAmount);
        rwa015AOutputConduit.quit();

        assertEq(dai.balanceOf(address(rwa015AOutputConduit)), 0, "RWA015-A: Output conduit still holds Dai after quit()");
        assertEq(psmGem.balanceOf(address(this)), pushAmount / daiPsmGemDiffDecimals, "RWA015-A: Psm GEM not sent to destination after push()");
        assertEq(dai.balanceOf(address(rwa015AUrn)), drawAmount - pushAmount, "RWA015-A: Dai not sent to destination after push()");

        // as we have SF 0 we need to pay exectly the same amount of DAI we have drawn
        uint256 daiToPay = drawAmount;

        // Note: In the version of inputConduit for this deal `push` is permissionles
        // // wards
        // GodMode.setWard(address(rwa015AInputConduitUrn), address(this), 1);
        // // may
        // rwa015AInputConduitUrn.mate(address(this));
        // assertEq(rwa015AInputConduitUrn.may(address(this)), 1);

        // transfer PSM GEM to input conduit
        psmGem.transfer(address(rwa015AInputConduitUrn), pushAmount / daiPsmGemDiffDecimals);
        assertEq(psmGem.balanceOf(address(rwa015AInputConduitUrn)), pushAmount / daiPsmGemDiffDecimals, "RWA015-A: Psm GEM not sent to input conduit");

        // input conduit 'push()' to the urn
        rwa015AInputConduitUrn.push();

        assertEq(dai.balanceOf(address(rwa015AUrn)), daiToPay, "Balance of the URN doesnt match");

        // repay debt and free our collateral
        rwa015AUrn.wipe(daiToPay);
        rwa015AUrn.free(1 * WAD);

        // check if we get back RWA015 Tokens
        assertEq(rwa015AGem.balanceOf(address(this)), 1 * WAD, "RWA015-A: gem not sent back to the caller");

        // check if we have 0 collateral and outstanding debt in the VAT
        (ink, art) = vat.urns("RWA015-A", address(rwa015AUrn));
        assertEq(ink, 0, "RWA015-A: bad `ink` after free()");
        assertEq(art, 0, "RWA015-A: bad `art` after wipe()");
    }

    function testFailRWA015_A_DRAW_ABOVE_LINE() public {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        uint256 drawAmount = 2_500_001 * WAD;

        // setting address(this) as operator
        vm.store(address(rwa015AUrn), keccak256(abi.encode(address(this), uint256(1))), bytes32(uint256(1)));

        // Draw 500m + 1
        rwa015AUrn.draw(drawAmount);
    }

    function testFailRWA015_A_OUTPUT_CONDUIT_PUSH_ABOVE_BALANCE() public {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        uint256 drawAmount = 1_000 * WAD;

        // setting address(this) as operator
        vm.store(address(rwa015AUrn), keccak256(abi.encode(address(this), uint256(1))), bytes32(uint256(1)));

        // Draw 500mm
        rwa015AUrn.draw(drawAmount);

        // auth
        GodMode.setWard(address(rwa015AOutputConduit), address(this), 1);

        // pick address(this)
        rwa015AOutputConduit.hope(address(this)); // allow this to call pick
        rwa015AOutputConduit.kiss(address(this)); // allow this to be picked
        rwa015AOutputConduit.pick(address(this));

        // push above balance
        uint256 pushAmount = drawAmount + 1 * WAD;
        rwa015AOutputConduit.mate(address(this)); // allow this to call push
        rwa015AOutputConduit.push(pushAmount);    // fail
    }

    // This test is not applicable this deal because the lock and draw steps are executed in the spell.
    function testRWA015_A_OPERATOR_LOCK_DRAW_CAGE() private {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        uint256 drawAmount = 2_500_000 * WAD;

        // setting address(this) as operator
        vm.store(address(rwa015AUrn), keccak256(abi.encode(address(this), uint256(1))), bytes32(uint256(1)));
        assertEq(rwa015AUrn.can(address(this)), 1);

        // Check if spell lock 1 * WAD of RWA015
        assertEq(rwa015AGem.balanceOf(addr.addr('MCD_PAUSE_PROXY')), 0, "RWA015-A: gem not transfered from the pause proxy");
        assertEq(rwa015AGem.balanceOf(address(rwa015AJoin)), 1 * WAD, "RWA015-A: gem not locked into the urn");

        // 0 DAI in Output Conduit
        assertEq(dai.balanceOf(address(rwa015AOutputConduit)), 0, "RWA015-A: Dangling Dai in input conduit before draw()");

        // Draw 500mm
        rwa015AUrn.draw(drawAmount);

        // 500mm DAI in Output Conduit
        assertEq(dai.balanceOf(address(rwa015AOutputConduit)), drawAmount, "RWA015-A: Dai drawn was not send to the recipient");

        (uint256 ink, uint256 art) = vat.urns("RWA015-A", address(rwa015AUrn));
        assertEq(art, drawAmount, "RWA015-A: bad `art` after spell"); // DAI drawn == art as rate should always be 1 RAY
        assertEq(ink, 1 * WAD, "RWA015-A: bad `ink` after spell"); // Whole unit of collateral is locked

        vm.warp(block.timestamp + 10 days);
        jug.drip("RWA015-A");

        (, uint256 rate,,,) = vat.ilks("RWA015-A");
        assertEq(rate, RAY, 'RWA015-A: bad `rate`'); // rate keeps being 1 RAY

        // wards
        GodMode.setWard(address(rwa015AOutputConduit), address(this), 1);
        // may
        rwa015AOutputConduit.mate(address(this));
        rwa015AOutputConduit.hope(address(this));

        rwa015AOutputConduit.kiss(address(this));
        assertEq(rwa015AOutputConduit.bud(address(this)), 1);
        rwa015AOutputConduit.pick(address(this));

        uint256 pushAmount = 100 * WAD; // We push only 100 DAI on Görli
        // uint256 pushAmount = drawAmount; // We push all on Mainnet
        rwa015AOutputConduit.push(pushAmount);
        rwa015AOutputConduit.quit();

        assertEq(dai.balanceOf(address(rwa015AOutputConduit)), 0, "RWA015-A: Output conduit still holds Dai after quit()");
        assertEq(psmGem.balanceOf(address(this)), pushAmount / daiPsmGemDiffDecimals, "RWA015-A: Psm GEM not sent to destination after push()");
        assertEq(dai.balanceOf(address(rwa015AUrn)), drawAmount - pushAmount, "RWA015-A: Dai not sent to destination after push()");

        // END
        GodMode.setWard(address(end), address(this), 1);
        end.cage();
        end.cage("RWA015-A");

        end.skim("RWA015-A", address(rwa015AUrn));

        (ink, art) = vat.urns("RWA015-A", address(rwa015AUrn));
        uint256 skimmedInk = drawAmount / 2_500_000;
        assertEq(ink, 1 * WAD - skimmedInk, "RWA015-A: wrong ink in urn after skim");
        assertEq(art, 0, "RWA015-A: wrong art in urn after skim");
        vm.warp(block.timestamp + end.wait());

        // Removing the surplus to allow continuing the execution.
        vm.store(
            address(vat),
            keccak256(abi.encode(address(vow), uint256(5))),
            bytes32(uint256(0))
        );

        end.thaw();

        end.flow("RWA015-A");

        GodMode.setBalance(address(dai), address(this), 2_500_000 * WAD);
        dai.approve(address(daiJoin), 2_500_000 * WAD);
        daiJoin.join(address(this), 2_500_000 * WAD);

        vat.hope(address(end));
        end.pack(2_500_000 * WAD);

        // Check DAI redemption after "cage()"
        assertEq(vat.gem("RWA015-A", address(this)), 0, "RWA015-A: wrong vat gem");
        assertEq(rwa015AGem.balanceOf(address(this)), 0, "RWA015-A: wrong gem balance");
        end.cash("RWA015-A", 2_500_000 * WAD);
        assertGt(vat.gem("RWA015-A", address(this)), 0, "RWA015-A: wrong vat gem after cash");
        assertEq(rwa015AGem.balanceOf(address(this)), 0, "RWA015-A: wrong gem balance after cash");
        rwa015AJoin.exit(address(this), vat.gem("RWA015-A", address(this)));
        assertEq(vat.gem("RWA015-A", address(this)), 0, "RWA015-A: wrong vat gem after exit");
        assertGt(rwa015AGem.balanceOf(address(this)), 0, "RWA015-A: wrong gem balance after exit");
    }

    // This test is not applicable this deal because the draw is executed in the spell.
    function testRWA015_A_SPELL_LOCK() private {
        (uint256 pink, uint256 part) = vat.urns("RWA015-A", address(rwa015AUrn));
        uint256 prevBalance = rwa015AGem.balanceOf(address(rwa015AUrn.gemJoin()));

        assertEq(part, 0, "RWA015-A/bad-art-before-spell");
        assertEq(pink, 0, "RWA015-A/bad-ink-before-spell");

        uint256 lockAmount = 1 * WAD;

        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Check if spell lock whole unit of RWA015 Token to the Urn
        assertEq(rwa015AGem.balanceOf(address(rwa015AUrn.gemJoin())), prevBalance + lockAmount, "RWA015-A/spell-do-not-lock-rwa015-token");

        (uint256 ink, uint256 art) = vat.urns("RWA015-A", address(rwa015AUrn));
        assertEq(art, 0, "RWA015-A/bad-art-after-spell");
        assertEq(ink, lockAmount, "RWA015-A/bad-ink-after-spell"); // Whole unit of collateral is locked
    }

    // The tests below are specific to RWA015-A deal and were adapted from the existing ones

    function testRWA015_A_SPELL_OPERATOR_WIPE_FREE() public {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        uint256 drawAmount = 2_500_000 * WAD; // We push only 100 DAI on Görli
        // as we have SF 0 we need to pay exectly the same amount of DAI we have pushed
        uint256 daiToPay = drawAmount;

        // Note: for Görli we cannot push the entire debt ceiling because the PSM is short on USDC.
        // For that reason, we need to artificially give this contract some USDC.
        GodMode.setBalance(address(psmGem), address(this), daiToPay / daiPsmGemDiffDecimals);
        // We also need to increase the global and PSM-USDC-A debt ceilings
        GodMode.setWard(address(vat), address(this), 1);
        vat.file("Line", 100_000_000_000 * RAD);
        vat.file("PSM-USDC-A", "line", 10_000_000_000 * RAD);

        // Note: In the version of inputConduit for this deal `push` is permissionles
        // // wards
        // GodMode.setWard(address(rwa015AInputConduitUrn), address(this), 1);
        // // may
        // rwa015AInputConduitUrn.mate(address(this));
        // assertEq(rwa015AInputConduitUrn.may(address(this)), 1);

        // transfer PSM GEM to input conduit
        psmGem.transfer(address(rwa015AInputConduitUrn), daiToPay / daiPsmGemDiffDecimals);
        assertEq(psmGem.balanceOf(address(rwa015AInputConduitUrn)), daiToPay / daiPsmGemDiffDecimals, "RWA015-A: Psm GEM not sent to input conduit");

        // input conduit 'push()' to the urn
        rwa015AInputConduitUrn.push();

        assertEq(dai.balanceOf(address(rwa015AUrn)), daiToPay, "Balance of the URN doesnt match");

        // wards
        GodMode.setWard(address(rwa015AUrn), address(this), 1);
        // can
        rwa015AUrn.hope(address(this));
        assertEq(rwa015AUrn.can(address(this)), 1);

        // repay debt and free our collateral
        rwa015AUrn.wipe(daiToPay);
        rwa015AUrn.free(1 * WAD);

        // check if we get back RWA015 Tokens
        assertEq(rwa015AGem.balanceOf(address(this)), 1 * WAD, "RWA015-A: gem not sent back to the caller");

        // check if we have 0 collateral and outstanding debt in the VAT
        (uint256 ink, uint256 art) = vat.urns("RWA015-A", address(rwa015AUrn));
        assertEq(ink, 0, "RWA015-A: bad `ink` after free()");
        assertEq(art, 0, "RWA015-A: bad `art` after wipe()");
    }

    function testRWA015_A_SPELL_CAGE() public {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        uint256 drawAmount = 2_500_000 * WAD;

        vm.warp(block.timestamp + 10 days);
        jug.drip("RWA015-A");

        (, uint256 rate,,,) = vat.ilks("RWA015-A");
        assertEq(rate, RAY, 'RWA015-A: bad `rate`'); // rate keeps being 1 RAY

        // END
        GodMode.setWard(address(end), address(this), 1);
        end.cage();
        end.cage("RWA015-A");

        end.skim("RWA015-A", address(rwa015AUrn));

        (uint256 ink, uint256 art) = vat.urns("RWA015-A", address(rwa015AUrn));
        uint256 skimmedInk = drawAmount / 2_500_000;
        assertEq(ink, 1 * WAD - skimmedInk, "RWA015-A: wrong ink in urn after skim");
        assertEq(art, 0, "RWA015-A: wrong art in urn after skim");
        vm.warp(block.timestamp + end.wait());

        // Removing the surplus to allow continuing the execution.
        vm.store(
            address(vat),
            keccak256(abi.encode(address(vow), uint256(5))),
            bytes32(uint256(0))
        );

        end.thaw();

        end.flow("RWA015-A");

        GodMode.setBalance(address(dai), address(this), 2_500_000 * WAD);
        dai.approve(address(daiJoin), 2_500_000 * WAD);
        daiJoin.join(address(this), 2_500_000 * WAD);

        vat.hope(address(end));
        end.pack(2_500_000 * WAD);

        // Check DAI redemption after "cage()"
        assertEq(vat.gem("RWA015-A", address(this)), 0, "RWA015-A: wrong vat gem");
        assertEq(rwa015AGem.balanceOf(address(this)), 0, "RWA015-A: wrong gem balance");
        end.cash("RWA015-A", 2_500_000 * WAD);
        assertGt(vat.gem("RWA015-A", address(this)), 0, "RWA015-A: wrong vat gem after cash");
        assertEq(rwa015AGem.balanceOf(address(this)), 0, "RWA015-A: wrong gem balance after cash");
        rwa015AJoin.exit(address(this), vat.gem("RWA015-A", address(this)));
        assertEq(vat.gem("RWA015-A", address(this)), 0, "RWA015-A: wrong vat gem after exit");
        assertGt(rwa015AGem.balanceOf(address(this)), 0, "RWA015-A: wrong gem balance after exit");
    }

    function testRWA015A_SPELL_EXECUTES_LOCK_DRAW_PUSH() public {
        uint256 drawAmount = 2_500_000 * WAD;
        uint256 pushAmount = 100 * WAD; // We push only 100 DAI on Görli
        // uint256 pushAmount = drawAmount; // We push all on Mainnet
        uint256 expectedBalanceChange = pushAmount / daiPsmGemDiffDecimals;

        uint256 pBalance = psmGem.balanceOf(RWA015_A_CUSTODY);

        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Check if the spell draw Dai up to the debt ceiling, swapped it into USDC and pushed it to the custody address.

        (uint256 ink, uint256 art) = vat.urns("RWA015-A", address(rwa015AUrn));
        assertEq(art, drawAmount, "RWA015-A: bad `art` after spell"); // DAI drawn == art as rate should always be 1 RAY
        assertEq(ink, 1 * WAD, "RWA015-A: bad `ink` after spell"); // Whole unit of collateral is locked

        uint256 balance = psmGem.balanceOf(RWA015_A_CUSTODY);

        assertEq(
            balance - pBalance,
            expectedBalanceChange,
            "RWA015-A: wrong custody address gem balance change"
        );
    }

    function testRWA015_A_SPELL_LOCK_IGNORE_ART() public {
        (uint256 pink, uint256 part) = vat.urns("RWA015-A", address(rwa015AUrn));
        uint256 prevBalance = rwa015AGem.balanceOf(address(rwa015AUrn.gemJoin()));

        assertEq(part, 0, "RWA015-A/bad-art-before-spell");
        assertEq(pink, 0, "RWA015-A/bad-ink-before-spell");

        uint256 lockAmount = 1 * WAD;

        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Check if spell lock whole unit of RWA015 Token to the Urn
        assertEq(rwa015AGem.balanceOf(address(rwa015AUrn.gemJoin())), prevBalance + lockAmount, "RWA015-A/spell-do-not-lock-rwa015-token");

        (uint256 ink,) = vat.urns("RWA015-A", address(rwa015AUrn));
        assertEq(ink, lockAmount, "RWA015-A/bad-ink-after-spell"); // Whole unit of collateral is locked
    }
}
