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

    address internal constant MCD_FLAP = 0x584491031764f94a97a0f98bBe536B004Ab9467b;
    address internal constant FLAPPER_MOM = 0x7316C080BFd1c8857605627a251A2F0ae511E4A1;
    address internal constant PIP_MKR = 0x496C851B2A9567DfEeE0ACBf04365F3ba00Eb8dC;
    // NOT FOR GOERLI:
    // address internal constant CRON_SEQUENCER       = ;
    // address internal constant CRON_AUTOLINE_JOB    = ;
    // address internal constant CRON_LERP_JOB        = ;
    // address internal constant CRON_D3M_JOB         = ;
    // address internal constant CRON_CLIPPER_MOM_JOB = ;
    // address internal constant CRON_ORACLE_JOB      = ;
    // address internal constant CRON_FLAP_JOB        = ;

    // Always keep office hours off on goerli
    function officeHours() public pure override returns (bool) {
        return false;
    }

    uint256 internal constant THOUSAND          = 10 **  3;
    uint256 internal constant MILLION           = 10 **  6;
    uint256 internal constant WAD               = 10 ** 18;
    uint256 internal constant RAD               = 10 ** 45;

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

    function actions() public override {

        DssExecLib.setChangelogAddress("PIP_MKR", PIP_MKR);

        DssInstance memory dss = MCD.loadFromChainlog(DssExecLib.LOG);
        FlapperInstance memory flap = FlapperInstance({
            flapper: MCD_FLAP,
            mom:     FLAPPER_MOM
        });
        FlapperUniV2Config memory cfg = FlapperUniV2Config({
            hop:  1577,
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

        // NOT FOR GOERLI:
        // DssCronSequencerLike(CRON_SEQUENCER).addJob(CRON_FLAP_JOB);

        // DssExecLib.setChangelogAddress("CRON_SEQUENCER", CRON_SEQUENCER);
        // DssExecLib.setChangelogAddress("CRON_AUTOLINE_JOB", CRON_AUTOLINE_JOB);
        // DssExecLib.setChangelogAddress("CRON_LERP_JOB", CRON_LERP_JOB);
        // DssExecLib.setChangelogAddress("CRON_D3M_JOB", CRON_D3M_JOB);
        // DssExecLib.setChangelogAddress("CRON_CLIPPER_MOM_JOB", CRON_CLIPPER_MOM_JOB);
        // DssExecLib.setChangelogAddress("CRON_ORACLE_JOB", CRON_ORACLE_JOB);
        // DssExecLib.setChangelogAddress("CRON_FLAP_JOB", CRON_FLAP_JOB);

        DssExecLib.setChangelogVersion("1.15.0");
    }
}


contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
