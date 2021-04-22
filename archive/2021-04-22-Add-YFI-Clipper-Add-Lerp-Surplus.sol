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

interface LerpFabLike {
    function newLerp(bytes32, address, bytes32, uint256, uint256, uint256, uint256) external returns (address);
    function active(uint256) external returns (address);
    function lerps(bytes32) external returns (address);
    function tall() external;
    function count() external returns (uint256);
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

    address constant MCD_CLIP_YFI_A      = 0x9020C96B06d2ac59e98A0F35f131D491EEcAa2C2; 
    address constant MCD_CLIP_CALC_YFI_A = 0x54A18C6ceEBDf42D8532EBf5e0a67C430a51b2f6;

    address constant LERP_FAB = 0xa6766Ed3574bAFc6114618E74035C7bb5e9a6aa9;

    function actions() public override {
        address MCD_VAT = DssExecLib.vat();
        address MCD_CAT = DssExecLib.cat();
        address MCD_DOG = DssExecLib.getChangelogAddress("MCD_DOG");
        address MCD_VOW = DssExecLib.vow();
        address MCD_END = DssExecLib.end();
        address MCD_ESM = DssExecLib.getChangelogAddress("MCD_ESM");
        address CLIPPER_MOM = DssExecLib.getChangelogAddress("CLIPPER_MOM");
        address ILK_REGISTRY = DssExecLib.getChangelogAddress("ILK_REGISTRY");
        address PIP_YFI = DssExecLib.getChangelogAddress("PIP_YFI");
        address MCD_FLIP_YFI_A = DssExecLib.getChangelogAddress("MCD_FLIP_YFI_A");

        // Set CLIP for YFI-A in the DOG
        DssExecLib.setContract(MCD_DOG, "YFI-A", "clip", MCD_CLIP_YFI_A);

        // Set VOW in the YFI-A CLIP
        DssExecLib.setContract(MCD_CLIP_YFI_A, "vow", MCD_VOW);

        // Set CALC in the YFI-A CLIP
        DssExecLib.setContract(MCD_CLIP_YFI_A, "calc", MCD_CLIP_CALC_YFI_A);

        // Authorize CLIP can access to VAT
        DssExecLib.authorize(MCD_VAT, MCD_CLIP_YFI_A);

        // Authorize CLIP can access to DOG
        DssExecLib.authorize(MCD_DOG, MCD_CLIP_YFI_A);

        // Authorize DOG can kick auctions on CLIP
        DssExecLib.authorize(MCD_CLIP_YFI_A, MCD_DOG);

        // Authorize the new END to access the YFI CLIP
        DssExecLib.authorize(MCD_CLIP_YFI_A, MCD_END);

        // Authorize CLIPPERMOM can set the stopped flag in CLIP
        DssExecLib.authorize(MCD_CLIP_YFI_A, CLIPPER_MOM);

        // Authorize new ESM to execute in YFI-A Clipper
        DssExecLib.authorize(MCD_CLIP_YFI_A, MCD_ESM);

        // Whitelist CLIP in the YFI osm
        DssExecLib.addReaderToOSMWhitelist(PIP_YFI, MCD_CLIP_YFI_A);

        // Whitelist CLIPPER_MOM in the YFI osm
        DssExecLib.addReaderToOSMWhitelist(PIP_YFI, CLIPPER_MOM);

        // No more auctions kicked via the CAT:
        DssExecLib.deauthorize(MCD_FLIP_YFI_A, MCD_CAT);

        // No more circuit breaker for the FLIP in YFI-A:
        DssExecLib.deauthorize(MCD_FLIP_YFI_A, DssExecLib.flipperMom());

        Fileable(MCD_DOG).file("YFI-A", "hole", 5_000 * RAD);
        Fileable(MCD_DOG).file("YFI-A", "chop", 113 * WAD / 100);
        Fileable(MCD_CLIP_YFI_A).file("buf", 130 * RAY / 100);
        Fileable(MCD_CLIP_YFI_A).file("tail", 140 minutes);
        Fileable(MCD_CLIP_YFI_A).file("cusp", 40 * RAY / 100);
        Fileable(MCD_CLIP_YFI_A).file("chip", 1 * WAD / 1000);
        Fileable(MCD_CLIP_YFI_A).file("tip", 0);
        Fileable(MCD_CLIP_CALC_YFI_A).file("cut", 99 * RAY / 100); // 1% cut
        Fileable(MCD_CLIP_CALC_YFI_A).file("step", 90 seconds);

        //  Tolerance currently set to 50%.
        //   n.b. 600000000000000000000000000 == 40% acceptable drop
        ClipperMomAbstract(CLIPPER_MOM).setPriceTolerance(MCD_CLIP_YFI_A, 50 * RAY / 100);

        ClipAbstract(MCD_CLIP_YFI_A).upchost();

        // Increase the Surplus Buffer to 1000 DAI over 7 days starting Thu Apr 22 2021 16:00:00 GMT+0000
        address lerp = LerpFabLike(LERP_FAB).newLerp("20210421_VOW_HUMP1", MCD_VOW, "hump", 1619107200, 500 * RAD, 1000 * RAD, 7 days);
        VowAbstract(MCD_VOW).rely(lerp);

        // Replace flip to clip in the ilk registry
        DssExecLib.setContract(ILK_REGISTRY, "YFI-A", "xlip", MCD_CLIP_YFI_A);
        Fileable(ILK_REGISTRY).file("YFI-A", "class", 1);

        address log = DssExecLib.getChangelogAddress("CHANGELOG");
        DssExecLib.setChangelogAddress("MCD_CLIP_YFI_A", MCD_CLIP_YFI_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_YFI_A", MCD_CLIP_CALC_YFI_A);
        ChainlogLike(log).removeAddress("MCD_FLIP_YFI_A");

        DssExecLib.setChangelogAddress("LERP_FAB", LERP_FAB);

        DssExecLib.setChangelogVersion("1.4.0");
    }
}

contract DssSpell is DssExec {
    DssSpellAction internal action_ = new DssSpellAction();
    constructor() DssExec(action_.description(), block.timestamp + 30 days, address(action_)) public {}
}
