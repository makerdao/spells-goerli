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

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";
import { MCD, DssInstance } from "dss-test/MCD.sol";
import { FlapperInit, FlapperInstance, FlapperUniV2Config } from "src/dependencies/dss-flappers/FlapperInit.sol";

// NOT FOR GOERLI:
// interface DssCronSequencerLike {
//     function addJob(address) external;
// }

interface RwaOutputConduitLike {
    function deny(address usr) external;
    function hope(address usr) external;
    function nope(address usr) external;
    function mate(address usr) external;
    function hate(address usr) external;
    function kiss(address who) external;
    function diss(address who) external;
    function file(bytes32 what, address data) external;
    function clap(address _psm) external;
}

interface RwaUrnLike {
    function file(bytes32 what, address data) external;
}

interface ChainlogLike {
    function removeAddress(bytes32) external;
}

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Always keep office hours off on goerli
    function officeHours() public pure override returns (bool) {
        return false;
    }

    uint256 internal constant THOUSAND                     = 10 **  3;
    uint256 internal constant MILLION                      = 10 **  6;
    uint256 internal constant WAD                          = 10 ** 18;
    uint256 internal constant RAD                          = 10 ** 45;

    // New RWA015 output conduit
    address internal constant RWA015_A_OPERATOR            = 0x23a10f09Fac6CCDbfb6d9f0215C795F9591D7476;
    address internal constant RWA015_A_CUSTODY             = 0x65729807485F6f7695AF863d97D62140B7d69d83;
    address internal constant RWA015_A_OUTPUT_CONDUIT      = 0xEff59711CbB16BCAdA3AA8B8f2Bbd26F5B38a8cA;
    address internal constant RWA015_A_OUTPUT_CONDUIT_USDC = 0xe80420B69106E6993A7df14C191e7813dE3Ed8Db;
    // NOTE: previous line will be different on the mainnet since the chains are out of sync
    // address internal immutable RWA015_A_OUTPUT_CONDUIT_USDC = DssExecLib.getChangelogAddress("RWA015_A_OUTPUT_CONDUIT_LEGACY");
    address internal immutable RWA015_A_URN                = DssExecLib.getChangelogAddress("RWA015_A_URN");
    address internal immutable RWA015_A_OUTPUT_CONDUIT_PAX = DssExecLib.getChangelogAddress("RWA015_A_OUTPUT_CONDUIT");
    address internal immutable MCD_PSM_PAX_A               = DssExecLib.getChangelogAddress("MCD_PSM_PAX_A");
    address internal immutable MCD_PSM_GUSD_A              = DssExecLib.getChangelogAddress("MCD_PSM_GUSD_A");
    address internal immutable MCD_PSM_USDC_A              = DssExecLib.getChangelogAddress("MCD_PSM_USDC_A");
    address internal immutable MCD_ESM                     = DssExecLib.esm();

    // CRON jobs
    // NOTE: ignore in goerli
    // address internal constant CRON_SEQUENCER            = ;
    // address internal constant CRON_AUTOLINE_JOB         = ;
    // address internal constant CRON_LERP_JOB             = ;
    // address internal constant CRON_D3M_JOB              = ;
    // address internal constant CRON_CLIPPER_MOM_JOB      = ;
    // address internal constant CRON_ORACLE_JOB           = ;
    // address internal constant CRON_FLAP_JOB             = ;

    // New flapper
    address internal constant MCD_FLAP                     = 0x584491031764f94a97a0f98bBe536B004Ab9467b;
    address internal constant FLAPPER_MOM                  = 0x7316C080BFd1c8857605627a251A2F0ae511E4A1;
    address internal constant PIP_MKR                      = 0x496C851B2A9567DfEeE0ACBf04365F3ba00Eb8dC;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmVp4mhhbwWGTfbh2BzwQB9eiBrQBKiqcPRZCaAxNUaar6
    //
    // uint256 internal constant X_PCT_RATE      = ;

    uint256 internal constant THREE_PT_ONE_NINE_PCT_RATE  = 1000000000995743377573746041;
    uint256 internal constant THREE_PT_FOUR_FOUR_PCT_RATE = 1000000001072474267302354182;
    uint256 internal constant THREE_PT_NINE_FOUR_PCT_RATE = 1000000001225381266358479708;
    uint256 internal constant FIVE_PT_FOUR_FOUR_PCT_RATE  = 1000000001679727448331902751;
    uint256 internal constant FIVE_PT_SIX_NINE_PCT_RATE   = 1000000001754822903403114680;
    uint256 internal constant SIX_PT_ONE_NINE_PCT_RATE    = 1000000001904482384730282575;

    function actions() public override {
        // ----- Deploy Multiswap Conduit for RWA015-A -----

        // Add OPERATOR permission on RWA015_A_OUTPUT_CONDUIT
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT).hope(RWA015_A_OPERATOR);
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT).mate(RWA015_A_OPERATOR);
        // Whitelist custody for output conduit destination address
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT).kiss(RWA015_A_CUSTODY);
        // Whitelist PSM's
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT).clap(MCD_PSM_PAX_A);
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT).clap(MCD_PSM_GUSD_A);
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT).clap(MCD_PSM_USDC_A);
        // Set "quitTo" address for RWA015_A_OUTPUT_CONDUIT
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT).file("quitTo", RWA015_A_URN);
        // Route URN to new conduit
        RwaUrnLike(RWA015_A_URN).file("outputConduit", RWA015_A_OUTPUT_CONDUIT);
        // Authorize ESM
        DssExecLib.authorize(RWA015_A_OUTPUT_CONDUIT, MCD_ESM);
        // Update ChainLog address
        DssExecLib.setChangelogAddress("RWA015_A_OUTPUT_CONDUIT", RWA015_A_OUTPUT_CONDUIT);

        // Revoke permissions on the old RWA015_A_OUTPUT_CONDUIT_PAX
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT_PAX).nope(RWA015_A_OPERATOR);
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT_PAX).hate(RWA015_A_OPERATOR);
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT_PAX).diss(RWA015_A_CUSTODY);
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT_PAX).file("quitTo", address(0));
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT_PAX).deny(MCD_ESM);
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT_PAX).deny(address(this));

        // Revoke permissions on the old RWA015_A_OUTPUT_CONDUIT_USDC
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT_USDC).nope(RWA015_A_OPERATOR);
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT_USDC).hate(RWA015_A_OPERATOR);
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT_USDC).diss(RWA015_A_CUSTODY);
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT_USDC).file("quitTo", address(0));
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT_USDC).deny(MCD_ESM);
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT_USDC).deny(address(this));

        // Remove LEGACY conduit from ChainLog
        // NOTE: ignore in goerli
        // ChainlogLike(DssExecLib.LOG).removeAddress("RWA015_A_OUTPUT_CONDUIT_LEGACY");

        // ----- Add Cron Jobs to Chainlog -----
        // Forum: https://forum.makerdao.com/t/dsscron-housekeeping-additions/21292
        // NOTE: ignore in goerli

        // DssExecLib.setChangelogAddress("CRON_SEQUENCER",       CRON_SEQUENCER);
        // DssExecLib.setChangelogAddress("CRON_AUTOLINE_JOB",    CRON_AUTOLINE_JOB);
        // DssExecLib.setChangelogAddress("CRON_LERP_JOB",        CRON_LERP_JOB);
        // DssExecLib.setChangelogAddress("CRON_D3M_JOB",         CRON_D3M_JOB);
        // DssExecLib.setChangelogAddress("CRON_CLIPPER_MOM_JOB", CRON_CLIPPER_MOM_JOB);
        // DssExecLib.setChangelogAddress("CRON_ORACLE_JOB",      CRON_ORACLE_JOB);

        // ----- Deploy FlapperUniV2 -----
        // Poll: https://vote.makerdao.com/polling/QmQmxEZp#poll-detail
        // Forum: https://forum.makerdao.com/t/introduction-of-smart-burn-engine-and-initial-parameters/21201
        // dss-flappers @ b10f68224c648166cd4f9b09595412bce9824301

        DssInstance memory dss = MCD.loadFromChainlog(DssExecLib.LOG);
        FlapperInstance memory flap = FlapperInstance({
            flapper: MCD_FLAP,
            mom:     FLAPPER_MOM
        });
        FlapperUniV2Config memory cfg = FlapperUniV2Config({
            hop:  1577 seconds,
            want: 98 * WAD / 100,
            pip:  PIP_MKR,
            hump: 50 * MILLION * RAD,
            bump: 5 * THOUSAND * RAD
        });

        FlapperInit.initFlapperUniV2({
            dss: dss,
            flapperInstance: flap,
            cfg: cfg
        });

        FlapperInit.initDirectOracle({
            flapper : MCD_FLAP
        });

        DssExecLib.setChangelogAddress("PIP_MKR", PIP_MKR);
        // NOTE: ignore in goerli
        // DssCronSequencerLike(CRON_SEQUENCER).addJob(CRON_FLAP_JOB);
        // DssExecLib.setChangelogAddress("CRON_FLAP_JOB", CRON_FLAP_JOB);

        // ----- Scope Defined Parameter Changes -----
        // Forum: https://forum.makerdao.com/t/stability-scope-parameter-changes-3/21238/6

        // Reduce DSR by 0.30% from 3.49% to 3.19%
        DssExecLib.setDSR(THREE_PT_ONE_NINE_PCT_RATE, /* doDrip = */ true);

        // Reduce WSTETH-A Liquidation Ratio by 10% from 160% to 150%
        DssExecLib.setIlkLiquidationRatio("WSTETH-A", 150_00);

        // Reduce WSTETH-B Liquidation Ratio by 10% from 185% to 175%
        DssExecLib.setIlkLiquidationRatio("WSTETH-B", 175_00);

        // Reduce RETH-A Liquidation Ratio by 20% from 170% to 150%
        DssExecLib.setIlkLiquidationRatio("RETH-A", 150_00);

        // Reduce the ETH-A Stability Fee (SF) by 0.30% from 3.74% to 3.44%
        DssExecLib.setIlkStabilityFee("ETH-A", THREE_PT_FOUR_FOUR_PCT_RATE, /* doDrip = */ true);

        // Reduce the ETH-B Stability Fee (SF) by 0.30% from 4.24% to 3.94%
        DssExecLib.setIlkStabilityFee("ETH-B", THREE_PT_NINE_FOUR_PCT_RATE, /* doDrip = */ true);

        // Reduce the ETH-C Stability Fee (SF) by 0.30% from 3.49% to 3.19%
        DssExecLib.setIlkStabilityFee("ETH-C", THREE_PT_ONE_NINE_PCT_RATE, /* doDrip = */ true);

        // Reduce the WSTETH-A Stability Fee (SF) by 0.30% from 3.74% to 3.44%
        DssExecLib.setIlkStabilityFee("WSTETH-A", THREE_PT_FOUR_FOUR_PCT_RATE, /* doDrip = */ true);

        // Reduce the WSTETH-B Stability Fee (SF) by 0.30% from 3.49% to 3.19%
        DssExecLib.setIlkStabilityFee("WSTETH-B", THREE_PT_ONE_NINE_PCT_RATE, /* doDrip = */ true);

        // Reduce the RETH-A Stability Fee (SF) by 0.30% from 3.74% to 3.44%
        DssExecLib.setIlkStabilityFee("RETH-A", THREE_PT_FOUR_FOUR_PCT_RATE, /* doDrip = */ true);

        // Reduce the WBTC-A Stability Fee (SF) by 0.11% from 5.80% to 5.69%
        DssExecLib.setIlkStabilityFee("WBTC-A", FIVE_PT_SIX_NINE_PCT_RATE, /* doDrip = */ true);

        // Reduce the WBTC-B Stability Fee (SF) by 0.11% from 6.30% to 6.19%
        DssExecLib.setIlkStabilityFee("WBTC-B", SIX_PT_ONE_NINE_PCT_RATE, /* doDrip = */ true);

        // Reduce the WBTC-C Stability Fee (SF) by 0.11% from 5.55% to 5.44%
        DssExecLib.setIlkStabilityFee("WBTC-C", FIVE_PT_FOUR_FOUR_PCT_RATE, /* doDrip = */ true);

        // ----- Delegate Compensation for June 2023 -----
        // Forum: https://forum.makerdao.com/t/june-2023-aligned-delegate-compensation/21310
        // NOTE: ignore in goerli

        // 0xDefensor  - 29.76 MKR - 0x9542b441d65B6BF4dDdd3d4D2a66D8dCB9EE07a9
        // BONAPUBLICA - 29.76 MKR - 0x167c1a762B08D7e78dbF8f24e5C3f1Ab415021D3
        // QGov        - 29.76 MKR - 0xB0524D8707F76c681901b782372EbeD2d4bA28a6
        // TRUE NAME   - 29.76 MKR - 0x612f7924c367575a0edf21333d96b15f1b345a5d
        // UPMaker     - 29.76 MKR - 0xbb819df169670dc71a16f58f55956fe642cc6bcd
        // vigilant    - 29.76 MKR - 0x2474937cB55500601BCCE9f4cb0A0A72Dc226F61
        // WBC         - 20.16 MKR - 0xeBcE83e491947aDB1396Ee7E55d3c81414fB0D47
        // PBG         -  9.92 MKR - 0x8D4df847dB7FfE0B46AF084fE031F7691C6478c2
        // Bandhar     -  7.68 MKR - 0xE83B6a503A94a5b764CCF00667689B3a522ABc21
        // Libertas    -  7.04 MKR - 0xE1eBfFa01883EF2b4A9f59b587fFf1a5B44dbb2f
        // PALC        -  2.24 MKR - 0x78Deac4F87BD8007b9cb56B8d53889ed5374e83A
        // Harmony     -  1.92 MKR - 0xF4704Aa4Ad22cAA2A3Dd7A7C529B4C32f7A421F2
        // VoteWizard  -  1.6  MKR - 0x9E72629dF4fcaA2c2F5813FbbDc55064345431b1
        // Navigator   -  0.32 MKR - 0x11406a9CC2e37425F15f920F494A51133ac93072

        // ----- CRVV1ETHSTETH-A 1st Stage Offboarding -----
        // Forum: https://forum.makerdao.com/t/stability-scope-parameter-changes-3/21238/6
        // NOTE: ignore in goerli

        // Set CRVV1ETHSTETH-A Debt Ceiling to 0
        // Remove CRVV1ETHSTETH-A from autoline

        // ----- Ecosystem Actor Dai Budget Stream -----
        // NOTE: ignore in goerli

        // Chronicle Labs Auditor Wallet | 2023-07-01 00:00:00 to 2024-06-30 23:59:59 | 3,721,800 DAI | 0x68D0ca2d5Ac777F6A9b0d1be44332BB3d5981C2f
        // Poll: https://vote.makerdao.com/polling/QmdnSKPu#poll-detail

        // Jetstream Auditor Wallet      | 2023-07-01 00:00:00 to 2024-12-31 23:59:59 | 2,964,006 DAI | 0xF478A08C41ad06E8D957d5e6B6Bcde7452cEE962
        // Forum: https://forum.makerdao.com/t/mip39c3-sp9-removing-dux-001/21306

        // ----- Ecosystem Actor MKR Budget Stream -----
        // NOTE: ignore in goerli

        // Chronicle Labs Auditor Wallet | 2023-07-01 00:00:00 to 2024-06-30 23:59:59 | 2,216.4  MKR | 0x68D0ca2d5Ac777F6A9b0d1be44332BB3d5981C2f
        // Poll: https://vote.makerdao.com/polling/QmdnSKPu

        // Jetstream Auditor Wallet      | 2023-06-26 00:00:00 to 2024-12-31 23:59:59 | 1,619.93 MKR | 0xF478A08C41ad06E8D957d5e6B6Bcde7452cEE962
        // Forum: https://forum.makerdao.com/t/mip39c3-sp9-removing-dux-001/21306

        // ----- Ecosystem Actor Dai Transfer -----
        // NOTE: ignore in goerli

        // Jetstream - 494,001 DAI - 0xF478A08C41ad06E8D957d5e6B6Bcde7452cEE962
        // Forum: https://forum.makerdao.com/t/mip39c3-sp9-removing-dux-001/21306

        // ----- Core Unit MKR Vesting Transfer -----
        // NOTE: ignore in goerli

        // DECO-001 - 125    MKR - 0xF482D1031E5b172D42B2DAA1b6e5Cbf6519596f7
        // Mip: https://mips.makerdao.com/mips/details/MIP40c3SP36#mkr-vesting

        // DUX-001  -  56.48 MKR - 0x5A994D8428CCEbCC153863CCdA9D2Be6352f89ad
        // Forum: https://forum.makerdao.com/t/mip39c3-sp9-removing-dux-001/21306

        // ----- Core Unit DAI Stream Cancel -----
        // NOTE: ignore in goerli

        // yank DAI stream ID 14 to DUX-001
        // Forum: https://forum.makerdao.com/t/mip39c3-sp9-removing-dux-001/21306

        // ----- Update ChainLog version -----
        // Justification: The MINOR version is updated as core MCD_FLAP contract is being replaced in the spell
        // See https://github.com/makerdao/pe-checklists/blob/492326ab00b4c400173b7d7d43a79df90c0c6c1d/spell/spell-crafter-goerli-workflow.md?plain=1#L80
        DssExecLib.setChangelogVersion("1.15.0");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
