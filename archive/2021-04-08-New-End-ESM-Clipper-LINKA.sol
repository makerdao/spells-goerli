// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2021 Maker Ecosystem Growth Holdings, INC.
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

import {Fileable, ChainlogLike} from "dss-exec-lib/DssExecLib.sol";
import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";
import "dss-interfaces/dss/IlkRegistryAbstract.sol";
import "dss-interfaces/dss/ClipAbstract.sol";
import "dss-interfaces/dss/ClipperMomAbstract.sol";
import "dss-interfaces/dss/EndAbstract.sol";

contract DssSpellAction is DssAction {

    string public constant description = "Kovan Spell";

    address constant MCD_DOG              = 0x121D0953683F74e9a338D40d9b4659C0EBb539a0;
    address constant MCD_END              = 0x0D1a98E93d9cE32E44bC035e8C6E4209fdB70C27;
    address constant MCD_ESM_BUG          = 0x0798603b8AE1f76D2823aDbc2E15d047Eac1Efd7;
    address constant MCD_ESM_ATTACK       = 0x23Aa7cbeb266413f968D284acce3a3f9EEFFC2Ec;
    address constant ILK_REGISTRY         = 0xB3fBb13b831F254DbBB9a1abdb81d8D91589B3B4;
    address constant CLIPPER_MOM          = 0x96E9a19Be6EA91d1C0908e5E207f944dc2E7B878;
    address constant MCD_CLIP_LINK_A      = 0x1eB71cC879960606F8ab0E02b3668EEf92CE6D98;
    address constant MCD_CLIP_CALC_LINK_A = 0xbd586d6352Fcf0C45f77FC9348F4Ee7539F6e2bD;

    uint256 constant THOUSAND   = 10**3;
    uint256 constant MILLION    = 10**6;
    uint256 constant WAD        = 10**18;
    uint256 constant RAY        = 10**27;
    uint256 constant RAD        = 10**45;

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {
        // Set stability for ETH-A to 4% (whatever higher than 0)
        DssExecLib.setIlkStabilityFee("ETH-A", 1000000001243680656318820312, true);


        address MCD_VAT          = DssExecLib.vat();
        address MCD_CAT          = DssExecLib.cat();
        address MCD_VOW          = DssExecLib.vow();
        address MCD_POT          = DssExecLib.pot();
        address MCD_SPOT         = DssExecLib.spotter();
        address MCD_END_OLD      = DssExecLib.end();
        address MCD_FLIP_LINK_A  = DssExecLib.flip("LINK-A");
        address ILK_REGISTRY_OLD = DssExecLib.reg();
        address PIP_LINK         = DssExecLib.getChangelogAddress("PIP_LINK");

        // ------------------  END  ------------------

        // Set contracts in END
        DssExecLib.setContract(MCD_END,  "vat", MCD_VAT);
        DssExecLib.setContract(MCD_END,  "cat", MCD_CAT);
        DssExecLib.setContract(MCD_END,  "dog", MCD_DOG);
        DssExecLib.setContract(MCD_END,  "vow", MCD_VOW);
        DssExecLib.setContract(MCD_END,  "pot", MCD_POT);
        DssExecLib.setContract(MCD_END, "spot", MCD_SPOT);

        // Authorize the new END in contracts
        DssExecLib.authorize(MCD_VAT, MCD_END);
        DssExecLib.authorize(MCD_CAT, MCD_END);
        DssExecLib.authorize(MCD_DOG, MCD_END);
        DssExecLib.authorize(MCD_VOW, MCD_END);
        DssExecLib.authorize(MCD_POT, MCD_END);
        DssExecLib.authorize(MCD_SPOT, MCD_END);

        // Set wait time in END
        Fileable(MCD_END).file("wait", EndAbstract(MCD_END_OLD).wait());

        // Deauthorize the old END in contracts
        DssExecLib.deauthorize(MCD_VAT, MCD_END_OLD);
        DssExecLib.deauthorize(MCD_CAT, MCD_END_OLD);
        DssExecLib.deauthorize(MCD_VOW, MCD_END_OLD);
        DssExecLib.deauthorize(MCD_POT, MCD_END_OLD);
        DssExecLib.deauthorize(MCD_SPOT, MCD_END_OLD);

        // Deauthorize the old END from all the FLIPS
        // Authorize the new END in all the FLIPS
        bytes32[] memory ilks = IlkRegistryAbstract(ILK_REGISTRY_OLD).list();
        address[] memory flips = new address[](ilks.length);
        for (uint256 i = 0; i < ilks.length; i++) {
            bytes32 ilk = ilks[i];

            address flip = DssExecLib.flip(ilk);
            flips[i] = flip;
            DssExecLib.deauthorize(flip, MCD_END_OLD);
            DssExecLib.authorize(flip, MCD_END);

            try DssExecLib.removeReaderFromOSMWhitelist(IlkRegistryAbstract(ILK_REGISTRY_OLD).pip(ilk), MCD_END_OLD) {} catch {}
            try DssExecLib.addReaderToOSMWhitelist(IlkRegistryAbstract(ILK_REGISTRY_OLD).pip(ilk), MCD_END) {} catch {}
        }

        // ------------------  ESM  ------------------

        // Authorize new ESM to execute in new END
        DssExecLib.authorize(MCD_END, MCD_ESM_BUG);
        DssExecLib.authorize(MCD_END, MCD_ESM_ATTACK);

        // Authorize new ESM to execute in VAT
        DssExecLib.authorize(MCD_VAT, MCD_ESM_ATTACK);

        // Make every flipper relies the MCD_ESM_ATTACK
        for (uint256 i = 0; i < flips.length; i++) {
            DssExecLib.authorize(flips[i], MCD_ESM_ATTACK);
        }

        // ------------------  DOG  ------------------

        // Set VOW in the DOG
        DssExecLib.setContract(MCD_DOG, "vow", MCD_VOW);

        // Authorize DOG can access to VAT
        DssExecLib.authorize(MCD_VAT, MCD_DOG);

        // Authorize DOG can access to VOW
        DssExecLib.authorize(MCD_VOW, MCD_DOG);

        Fileable(MCD_DOG).file("Hole", 10 * THOUSAND * RAD);


        // --------------  CLIPPER_MOM  --------------

        ClipperMomAbstract(CLIPPER_MOM).setAuthority(DssExecLib.getChangelogAddress("MCD_ADM"));

        // ----------------  LINK-A  -----------------

        // Set CLIP for LINK-A in the DOG
        DssExecLib.setContract(MCD_DOG, "LINK-A", "clip", MCD_CLIP_LINK_A);

        // Set VOW in the LINK-A CLIP
        DssExecLib.setContract(MCD_CLIP_LINK_A, "vow", MCD_VOW);

        // Set CALC in the LINK-A CLIP
        DssExecLib.setContract(MCD_CLIP_LINK_A, "calc", MCD_CLIP_CALC_LINK_A);

        // Authorize CLIP can access to VAT
        DssExecLib.authorize(MCD_VAT, MCD_CLIP_LINK_A);

        // Authorize CLIP can access to DOG
        DssExecLib.authorize(MCD_DOG, MCD_CLIP_LINK_A);

        // Authorize DOG can kick auctions on CLIP
        DssExecLib.authorize(MCD_CLIP_LINK_A, MCD_DOG);

        // Authorize the new END to access the LINK CLIP
        DssExecLib.authorize(MCD_CLIP_LINK_A, MCD_END);

        // Authorize CLIPPERMOM can set the stopped flag in CLIP
        DssExecLib.authorize(MCD_CLIP_LINK_A, CLIPPER_MOM);

        // Authorize new ESM to execute in LINK-A Clipper
        DssExecLib.authorize(MCD_CLIP_LINK_A, MCD_ESM_ATTACK);

        // Whitelist CLIP in the LINK osm
        DssExecLib.addReaderToOSMWhitelist(PIP_LINK, MCD_CLIP_LINK_A);

        // Whitelist CLIPPER_MOM in the LINK osm
        DssExecLib.addReaderToOSMWhitelist(PIP_LINK, CLIPPER_MOM);

        // No more auctions kicked via the CAT:
        DssExecLib.deauthorize(MCD_FLIP_LINK_A, MCD_CAT);

        // No more circuit breaker for the FLIP in LINK-A:
        DssExecLib.deauthorize(MCD_FLIP_LINK_A, DssExecLib.flipperMom());

        Fileable(MCD_DOG).file("LINK-A", "hole", 5 * THOUSAND * RAD);
        Fileable(MCD_DOG).file("LINK-A", "chop", 113 * WAD / 100);
        Fileable(MCD_CLIP_LINK_A).file("buf", 130 * RAY / 100);
        Fileable(MCD_CLIP_LINK_A).file("tail", 140 minutes);
        Fileable(MCD_CLIP_LINK_A).file("cusp", 40 * RAY / 100);
        Fileable(MCD_CLIP_LINK_A).file("chip", 1 * WAD / 1000);
        Fileable(MCD_CLIP_LINK_A).file("tip", 0);
        Fileable(MCD_CLIP_CALC_LINK_A).file("cut", 99 * RAY / 100); // 1% cut
        Fileable(MCD_CLIP_CALC_LINK_A).file("step", 90 seconds);

        //  Tolerance currently set to 50%.
        //   n.b. 600000000000000000000000000 == 40% acceptable drop
        ClipperMomAbstract(CLIPPER_MOM).setPriceTolerance(MCD_CLIP_LINK_A, 50 * RAY / 100);

        ClipAbstract(MCD_CLIP_LINK_A).upchost();

        // Replace flip to clip in the ilk registry
        DssExecLib.setContract(ILK_REGISTRY, "LINK-A", "xlip", MCD_CLIP_LINK_A);
        Fileable(ILK_REGISTRY).file("LINK-A", "class", 1);


        // ------------------  CHAINLOG  -----------------

        address log = DssExecLib.getChangelogAddress("CHANGELOG");

        DssExecLib.setChangelogAddress("MCD_DOG", MCD_DOG);
        DssExecLib.setChangelogAddress("MCD_END", MCD_END);
        ChainlogLike(log).removeAddress("MCD_ESM");
        DssExecLib.setChangelogAddress("MCD_ESM_BUG", MCD_ESM_BUG);
        DssExecLib.setChangelogAddress("MCD_ESM_ATTACK", MCD_ESM_ATTACK);
        DssExecLib.setChangelogAddress("CLIPPER_MOM", CLIPPER_MOM);
        DssExecLib.setChangelogAddress("MCD_CLIP_LINK_A", MCD_CLIP_LINK_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_LINK_A", MCD_CLIP_CALC_LINK_A);
        DssExecLib.setChangelogAddress("ILK_REGISTRY", ILK_REGISTRY);
        ChainlogLike(log).removeAddress("MCD_FLIP_LINK_A");

        // DssExecLib.setChangelogVersion("1.3.0");
    }

}

contract DssSpell is DssExec {
    DssSpellAction internal action_ = new DssSpellAction();
    constructor() DssExec(action_.description(), block.timestamp + 30 days, address(action_)) public {}
}
