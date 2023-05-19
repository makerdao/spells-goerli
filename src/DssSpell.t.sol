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

interface RwaLiquidationOracleLike {
    function ilks(bytes32) external view returns (string memory, address, uint48 toc, uint48 tau);
    function bump(bytes32 ilk, uint256 val) external;
    function tell(bytes32) external;
    function cure(bytes32) external;
    function cull(bytes32, address) external;
    function good(bytes32) external view returns (bool);
}

interface RwaUrnLike {
    function wards(address) external view returns (uint256);
    function can(address) external view returns (uint256);
    function gemJoin() external view returns (GemAbstract);
    function lock(uint256) external;
    function draw(uint256) external;
    function wipe(uint256) external;
    function free(uint256) external;
}

interface RwaOutputConduitLike {
    function wards(address) external view returns (uint256);
    function can(address) external view returns (uint256);
    function may(address) external view returns (uint256);
    function gem() external view returns (GemAbstract);
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
    function wards(address) external view returns (uint256);
    function may(address) external view returns (uint256);
    function quitTo() external view returns (address);
    function mate(address) external;
    function push() external;
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
    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;
    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;
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

        // RWA014
        _checkChainlogKey("RWA014_A_JAR");
        _checkChainlogKey("RWA014");
        _checkChainlogKey("MCD_JOIN_RWA014_A");
        _checkChainlogKey("RWA014_A_URN");
        _checkChainlogKey("RWA014_A_INPUT_CONDUIT_URN");
        _checkChainlogKey("RWA014_A_INPUT_CONDUIT_JAR");
        _checkChainlogKey("RWA014_A_OUTPUT_CONDUIT");
        _checkChainlogKey("PIP_RWA014");

        _checkChainlogVersion("1.14.12");
    }

    function testNewIlkRegistryValues() public { // make private to disable
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Insert new ilk registry values tests here
        // RWA014
        assertEq(reg.pos("RWA014-A"),    61);
        assertEq(reg.join("RWA014-A"),   addr.addr("MCD_JOIN_RWA014_A"));
        assertEq(reg.gem("RWA014-A"),    addr.addr("RWA014"));
        assertEq(reg.dec("RWA014-A"),    GemAbstract(addr.addr("RWA014")).decimals());
        assertEq(reg.class("RWA014-A"),  3);
        assertEq(reg.pip("RWA014-A"),    addr.addr("PIP_RWA014"));
        assertEq(reg.name("RWA014-A"),   "RWA014-A: Coinbase Custody");
        assertEq(reg.symbol("RWA014-A"), GemAbstract(addr.addr("RWA014")).symbol());
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

    // RWA tests

    address RWA014_A_OPERATOR                  = addr.addr("RWA014_A_OPERATOR");
    address RWA014_A_COINBASE_CUSTODY          = addr.addr("RWA014_A_COINBASE_CUSTODY");
    
    address ESM                                = addr.addr("MCD_ESM");
    RwaLiquidationOracleLike oracle            = RwaLiquidationOracleLike(addr.addr("MIP21_LIQUIDATION_ORACLE"));

    GemAbstract          rwagem_014            = GemAbstract(addr.addr("RWA014"));
    GemJoinAbstract      rwajoin_014           = GemJoinAbstract(addr.addr("MCD_JOIN_RWA014_A"));
    RwaUrnLike           rwaurn_014            = RwaUrnLike(addr.addr("RWA014_A_URN"));
    RwaOutputConduitLike rwaconduitout_014     = RwaOutputConduitLike(addr.addr("RWA014_A_OUTPUT_CONDUIT"));
    GemAbstract          psmGem                = rwaconduitout_014.gem();
    RwaInputConduitLike  rwaconduitinurn_014   = RwaInputConduitLike(addr.addr("RWA014_A_INPUT_CONDUIT_URN"));
    RwaInputConduitLike  rwaconduitinjar_014   = RwaInputConduitLike(addr.addr("RWA014_A_INPUT_CONDUIT_JAR"));
    uint256 daiPsmGemDiffDecimals              = 10 ** (dai.decimals() - psmGem.decimals());

    function testRWA014_INTEGRATION_CONDUITS_SETUP() public {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        assertEq(rwaconduitout_014.wards(ESM), 1, "OutputConduit/ward-esm-not-set");
        assertEq(rwaconduitout_014.can(pauseProxy), 1, "OutputConduit/pause-proxy-not-operator");
        assertEq(rwaconduitout_014.can(RWA014_A_OPERATOR), 1, "OutputConduit/monetalis-not-operator");
        assertEq(rwaconduitout_014.may(pauseProxy), 1, "OutputConduit/pause-proxy-not-mate");
        assertEq(rwaconduitout_014.may(RWA014_A_OPERATOR), 1, "OutputConduit/monetalis-not-mate");
        assertEq(rwaconduitout_014.quitTo(), address(rwaurn_014), "OutputConduit/quit-to-not-urn");     
        assertEq(rwaconduitout_014.bud(RWA014_A_COINBASE_CUSTODY), 1, "OutputConduit/coinbase-custody-not-whitelisted-for-pick");

        assertEq(rwaconduitinurn_014.wards(ESM), 1, "InputConduitUrn/ward-esm-not-set");
        assertEq(rwaconduitinurn_014.may(pauseProxy), 1, "InputConduitUrn/pause-proxy-not-mate");
        assertEq(rwaconduitinurn_014.may(RWA014_A_OPERATOR), 1, "InputConduitUrn/monetalis-not-mate");
        assertEq(rwaconduitinurn_014.quitTo(), RWA014_A_COINBASE_CUSTODY, "InputConduitUrn/quit-to-not-set");

        assertEq(rwaconduitinjar_014.wards(ESM), 1, "InputConduitJar/ward-esm-not-set");
        assertEq(rwaconduitinjar_014.may(pauseProxy), 1, "InputConduitJar/pause-proxy-not-mate");
        assertEq(rwaconduitinjar_014.may(RWA014_A_OPERATOR), 1, "InputConduitJar/monetalis-not-mate");
        assertEq(rwaconduitinjar_014.quitTo(), RWA014_A_COINBASE_CUSTODY, "InputConduitJar/quit-to-not-set");

        assertEq(rwajoin_014.wards(address(rwaurn_014)), 1, "Join/ward-urn-not-set");
        assertEq(rwajoin_014.wards(ESM), 1, "Join/ward-esm-not-set");

        assertEq(rwaurn_014.wards(ESM), 1, "Urn/ward-esm-not-set");
        assertEq(rwaurn_014.can(pauseProxy), 1, "Urn/pause-proxy-not-hoped");
        assertEq(rwaurn_014.can(RWA014_A_OPERATOR), 1, "Urn/operator-not-hoped");
    }

    function testRWA014_INTEGRATION_BUMP() public {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        GodMode.setWard(address(oracle), address(this), 1);

        (, address pip, , ) = oracle.ilks("RWA014-A");

        assertEq(DSValueAbstract(pip).read(), bytes32(500 * MILLION * WAD), "RWA014: Bad initial PIP value");

        oracle.bump("RWA014-A", 510 * MILLION * WAD);

        assertEq(DSValueAbstract(pip).read(), bytes32(510 * MILLION * WAD), "RWA014: Bad PIP value after bump()");
    }

    function testRWA014_INTEGRATION_TELL() public {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        GodMode.setWard(address(vat), address(this), 1);
        GodMode.setWard(address(oracle), address(this), 1);

        (, , , uint48 tocPre) = oracle.ilks("RWA014-A");
        assertEq(uint256(tocPre), 0, "RWA014: `toc` is not 0 before tell()");
        assertTrue(oracle.good("RWA014-A"), "RWA014: Oracle not good before tell()");

        vat.file("RWA014-A", "line", 0);
        oracle.tell("RWA014-A");

        (, , , uint48 tocPost) = oracle.ilks("RWA014-A");
        assertGt(uint256(tocPost), 0, "RWA014: `toc` is not set after tell()");
        assertTrue(!oracle.good("RWA014-A"), "RWA014: Oracle still good after tell()");
    }

    function testRWA014_INTEGRATION_TELL_CURE_GOOD() public {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        GodMode.setWard(address(vat), address(this), 1);
        GodMode.setWard(address(oracle), address(this), 1);

        vat.file("RWA014-A", "line", 0);
        oracle.tell("RWA014-A");

        assertTrue(!oracle.good("RWA014-A"), "RWA014: Oracle still good after tell()");

        oracle.cure("RWA014-A");

        assertTrue(oracle.good("RWA014-A"), "RWA014: Oracle not good after cure()");
        (, , , uint48 toc) = oracle.ilks("RWA014-A");
        assertEq(uint256(toc), 0, "RWA014: `toc` not zero after cure()");
    }

    function testFailRWA014_INTEGRATION_CURE_BEFORE_TELL() public {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        GodMode.setWard(address(oracle), address(this), 1);

        oracle.cure("RWA014-A");
    }

    function testRWA014_INTEGRATION_TELL_CULL() public {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        GodMode.setWard(address(vat), address(this), 1);
        GodMode.setWard(address(oracle), address(this), 1);

        assertTrue(oracle.good("RWA014-A"));

        vat.file("RWA014-A", "line", 0);
        oracle.tell("RWA014-A");

        assertTrue(!oracle.good("RWA014-A"), "RWA014: Oracle still good after tell()");

        oracle.cull("RWA014-A", addr.addr("RWA014_A_URN"));

        assertTrue(!oracle.good("RWA014-A"), "RWA014: Oracle still good after cull()");
        (, address pip, , ) = oracle.ilks("RWA014-A");
        assertEq(DSValueAbstract(pip).read(), bytes32(0), "RWA014: Oracle PIP value not set to zero after cull()");
    }

    function testRWA014_PAUSE_PROXY_OWNS_RWA014_TOKEN_BEFORE_SPELL() public {
        assertEq(rwagem_014.balanceOf(addr.addr('MCD_PAUSE_PROXY')), 1 * WAD);
    }

    function testRWA014_SPELL_LOCK_OPERATOR_DRAW_WIPE_FREE() public {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        uint256 drawAmount = 500_000_000 * WAD;

        // setting address(this) as operator
        vm.store(address(rwaurn_014), keccak256(abi.encode(address(this), uint256(1))), bytes32(uint256(1)));
        assertEq(rwaurn_014.can(address(this)), 1);

        // Check if spell lock 1 * WAD of RWA009
        assertEq(rwagem_014.balanceOf(addr.addr('MCD_PAUSE_PROXY')), 0, "RWA014: gem not transfered from the pause proxy");
        assertEq(rwagem_014.balanceOf(address(rwajoin_014)), 1 * WAD, "RWA014: gem not locked into the urn");

        // 0 DAI in Output Conduit
        assertEq(dai.balanceOf(address(rwaconduitout_014)), 0, "RWA014: Dangling Dai in input conduit before draw()");

        // Draw 500mm
        rwaurn_014.draw(drawAmount);

        // 1mm DAI in Output Conduit
        assertEq(dai.balanceOf(address(rwaconduitout_014)), drawAmount, "RWA014: Dai drawn was not send to the recipient");

        (uint256 ink, uint256 art) = vat.urns("RWA014-A", address(rwaurn_014));
        assertEq(art, drawAmount, "RWA014: bad `art` after spell"); // DAI drawn == art as rate should always be 1 RAY
        assertEq(ink, 1 * WAD, "RWA014: bad `ink` after spell"); // Whole unit of collateral is locked

        vm.warp(block.timestamp + 10 days);
        jug.drip("RWA014-A");

        (, uint256 rate,,,) = vat.ilks("RWA014-A");
        assertEq(rate, RAY, 'RWA014: bad `rate`'); // rate keeps being 1 RAY

        // wards
        GodMode.setWard(address(rwaconduitout_014), address(this), 1);
        // may
        rwaconduitout_014.mate(address(this));
        assertEq(rwaconduitout_014.may(address(this)), 1);
        rwaconduitout_014.hope(address(this));
        assertEq(rwaconduitout_014.can(address(this)), 1);

        rwaconduitout_014.kiss(address(this));
        assertEq(rwaconduitout_014.bud(address(this)), 1);
        rwaconduitout_014.pick(address(this));

        uint256 pushAmount = 100 * WAD; // We push only 100 DAI on Görli
        rwaconduitout_014.push(pushAmount);
        rwaconduitout_014.quit();

        assertEq(dai.balanceOf(address(rwaconduitout_014)), 0, "RWA014: Output conduit still holds Dai after quit()");
        assertEq(psmGem.balanceOf(address(this)), pushAmount / daiPsmGemDiffDecimals, "RWA014: Psm GEM not sent to destination after push()");
        assertEq(dai.balanceOf(address(rwaurn_014)), drawAmount - pushAmount, "RWA014: Dai not sent to destination after push()");

        // as we have SF 0 we need to pay exectly the same amount of DAI we have drawn
        uint256 daiToPay = drawAmount;

        // Note: In the version of outputCounduit for this deal `push` is permissionles
        // // wards
        // GodMode.setWard(address(rwaconduitinurn_014), address(this), 1);
        // // may
        // rwaconduitinurn_014.mate(address(this));
        // assertEq(rwaconduitinurn_014.may(address(this)), 1);

        // transfer PSM GEM to input conduit
        psmGem.transfer(address(rwaconduitinurn_014), pushAmount / daiPsmGemDiffDecimals);
        assertEq(psmGem.balanceOf(address(rwaconduitinurn_014)), pushAmount / daiPsmGemDiffDecimals, "RWA014: Psm GEM not sent to input conduit");
        
        // input conduit 'push()' to the urn
        rwaconduitinurn_014.push();

        assertEq(dai.balanceOf(address(rwaurn_014)), daiToPay, "Balance of the URN doesnt match");

        // repay debt and free our collateral
        rwaurn_014.wipe(daiToPay);
        rwaurn_014.free(1 * WAD);

        // check if we get back RWA009 Tokens
        assertEq(rwagem_014.balanceOf(address(this)), 1 * WAD, "RWA014: gem not sent back to the caller");

        // check if we have 0 collateral and outstanding debt in the VAT
        (ink, art) = vat.urns("RWA014-A", address(rwaurn_014));
        assertEq(ink, 0, "RWA014: bad `ink` after free()");
        assertEq(art, 0, "RWA014: bad `art` after wipe()");
    }

    function testFailRWA014_DRAW_ABOVE_LINE() public {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        uint256 drawAmount = 500_000_001 * WAD;

        // setting address(this) as operator
        vm.store(address(rwaurn_014), keccak256(abi.encode(address(this), uint256(1))), bytes32(uint256(1)));

        // Draw 2mm
        rwaurn_014.draw(drawAmount);
    }

    function testRWA014_OPERATOR_LOCK_DRAW_CAGE() public {
        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        uint256 drawAmount = 1_000_000 * WAD;

        // setting address(this) as operator
        vm.store(address(rwaurn_014), keccak256(abi.encode(address(this), uint256(1))), bytes32(uint256(1)));
        assertEq(rwaurn_014.can(address(this)), 1);

        // Check if spell lock 1 * WAD of RWA009
        assertEq(rwagem_014.balanceOf(addr.addr('MCD_PAUSE_PROXY')), 0, "RWA014: gem not transfered from the pause proxy");
        assertEq(rwagem_014.balanceOf(address(rwajoin_014)), 1 * WAD, "RWA014: gem not locked into the urn");

        // 0 DAI in Output Conduit
        assertEq(dai.balanceOf(address(rwaconduitout_014)), 0, "RWA014: Dangling Dai in input conduit before draw()");

        // Draw 500mm
        rwaurn_014.draw(drawAmount);

        // 500mm DAI in Output Conduit
        assertEq(dai.balanceOf(address(rwaconduitout_014)), drawAmount, "RWA014: Dai drawn was not send to the recipient");

        (uint256 ink, uint256 art) = vat.urns("RWA014-A", address(rwaurn_014));
        assertEq(art, drawAmount, "RWA014: bad `art` after spell"); // DAI drawn == art as rate should always be 1 RAY
        assertEq(ink, 1 * WAD, "RWA014: bad `ink` after spell"); // Whole unit of collateral is locked

        vm.warp(block.timestamp + 10 days);
        jug.drip("RWA014-A");

        (, uint256 rate,,,) = vat.ilks("RWA014-A");
        assertEq(rate, RAY, 'RWA014: bad `rate`'); // rate keeps being 1 RAY

        // wards
        GodMode.setWard(address(rwaconduitout_014), address(this), 1);
        // may
        rwaconduitout_014.mate(address(this));
        rwaconduitout_014.hope(address(this));

        rwaconduitout_014.kiss(address(this));
        assertEq(rwaconduitout_014.bud(address(this)), 1);
        rwaconduitout_014.pick(address(this));

        uint256 pushAmount = 100 * WAD; // We push only 100 DAI on Görli
        rwaconduitout_014.push(pushAmount);
        rwaconduitout_014.quit();

        assertEq(dai.balanceOf(address(rwaconduitout_014)), 0, "RWA014: Output conduit still holds Dai after quit()");
        assertEq(psmGem.balanceOf(address(this)), pushAmount / daiPsmGemDiffDecimals, "RWA014: Psm GEM not sent to destination after push()");
        assertEq(dai.balanceOf(address(rwaurn_014)), drawAmount - pushAmount, "RWA014: Dai not sent to destination after push()");

        // END
        GodMode.setWard(address(end), address(this), 1);
        end.cage();
        end.cage("RWA014-A");

        end.skim("RWA014-A", address(rwaurn_014));

        (ink, art) = vat.urns("RWA014-A", address(rwaurn_014));
        uint256 skimmedInk = drawAmount / 500_000_000;
        assertEq(ink, 1 * WAD - skimmedInk, "RWA014: wrong ink in urn after skim");
        assertEq(art, 0, "RWA014: wrong art in urn after skim");
        vm.warp(block.timestamp + end.wait());

        // Removing the surplus to allow continuing the execution.
        vm.store(
            address(vat),
            keccak256(abi.encode(address(vow), uint256(5))),
            bytes32(uint256(0))
        );

        end.thaw();

        end.flow("RWA014-A");

        GodMode.setBalance(address(dai), address(this), 1_000_000 * WAD);
        dai.approve(address(daiJoin), 1_000_000 * WAD);
        daiJoin.join(address(this), 1_000_000 * WAD);

        vat.hope(address(end));
        end.pack(1_000_000 * WAD);

        // Check DAI redemption after "cage()"
        assertEq(vat.gem("RWA014-A", address(this)), 0, "RWA014: wrong vat gem");
        assertEq(rwagem_014.balanceOf(address(this)), 0, "RWA014: wrong gem balance");
        end.cash("RWA014-A", 1_000_000 * WAD);
        assertGt(vat.gem("RWA014-A", address(this)), 0, "RWA014: wrong vat gem after cash");
        assertEq(rwagem_014.balanceOf(address(this)), 0, "RWA014: wrong gem balance after cash");
        rwajoin_014.exit(address(this), vat.gem("RWA014-A", address(this)));
        assertEq(vat.gem("RWA014-A", address(this)), 0, "RWA014: wrong vat gem after exit");
        assertGt(rwagem_014.balanceOf(address(this)), 0, "RWA014: wrong gem balance after exit");
    }

    function testRWA014_SPELL_LOCK() public {
        (uint256 pink, uint256 part) = vat.urns("RWA014-A", address(rwaurn_014));
        uint256 prevBalance = rwagem_014.balanceOf(address(rwaurn_014.gemJoin()));

        assertEq(part, 0, "RWA014/bad-art-before-spell");
        assertEq(pink, 0, "RWA014/bad-ink-before-spell");

        uint256 lockAmount = 1 * WAD;

        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Check if spell lock whole unit of RWA014 Token to the Urn
        assertEq(rwagem_014.balanceOf(address(rwaurn_014.gemJoin())), prevBalance + lockAmount, "RWA014/spell-do-not-lock-rwa014-token");
        
        (uint256 ink, uint256 art) = vat.urns("RWA014-A", address(rwaurn_014));
        assertEq(art, 0, "RWA014/bad-art-after-spell");
        assertEq(ink, lockAmount, "RWA014/bad-ink-after-spell"); // Whole unit of collateral is locked
    }

    function testSparkLendCollateralOnboarding() public {
        // Configuration masking parameters pulled from https://github.com/aave/aave-v3-core/blob/62dfda56bd884db2c291560c03abae9727a7635e/contracts/protocol/libraries/configuration/ReserveConfiguration.sol
        uint256 BORROWABLE_IN_ISOLATION_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFF;
        PoolLike pool = PoolLike(0x26ca51Af4506DE7a6f0785D20CD776081a05fF6d);
        address token = addr.addr("GNO");
        MedianAbstract medianizer = MedianAbstract(0x0cd01b018C355a60B2Cc68A1e3d53853f05A7280);
        address oracleAdapter = 0xa2B52104c454D3f6717028783695de985C1CfFdb;
        address interestRateStrategy = 0xE7Fe5041ec55c229fb41fD9183E5bc24B5E34959;
        address wstETH = 0x6E4F1e8d4c5E5E6e2781FD814EE0744cc16Eb352;

        PoolLike.ReserveData memory daiReserveData = pool.getReserveData(address(dai));
        PoolLike.ReserveData memory tokenReserveData = pool.getReserveData(token);
        assertEq((daiReserveData.configuration & ~BORROWABLE_IN_ISOLATION_MASK) != 0, false);
        assertTrue(tokenReserveData.aTokenAddress == address(0));   // Not set yet
        assertEq(medianizer.bud(oracleAdapter), 0);

        _vote(address(spell));
        _scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        daiReserveData = pool.getReserveData(address(dai));
        tokenReserveData = pool.getReserveData(token);
        assertEq((daiReserveData.configuration & ~BORROWABLE_IN_ISOLATION_MASK) != 0, true);
        assertTrue(tokenReserveData.aTokenAddress != address(0));
        assertEq(tokenReserveData.interestRateStrategyAddress, interestRateStrategy);
        assertEq(medianizer.bud(oracleAdapter), 1);

        // Integration test - take out a maximum loan

        // Make sure there is enough liquidity to borrow
        deal(address(dai), address(123), 50 * MILLION * WAD);
        vm.prank(address(123)); dai.approve(address(pool), type(uint256).max);
        vm.prank(address(123)); pool.supply(address(dai), 50 * MILLION * WAD, address(123), 0);

        deal(token, address(this), 50 * MILLION * WAD);
        GemAbstract(token).approve(address(pool), type(uint256).max);

        pool.supply(token, 50 * MILLION * WAD, address(this), 0);
        pool.borrow(address(dai), 4 * MILLION * WAD, 2, 0, address(this));
        vm.expectRevert(bytes('53'));   // 'Debt ceiling is exceeded'
        pool.borrow(address(dai), 1_100_000 * WAD, 2, 0, address(this));    // Over 5m limit
        vm.expectRevert(bytes('60'));   // 'Asset is not borrowable in isolation mode'
        pool.borrow(wstETH, 1 ether, 2, 0, address(this));  // Can't borrow another asset in isolation mode (wstETH)
    }
}
