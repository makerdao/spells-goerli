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
import "lib/dss-interfaces/src/dss/FlipAbstract.sol";

contract SpellAction {
    // KOVAN ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    // against the current release list at:
    //     https://changelog.makerdao.com/releases/kovan/1.1.1/contracts.json

    // USDT flip
    address constant MCD_FLIP_USDT_A   = 0x113733e00804e61D5fd8b107Ca11b4569B6DA95D;

    // PAXUSD flip
    address constant MCD_FLIP_PAXUSD_A = 0x88001b9C8192cbf43e14323B809Ae6C4e815E12E;

    // Decimals & precision
    uint256 constant THOUSAND = 10 ** 3;
    uint256 constant MILLION  = 10 ** 6;
    uint256 constant WAD      = 10 ** 18;
    uint256 constant RAY      = 10 ** 27;
    uint256 constant RAD      = 10 ** 45;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    uint256 constant TWO_PCT_RATE   = 1000000000627937192491029810;
    uint256 constant SIX_PCT_RATE   = 1000000001847694957439350562;

    function execute() external {
        // set USDT flipper ttl & tau
        // prev ttl/tau: 6 hours
        // new tt/tau: 1 hour
        FlipAbstract(MCD_FLIP_USDT_A).file(     "ttl" , 1 hours    ); // 1 hours ttl
        FlipAbstract(MCD_FLIP_USDT_A).file(     "tau" , 1 hours    ); // 1 hours tau

        // set PAXUSD flipper ttl & tau to 1 hour
        // prev ttl/tau: 6 hours
        // new tt/tau: 1 hour
        FlipAbstract(MCD_FLIP_PAXUSD_A).file(   "ttl"   , 1 hours  ); // 1 hours ttl
        FlipAbstract(MCD_FLIP_PAXUSD_A).file(   "tau"   , 1 hours  ); // 1 hours tau
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
    }

    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}
