// Copyright (C) 2020 Maker Ecosystem Growth Holdings, INC.
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

pragma solidity 0.5.12;

import "lib/dss-interfaces/src/dapp/DSPauseAbstract.sol";
import "lib/dss-interfaces/src/dapp/DSAuthorityAbstract.sol";
import "lib/dss-interfaces/src/dss/OsmMomAbstract.sol";
import "lib/dss-interfaces/src/dss/FlipperMomAbstract.sol";
import "lib/dss-interfaces/src/dss/ChainlogAbstract.sol";


contract SpellAction {
    // KOVAN ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    //  against the current release list at:
    //     https://changelog.makerdao.com/releases/kovan/active/contracts.json

    ChainlogAbstract constant CHANGELOG = ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);

    address constant MCD_ADM            = 0x27E0c9567729Ea6e3241DE74B3dE499b7ddd3fe6;
    address constant VOTE_PROXY_FACTORY = 0x1400798AA746457E467A1eb9b3F3f72C25314429;

    function execute() external {
        address MCD_PAUSE   = CHANGELOG.getAddress("MCD_PAUSE");
        address FLIPPER_MOM = CHANGELOG.getAddress("FLIPPER_MOM");
        address OSM_MOM     = CHANGELOG.getAddress("OSM_MOM");

        // Change MCD_ADM address in the changelog (Chief)
        CHANGELOG.setAddress("MCD_ADM", MCD_ADM);

        // Add VOTE_PROXY_FACTORY to the changelog (previous one was missing)
        CHANGELOG.setAddress("VOTE_PROXY_FACTORY", VOTE_PROXY_FACTORY);

        // Bump version
        CHANGELOG.setVersion("1.2.0");

        // Set new Chief in the Pause
        DSPauseAbstract(MCD_PAUSE).setAuthority(MCD_ADM);

        // Set new Chief in the FlipperMom
        FlipperMomAbstract(FLIPPER_MOM).setAuthority(MCD_ADM);

        // Set new Chief in the OsmMom
        OsmMomAbstract(OSM_MOM).setAuthority(MCD_ADM);
    }
}

contract DssSpell {
    ChainlogAbstract constant CHANGELOG = ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);
    DSPauseAbstract public pause =
        DSPauseAbstract(CHANGELOG.getAddress("MCD_PAUSE"));

    address constant SAI_MOM = 0x72Ee9496b0867Dfe5E8B280254Da55e51E34D27b;
    address constant SAI_TOP = 0x5f00393547561DA3030ebF30e52F5DC0D5D3362c;

    address         public action;
    bytes32         public tag;
    uint256         public eta;
    bytes           public sig;
    uint256         public expiration;
    bool            public done;

    string constant public description = "Kovan Spell Deploy";

    constructor() public {
        sig = abi.encodeWithSignature("execute()");
        action = address(new SpellAction());
        bytes32 _tag;
        address _action = action;
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
        expiration = now + 30 days;
    }

    function schedule() public {
        require(now <= expiration, "This contract has expired");
        require(eta == 0, "This spell has already been scheduled");
        eta = now + DSPauseAbstract(pause).delay();
        pause.plot(action, tag, sig, eta);

        DSAuthAbstract(SAI_MOM).setAuthority(address(0));
        DSAuthAbstract(SAI_TOP).setAuthority(address(0));
    }

    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}
