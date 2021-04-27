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
import "dss-interfaces/dss/ClipAbstract.sol";
import "dss-interfaces/dss/ClipperMomAbstract.sol";
import "dss-interfaces/dss/VowAbstract.sol";

struct Collateral {
    bytes32 ilk;
    address vat;
    address vow;
    address spotter;
    address cat;
    address dog;
    address end;
    address esm;
    address flipperMom;
    address clipperMom;
    address ilkRegistry;
    address pip;
    address clipper;
    address flipper;
    address calc;
    uint256 hole;
    uint256 chop;
    uint256 buf;
    uint256 tail;
    uint256 cusp;
    uint256 chip;
    uint256 tip;
    uint256 cut;
    uint256 step;
    uint256 tolerance;
    bytes32 clipKey;
    bytes32 calcKey;
    bytes32 flipKey;
}

contract DssSpellAction is DssAction {

    string public constant description = "Kovan Spell";

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    uint256 constant WAD = 10**18;
    uint256 constant RAY = 10**27;
    uint256 constant RAD = 10**45;

    address constant MCD_CLIP_ETH_A       = 0x7dD1Fb6b9aFdBA9F28DB89c81723b8c6B27A2Fbe;
    address constant MCD_CLIP_CALC_ETH_A  = 0x46bE29C1993d64f0C93e81D69FfAFDF4881806f2;
    address constant MCD_CLIP_ETH_B       = 0x004676c737FC75A2799dFe745d23F5597620Ad43;
    address constant MCD_CLIP_CALC_ETH_B  = 0x4672215ADF0556Af60261e97E221c875ce9F0863;
    address constant MCD_CLIP_ETH_C       = 0x86D5eA244cf6c79227CA73004C963b72431f23ac;
    address constant MCD_CLIP_CALC_ETH_C  = 0xa8AfB2680cced6de0E1dfe5C35F0FEdFB8E95720;
    address constant MCD_CLIP_WBTC_A      = 0x5518C2f409Bed4bD5FF3542d9D5002251EEDA892;
    address constant MCD_CLIP_CALC_WBTC_A = 0x2c39F8C9aE16B84076D7fEA15CE5855925a09DA6;

    function flipperToClipper(Collateral memory col) internal {
        // Check constructor values of Clipper
        require(ClipAbstract(col.clipper).vat() == col.vat, "DssSpell/clip-wrong-vat");
        require(ClipAbstract(col.clipper).spotter() == col.spotter, "DssSpell/clip-wrong-spotter");
        require(ClipAbstract(col.clipper).dog() == col.dog, "DssSpell/clip-wrong-dog");
        require(ClipAbstract(col.clipper).ilk() == col.ilk, "DssSpell/clip-wrong-ilk");
        // Set CLIP for the ilk in the DOG
        DssExecLib.setContract(col.dog, col.ilk, "clip", col.clipper);
        // Set VOW in the CLIP
        DssExecLib.setContract(col.clipper, "vow", col.vow);
        // Set CALC in the CLIP
        DssExecLib.setContract(col.clipper, "calc", col.calc);
        // Authorize CLIP can access to VAT
        DssExecLib.authorize(col.vat, col.clipper);
        // Authorize CLIP can access to DOG
        DssExecLib.authorize(col.dog, col.clipper);
        // Authorize DOG can kick auctions on CLIP
        DssExecLib.authorize(col.clipper, col.dog);
        // Authorize the END to access the CLIP
        DssExecLib.authorize(col.clipper, col.end);
        // Authorize CLIPPERMOM can set the stopped flag in CLIP
        DssExecLib.authorize(col.clipper, col.clipperMom);
        // Authorize ESM to execute in Clipper
        DssExecLib.authorize(col.clipper, col.esm);
        // Whitelist CLIP in the osm
        DssExecLib.addReaderToOSMWhitelist(col.pip, col.clipper);
        // Whitelist clipperMom in the osm
        DssExecLib.addReaderToOSMWhitelist(col.pip, col.clipperMom);
        // No more auctions kicked via the CAT:
        DssExecLib.deauthorize(col.flipper, col.cat);
        // No more circuit breaker for the FLIP:
        DssExecLib.deauthorize(col.flipper, col.flipperMom);
        // Set values
        Fileable(col.dog).file(col.ilk, "hole", col.hole);
        Fileable(col.dog).file(col.ilk, "chop", col.chop);
        Fileable(col.clipper).file("buf", col.buf);
        Fileable(col.clipper).file("tail", col.tail);
        Fileable(col.clipper).file("cusp", col.cusp);
        Fileable(col.clipper).file("chip", col.chip);
        Fileable(col.clipper).file("tip", col.tip);
        Fileable(col.calc).file("cut", col.cut);
        Fileable(col.calc).file("step", col.step);
        ClipperMomAbstract(col.clipperMom).setPriceTolerance(col.clipper, col.tolerance);
        // Update chost
        ClipAbstract(col.clipper).upchost();
        // Replace flip to clip in the ilk registry
        DssExecLib.setContract(col.ilkRegistry, col.ilk, "xlip", col.clipper);
        Fileable(col.ilkRegistry).file(col.ilk, "class", 1);
        // Update Chainlog
        DssExecLib.setChangelogAddress(col.clipKey, col.clipper);
        DssExecLib.setChangelogAddress(col.calcKey, col.calc);
        ChainlogLike(DssExecLib.LOG).removeAddress(col.flipKey);
    }

    function actions() public override {
        address MCD_VAT         = DssExecLib.vat();
        address MCD_CAT         = DssExecLib.cat();
        address MCD_DOG         = DssExecLib.getChangelogAddress("MCD_DOG");
        address MCD_VOW         = DssExecLib.vow();
        address MCD_SPOT        = DssExecLib.spotter();
        address MCD_END         = DssExecLib.end();
        address MCD_ESM         = DssExecLib.getChangelogAddress("MCD_ESM");
        address FLIPPER_MOM     = DssExecLib.getChangelogAddress("FLIPPER_MOM");
        address CLIPPER_MOM     = DssExecLib.getChangelogAddress("CLIPPER_MOM");
        address ILK_REGISTRY    = DssExecLib.getChangelogAddress("ILK_REGISTRY");
        address PIP_ETH         = DssExecLib.getChangelogAddress("PIP_ETH");
        address PIP_WBTC        = DssExecLib.getChangelogAddress("PIP_WBTC");

        // --------------------------------- ETH-A ---------------------------------
        flipperToClipper(Collateral({
            ilk: "ETH-A",
            vat: MCD_VAT,
            vow: MCD_VOW,
            spotter: MCD_SPOT,
            cat: MCD_CAT,
            dog: MCD_DOG,
            end: MCD_END,
            esm: MCD_ESM,
            flipperMom: FLIPPER_MOM,
            clipperMom: CLIPPER_MOM,
            ilkRegistry: ILK_REGISTRY,
            pip: PIP_ETH,
            clipper: MCD_CLIP_ETH_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_ETH_A"),
            calc: MCD_CLIP_CALC_ETH_A,
            hole: 5_000 * RAD,
            chop: 113 * WAD / 100,
            buf: 130 * RAY / 100,
            tail: 140 minutes,
            cusp: 40 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 0,
            cut: 99 * RAY / 100,
            step: 90 seconds,
            tolerance: 50 * RAY / 100,
            clipKey: "MCD_CLIP_ETH_A",
            calcKey: "MCD_CLIP_CALC_ETH_A",
            flipKey: "MCD_FLIP_ETH_A"
        }));

        // --------------------------------- ETH-B ---------------------------------

        flipperToClipper(Collateral({
            ilk: "ETH-B",
            vat: MCD_VAT,
            vow: MCD_VOW,
            spotter: MCD_SPOT,
            cat: MCD_CAT,
            dog: MCD_DOG,
            end: MCD_END,
            esm: MCD_ESM,
            flipperMom: FLIPPER_MOM,
            clipperMom: CLIPPER_MOM,
            ilkRegistry: ILK_REGISTRY,
            pip: PIP_ETH,
            clipper: MCD_CLIP_ETH_B,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_ETH_B"),
            calc: MCD_CLIP_CALC_ETH_B,
            hole: 5_000 * RAD,
            chop: 113 * WAD / 100,
            buf: 130 * RAY / 100,
            tail: 140 minutes,
            cusp: 40 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 0,
            cut: 99 * RAY / 100,
            step: 90 seconds,
            tolerance: 50 * RAY / 100,
            clipKey: "MCD_CLIP_ETH_B",
            calcKey: "MCD_CLIP_CALC_ETH_B",
            flipKey: "MCD_FLIP_ETH_B"
        }));

        // --------------------------------- ETH-C ---------------------------------

        flipperToClipper(Collateral({
            ilk: "ETH-C",
            vat: MCD_VAT,
            vow: MCD_VOW,
            spotter: MCD_SPOT,
            cat: MCD_CAT,
            dog: MCD_DOG,
            end: MCD_END,
            esm: MCD_ESM,
            flipperMom: FLIPPER_MOM,
            clipperMom: CLIPPER_MOM,
            ilkRegistry: ILK_REGISTRY,
            pip: PIP_ETH,
            clipper: MCD_CLIP_ETH_C,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_ETH_C"),
            calc: MCD_CLIP_CALC_ETH_C,
            hole: 5_000 * RAD,
            chop: 113 * WAD / 100,
            buf: 130 * RAY / 100,
            tail: 140 minutes,
            cusp: 40 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 0,
            cut: 99 * RAY / 100,
            step: 90 seconds,
            tolerance: 50 * RAY / 100,
            clipKey: "MCD_CLIP_ETH_C",
            calcKey: "MCD_CLIP_CALC_ETH_C",
            flipKey: "MCD_FLIP_ETH_C"
        }));

        // --------------------------------- WBTC-A ---------------------------------

        flipperToClipper(Collateral({
            ilk: "WBTC-A",
            vat: MCD_VAT,
            vow: MCD_VOW,
            spotter: MCD_SPOT,
            cat: MCD_CAT,
            dog: MCD_DOG,
            end: MCD_END,
            esm: MCD_ESM,
            flipperMom: FLIPPER_MOM,
            clipperMom: CLIPPER_MOM,
            ilkRegistry: ILK_REGISTRY,
            pip: PIP_WBTC,
            clipper: MCD_CLIP_WBTC_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_WBTC_A"),
            calc: MCD_CLIP_CALC_WBTC_A,
            hole: 5_000 * RAD,
            chop: 113 * WAD / 100,
            buf: 130 * RAY / 100,
            tail: 140 minutes,
            cusp: 40 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 0,
            cut: 99 * RAY / 100,
            step: 90 seconds,
            tolerance: 50 * RAY / 100,
            clipKey: "MCD_CLIP_WBTC_A",
            calcKey: "MCD_CLIP_CALC_WBTC_A",
            flipKey: "MCD_FLIP_WBTC_A"
        }));


        DssExecLib.setChangelogVersion("1.5.0");
    }
}

contract DssSpell is DssExec {
    DssSpellAction internal action_ = new DssSpellAction();
    constructor() DssExec(action_.description(), block.timestamp + 30 days, address(action_)) public {}
}
