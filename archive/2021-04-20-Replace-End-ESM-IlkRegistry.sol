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
import "dss-interfaces/dss/EndAbstract.sol";
import "dss-interfaces/dss/ESMAbstract.sol";

contract DssSpellAction is DssAction {

    string public constant description = "Kovan Spell";

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    uint256 constant WAD = 10**18;

    address constant MCD_END         = 0x3d9603037FF096af03B83725dFdB1CDA9EA02CE4;
    address constant MCD_ESM         = 0xD5D728446275B0A12E4a4038527974b92353B4a9;
    address constant ILK_REGISTRY    = 0xc3F42deABc0C506e8Ae9356F2d4fc1505196DCDB;

    address constant MCD_FLIP_LINK_A = 0xfbDCDF5Bd98f68cEfc3f37829189b97B602eCFF2;

    function actions() public override {
        address MCD_VAT          = DssExecLib.vat();
        address MCD_CAT          = DssExecLib.cat();
        address MCD_DOG          = DssExecLib.getChangelogAddress("MCD_DOG");
        address MCD_VOW          = DssExecLib.vow();
        address MCD_POT          = DssExecLib.pot();
        address MCD_SPOT         = DssExecLib.spotter();
        address MCD_END_OLD      = DssExecLib.end();
        address MCD_ESM_OLD      = DssExecLib.getChangelogAddress("MCD_ESM");
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
        DssExecLib.deauthorize(MCD_DOG, MCD_END_OLD);
        DssExecLib.deauthorize(MCD_VOW, MCD_END_OLD);
        DssExecLib.deauthorize(MCD_POT, MCD_END_OLD);
        DssExecLib.deauthorize(MCD_SPOT, MCD_END_OLD);

        // Deauthorize the old END from all the FLIPS
        // Authorize the new END in all the FLIPS
        bytes32[] memory ilks = IlkRegistryAbstract(ILK_REGISTRY).list();
        for (uint256 i = 0; i < ilks.length; i++) {
            bytes32 ilk = ilks[i];
            if (IlkRegistryAbstract(ILK_REGISTRY).class(ilk) < 3) {
                address xlip = IlkRegistryAbstract(ILK_REGISTRY).xlip(ilk);
                DssExecLib.deauthorize(xlip, MCD_END_OLD);
                DssExecLib.authorize(xlip, MCD_END);

                try DssExecLib.addReaderToOSMWhitelist(IlkRegistryAbstract(ILK_REGISTRY).pip(ilk), MCD_END) {} catch {}
                try DssExecLib.removeReaderFromOSMWhitelist(IlkRegistryAbstract(ILK_REGISTRY).pip(ilk), MCD_END_OLD) {} catch {}
            }
        }

        DssExecLib.deauthorize(MCD_FLIP_LINK_A, MCD_END_OLD);
        DssExecLib.authorize(MCD_FLIP_LINK_A, MCD_END);

        DssExecLib.addReaderToOSMWhitelist(PIP_LINK, MCD_END);
        DssExecLib.removeReaderFromOSMWhitelist(PIP_LINK, MCD_END_OLD);

        // ------------------  ESM  ------------------

        require(ESMAbstract(MCD_ESM).min() == 75_000 * WAD, "DssSpell/error-esm-min");
        require(ESMAbstract(MCD_ESM).end() == MCD_END, "DssSpell/error-esm-end");
        require(ESMAbstract(MCD_ESM).gem() == DssExecLib.getChangelogAddress("MCD_GOV"), "DssSpell/error-esm-gov");
        require(ESMAbstract(MCD_ESM).proxy() == address(this), "DssSpell/error-esm-proxy");

        // Authorize new ESM to execute in new END
        DssExecLib.authorize(MCD_END, MCD_ESM);

        // Authorize new ESM to execute in VAT
        DssExecLib.authorize(MCD_VAT, MCD_ESM);

        // Deauthorize old ESM to execute in VAT
        DssExecLib.deauthorize(MCD_VAT, MCD_ESM_OLD);

        // Make every flipper relies the MCD_ESM and denies the MCD_ESM_OLD
        for (uint256 i = 0; i < ilks.length; i++) {
            bytes32 ilk = ilks[i];
            if (IlkRegistryAbstract(ILK_REGISTRY).class(ilk) < 3) {
                address xlip = IlkRegistryAbstract(ILK_REGISTRY).xlip(ilk);
                DssExecLib.authorize(xlip, MCD_ESM);
                DssExecLib.deauthorize(xlip, MCD_ESM_OLD);
            }
        }

        DssExecLib.deauthorize(MCD_FLIP_LINK_A, MCD_ESM_OLD);
        DssExecLib.authorize(MCD_FLIP_LINK_A, MCD_ESM);
        
        // ------------------  CHAINLOG  -----------------
        
        DssExecLib.setChangelogAddress("MCD_END", MCD_END);
        DssExecLib.setChangelogAddress("MCD_ESM", MCD_ESM);
        DssExecLib.setChangelogAddress("ILK_REGISTRY", ILK_REGISTRY);
    }

}

contract DssSpell is DssExec {
    DssSpellAction internal action_ = new DssSpellAction();
    constructor() DssExec(action_.description(), block.timestamp + 30 days, address(action_)) public {}
}
