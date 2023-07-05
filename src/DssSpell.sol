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

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Always keep office hours off on goerli
    function officeHours() public pure override returns (bool) {
        return false;
    }

    uint256 internal constant THOUSAND    = 10 **  3;
    uint256 internal constant MILLION     = 10 **  6;
    uint256 internal constant WAD         = 10 ** 18;
    uint256 internal constant RAD         = 10 ** 45;

    address internal constant MCD_FLAP    = 0x584491031764f94a97a0f98bBe536B004Ab9467b;
    address internal constant FLAPPER_MOM = 0x7316C080BFd1c8857605627a251A2F0ae511E4A1;
    address internal constant PIP_MKR     = 0x496C851B2A9567DfEeE0ACBf04365F3ba00Eb8dC;

    // NOTE: ignore in goerli
    // address internal constant CRON_SEQUENCER       = ;
    // address internal constant CRON_AUTOLINE_JOB    = ;
    // address internal constant CRON_LERP_JOB        = ;
    // address internal constant CRON_D3M_JOB         = ;
    // address internal constant CRON_CLIPPER_MOM_JOB = ;
    // address internal constant CRON_ORACLE_JOB      = ;
    // address internal constant CRON_FLAP_JOB        = ;

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
    uint256 internal constant FIVE_PT_SIX_NINE_PCT_RATE   = 1000000001754822903403114680;
    uint256 internal constant SIX_PT_ONE_NINE_PCT_RATE    = 1000000001904482384730282575;
    uint256 internal constant FIVE_PT_FOUR_FOUR_PCT_RATE  = 1000000001679727448331902751;

    function actions() public override {
        // ----- Deploy Multiswap Conduit for RWA015-A -----

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
        DssExecLib.setChangelogVersion("1.15.0");

        // ----- Add Cron Jobs to Chainlog -----
        // Forum: https://forum.makerdao.com/t/dsscron-housekeeping-additions/21292
        // NOTE: ignore in goerli

        // DssExecLib.setChangelogAddress("CRON_SEQUENCER",       CRON_SEQUENCER);
        // DssExecLib.setChangelogAddress("CRON_AUTOLINE_JOB",    CRON_AUTOLINE_JOB);
        // DssExecLib.setChangelogAddress("CRON_LERP_JOB",        CRON_LERP_JOB);
        // DssExecLib.setChangelogAddress("CRON_D3M_JOB",         CRON_D3M_JOB);
        // DssExecLib.setChangelogAddress("CRON_CLIPPER_MOM_JOB", CRON_CLIPPER_MOM_JOB);
        // DssExecLib.setChangelogAddress("CRON_ORACLE_JOB",      CRON_ORACLE_JOB);

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
        // NOTE: ignore in goerli

        // ----- CRVV1ETHSTETH-A 1st Stage Offboarding -----
        // NOTE: ignore in goerli
        // Set CRVV1ETHSTETH-A Debt Ceiling to 0
        // Remove CRVV1ETHSTETH-A from autoline

        // ----- Ecosystem Actor Dai Budget Stream -----
        // NOTE: ignore in goerli
        // Chronicle Labs Auditor Wallet | 2023-07-01 00:00:00 to 2024-06-30 23:59:59 | 3,721,800 DAI | 0x68D0ca2d5Ac777F6A9b0d1be44332BB3d5981C2f

        // ----- Ecosystem Actor MKR Budget Stream -----
        // NOTE: ignore in goerli
        // Chronicle Labs Auditor Wallet | 2023-07-01 00:00:00 to 2024-06-30 23:59:59 | 2,216.4 MKR | 0x68D0ca2d5Ac777F6A9b0d1be44332BB3d5981C2f

        // ----- Core Unit MKR Vesting Transfer -----
        // Mip: https://mips.makerdao.com/mips/details/MIP40c3SP36#mkr-vesting
        // NOTE: ignore in goerli
        // DECO-001 - 125 MKR - 0xF482D1031E5b172D42B2DAA1b6e5Cbf6519596f7
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
