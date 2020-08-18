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
import "lib/dss-interfaces/src/dss/JugAbstract.sol";
import "lib/dss-interfaces/src/dss/VatAbstract.sol";
import "lib/dss-interfaces/src/dss/VowAbstract.sol";
import "lib/dss-interfaces/src/dss/IlkRegistryAbstract.sol";

contract SpellAction {

    string constant public description = "Kovan Spell Description";

    // KOVAN ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    // against the current release list at:
    //     https://changelog.makerdao.com/releases/kovan/1.0.9/contracts.json

    address constant MCD_VAT      = 0xbA987bDB501d131f766fEe8180Da5d81b34b69d9;
    address constant MCD_JUG      = 0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD;
    address constant MCD_VOW      = 0x0F4Cbe6CBA918b7488C26E29d9ECd7368F38EA3b;
    address constant ILK_REGISTRY = 0x6618BD7bBaBFacC518Fdec43542E4a73629B0819;

    uint256 constant MILLION = 10 ** 6;
    uint256 constant RAD     = 10 ** 45;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 6%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.06)/(60 * 60 * 24 * 365) )'
    //
    uint256 constant SIX_PCT_RATE       = 1000000001847694957439350562;
    uint256 constant FORTYFOUR_PCT_RATE = 1000000011562757347033522598;

    function execute() external {
        bytes32[] memory ilks = IlkRegistryAbstract(ILK_REGISTRY).list();

        for(uint i = 0; i < ilks.length; i++) {
            // Set all ilks dust value from 20 Dai to 100 Dai
            VatAbstract(MCD_VAT).file(ilks[i], "dust", 100 * RAD);
        }

        // Set the MANA-A stability fee
        // value is determined by the rate accumulator calculation (see above)
        //  ex. an 8% annual rate will be 1000000002440418608258400030
        //
        // Existing Rate: 8%
        // New Rate: 6%
        JugAbstract(MCD_JUG).drip("MANA-A");
        JugAbstract(MCD_JUG).file("MANA-A", "duty", SIX_PCT_RATE);

        // Set the USDC-B stability fee
        // value is determined by the rate accumulator calculation (see above)
        //  ex. an 8% annual rate will be 1000000002440418608258400030
        //
        // Existing Rate: 46%
        // New Rate: 44%
        JugAbstract(MCD_JUG).drip("USDC-B");
        JugAbstract(MCD_JUG).file("USDC-B", "duty", FORTYFOUR_PCT_RATE);

        // Sets the system surplus buffer from 500k Dai to 2mm Dai
        VowAbstract(MCD_VOW).file("hump", 2 * MILLION * RAD);
    }
}

contract DssSpell {
    DSPauseAbstract public pause =
        DSPauseAbstract(0x8754E6ecb4fe68DaA5132c2886aB39297a5c7189);
    address         public action;
    bytes32         public tag;
    uint256         public eta;
    bytes           public sig;
    uint256         public expiration;
    bool            public done;

    constructor() public {
        sig = abi.encodeWithSignature("execute()");
        action = address(new SpellAction());
        bytes32 _tag;
        address _action = action;
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
        expiration = now + 30 days;
    }

    function description() public view returns (string memory) {
        return SpellAction(action).description();
    }

    function schedule() public {
        require(now <= expiration, "This contract has expired");
        require(eta == 0, "This spell has already been scheduled");
        eta = now + DSPauseAbstract(pause).delay();
        pause.plot(action, tag, sig, eta);
    }

    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}
