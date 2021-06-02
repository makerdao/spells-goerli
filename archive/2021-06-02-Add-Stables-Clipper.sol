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

    address constant MCD_CLIP_USDC_A            = 0x09D45087c035DbcD8d6fB5e9d4c5341b9101E626;
    address constant MCD_CLIP_CALC_USDC_A       = 0xF8D26c26Ac481794E4Aebf4F35B10d8E9748086a;
    address constant MCD_CLIP_USDC_B            = 0xedFc36f75faafa80e39cd4623def15da6CF2B5C0;
    address constant MCD_CLIP_CALC_USDC_B       = 0x275076c9c101AF880BD944991258d564FA31D61B;
    address constant MCD_CLIP_TUSD_A            = 0x9D547d599489B3950485cBa119FC37Bba9c15c13;
    address constant MCD_CLIP_CALC_TUSD_A       = 0x4AE93701287b8C86f17E5a0Cb4D0732b5ae6EFBD;
    address constant MCD_CLIP_USDT_A            = 0xBDd2d10dAF8D86dA1f02bB7c7C7841bC9A4F62D4;
    address constant MCD_CLIP_CALC_USDT_A       = 0xa3a5163Fa4d46D799fE4B036349f0289D69A4445;
    address constant MCD_CLIP_PAXUSD_A          = 0x3939B686a0A7265512D38Ea3fe700812A703BF31;
    address constant MCD_CLIP_CALC_PAXUSD_A     = 0x784863edC4C28D73192bf56944D8803c0b5E0CbF;
    address constant MCD_CLIP_GUSD_A            = 0x448eD0ff4e154C1cBefE2c8057906Dd3dA194dA5;
    address constant MCD_CLIP_CALC_GUSD_A       = 0x4DD8AaB74a710E7a95937ef1b2618ee76F829Ba6;
    address constant MCD_CLIP_PSM_USDC_A        = 0xC8Ca47D0AE4193b3f7F813E95669cfB15d922D56;
    address constant MCD_CLIP_CALC_PSM_USDC_A   = 0x22C3286711bD63D04Da2Ea95C4d7B556B9502a70;

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
        // DssExecLib.authorize(col.clipper, col.clipperMom);
        ClipAbstract(col.clipper).file("stopped", 3);
        // Authorize ESM to execute in Clipper
        DssExecLib.authorize(col.clipper, col.esm);
        if (col.pip != address(0)) {
            // Whitelist CLIP in the osm
            DssExecLib.addReaderToOSMWhitelist(col.pip, col.clipper);
            // Whitelist clipperMom in the osm
            DssExecLib.addReaderToOSMWhitelist(col.pip, col.clipperMom);
        }
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

        // -------------------------- Set tip for prev Clippers --------------------------
        Fileable(DssExecLib.getChangelogAddress("MCD_CLIP_ETH_A")).file("tip", 1 * RAD);
        Fileable(DssExecLib.getChangelogAddress("MCD_CLIP_ETH_B")).file("tip", 1 * RAD);
        Fileable(DssExecLib.getChangelogAddress("MCD_CLIP_ETH_C")).file("tip", 1 * RAD);
        Fileable(DssExecLib.getChangelogAddress("MCD_CLIP_BAT_A")).file("tip", 1 * RAD);
        Fileable(DssExecLib.getChangelogAddress("MCD_CLIP_WBTC_A")).file("tip", 1 * RAD);
        Fileable(DssExecLib.getChangelogAddress("MCD_CLIP_KNC_A")).file("tip", 1 * RAD);
        Fileable(DssExecLib.getChangelogAddress("MCD_CLIP_ZRX_A")).file("tip", 1 * RAD);
        Fileable(DssExecLib.getChangelogAddress("MCD_CLIP_MANA_A")).file("tip", 1 * RAD);
        Fileable(DssExecLib.getChangelogAddress("MCD_CLIP_COMP_A")).file("tip", 1 * RAD);
        Fileable(DssExecLib.getChangelogAddress("MCD_CLIP_LRC_A")).file("tip", 1 * RAD);
        Fileable(DssExecLib.getChangelogAddress("MCD_CLIP_LINK_A")).file("tip", 1 * RAD);
        Fileable(DssExecLib.getChangelogAddress("MCD_CLIP_BAL_A")).file("tip", 1 * RAD);
        Fileable(DssExecLib.getChangelogAddress("MCD_CLIP_YFI_A")).file("tip", 1 * RAD);
        Fileable(DssExecLib.getChangelogAddress("MCD_CLIP_UNI_A")).file("tip", 1 * RAD);
        Fileable(DssExecLib.getChangelogAddress("MCD_CLIP_RENBTC_A")).file("tip", 1 * RAD);
        Fileable(DssExecLib.getChangelogAddress("MCD_CLIP_AAVE_A")).file("tip", 1 * RAD);
        Fileable(DssExecLib.getChangelogAddress("MCD_CLIP_UNIV2DAIETH_A")).file("tip", 1 * RAD);

        // ----------------------------------- USDC-A -----------------------------------
        flipperToClipper(Collateral({
            ilk: "USDC-A",
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
            pip: address(0),
            clipper: MCD_CLIP_USDC_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_USDC_A"),
            calc: MCD_CLIP_CALC_USDC_A,
            hole: 0,
            chop: 113 * WAD / 100,
            buf: 105 * RAY / 100,
            tail: 220 minutes,
            cusp: 90 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 1 * RAD,
            cut: 999 * RAY / 1000,
            step: 120 seconds,
            tolerance: 95 * RAY / 100,
            clipKey: "MCD_CLIP_USDC_A",
            calcKey: "MCD_CLIP_CALC_USDC_A",
            flipKey: "MCD_FLIP_USDC_A"
        }));

        // ----------------------------------- USDC-B -----------------------------------
        flipperToClipper(Collateral({
            ilk: "USDC-B",
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
            pip: address(0),
            clipper: MCD_CLIP_USDC_B,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_USDC_B"),
            calc: MCD_CLIP_CALC_USDC_B,
            hole: 0,
            chop: 113 * WAD / 100,
            buf: 105 * RAY / 100,
            tail: 220 minutes,
            cusp: 90 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 1 * RAD,
            cut: 999 * RAY / 1000,
            step: 120 seconds,
            tolerance: 95 * RAY / 100,
            clipKey: "MCD_CLIP_USDC_B",
            calcKey: "MCD_CLIP_CALC_USDC_B",
            flipKey: "MCD_FLIP_USDC_B"
        }));

        // ----------------------------------- TUSD-A -----------------------------------
        flipperToClipper(Collateral({
            ilk: "TUSD-A",
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
            pip: address(0),
            clipper: MCD_CLIP_TUSD_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_TUSD_A"),
            calc: MCD_CLIP_CALC_TUSD_A,
            hole: 0,
            chop: 113 * WAD / 100,
            buf: 105 * RAY / 100,
            tail: 220 minutes,
            cusp: 90 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 1 * RAD,
            cut: 999 * RAY / 1000,
            step: 120 seconds,
            tolerance: 95 * RAY / 100,
            clipKey: "MCD_CLIP_TUSD_A",
            calcKey: "MCD_CLIP_CALC_TUSD_A",
            flipKey: "MCD_FLIP_TUSD_A"
        }));

        // ----------------------------------- USDT-A -----------------------------------
        flipperToClipper(Collateral({
            ilk: "USDT-A",
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
            pip: DssExecLib.getChangelogAddress("PIP_USDT"),
            clipper: MCD_CLIP_USDT_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_USDT_A"),
            calc: MCD_CLIP_CALC_USDT_A,
            hole: 0,
            chop: 113 * WAD / 100,
            buf: 105 * RAY / 100,
            tail: 220 minutes,
            cusp: 90 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 1 * RAD,
            cut: 999 * RAY / 1000,
            step: 120 seconds,
            tolerance: 95 * RAY / 100,
            clipKey: "MCD_CLIP_USDT_A",
            calcKey: "MCD_CLIP_CALC_USDT_A",
            flipKey: "MCD_FLIP_USDT_A"
        }));

        // ---------------------------------- PAXUSD-A ---------------------------------
        flipperToClipper(Collateral({
            ilk: "PAXUSD-A",
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
            pip: address(0),
            clipper: MCD_CLIP_PAXUSD_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_PAXUSD_A"),
            calc: MCD_CLIP_CALC_PAXUSD_A,
            hole: 0,
            chop: 113 * WAD / 100,
            buf: 105 * RAY / 100,
            tail: 220 minutes,
            cusp: 90 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 1 * RAD,
            cut: 999 * RAY / 1000,
            step: 120 seconds,
            tolerance: 95 * RAY / 100,
            clipKey: "MCD_CLIP_PAXUSD_A",
            calcKey: "MCD_CLIP_CALC_PAXUSD_A",
            flipKey: "MCD_FLIP_PAXUSD_A"
        }));

        // ----------------------------------- GUSD-A -----------------------------------
        flipperToClipper(Collateral({
            ilk: "GUSD-A",
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
            pip: address(0),
            clipper: MCD_CLIP_GUSD_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_GUSD_A"),
            calc: MCD_CLIP_CALC_GUSD_A,
            hole: 0,
            chop: 113 * WAD / 100,
            buf: 105 * RAY / 100,
            tail: 220 minutes,
            cusp: 90 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 1 * RAD,
            cut: 999 * RAY / 1000,
            step: 120 seconds,
            tolerance: 95 * RAY / 100,
            clipKey: "MCD_CLIP_GUSD_A",
            calcKey: "MCD_CLIP_CALC_GUSD_A",
            flipKey: "MCD_FLIP_GUSD_A"
        }));

        // ----------------------------------- PSM-USDC-A -----------------------------------
        flipperToClipper(Collateral({
            ilk: "PSM-USDC-A",
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
            pip: address(0),
            clipper: MCD_CLIP_PSM_USDC_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_PSM_USDC_A"),
            calc: MCD_CLIP_CALC_PSM_USDC_A,
            hole: 0,
            chop: 113 * WAD / 100,
            buf: 105 * RAY / 100,
            tail: 220 minutes,
            cusp: 90 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 1 * RAD,
            cut: 999 * RAY / 1000,
            step: 120 seconds,
            tolerance: 95 * RAY / 100,
            clipKey: "MCD_CLIP_PSM_USDC_A",
            calcKey: "MCD_CLIP_CALC_PSM_USDC_A",
            flipKey: "MCD_FLIP_PSM_USDC_A"
        }));

        // ---------------------------- Update Chainlog version ----------------------------
        DssExecLib.setChangelogVersion("1.9.0");
    }
}

contract DssSpell is DssExec {
    DssSpellAction internal action_ = new DssSpellAction();
    constructor() DssExec(action_.description(), block.timestamp + 30 days, address(action_)) public {}
}
