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
import "lib/dss-interfaces/src/dss/VatAbstract.sol";
import "lib/dss-interfaces/src/dss/CatAbstract.sol";
import "lib/dss-interfaces/src/dss/JugAbstract.sol";
import "lib/dss-interfaces/src/dss/FlipAbstract.sol";
import "lib/dss-interfaces/src/dss/SpotAbstract.sol";
import "lib/dss-interfaces/src/dss/OsmAbstract.sol";
import "lib/dss-interfaces/src/dss/OsmMomAbstract.sol";
import "lib/dss-interfaces/src/dss/MedianAbstract.sol";
import "lib/dss-interfaces/src/dss/GemJoinAbstract.sol";
import "lib/dss-interfaces/src/dss/FlipperMomAbstract.sol";
import "lib/dss-interfaces/src/dss/IlkRegistryAbstract.sol";

contract SpellAction {
    // KOVAN ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    // against the current release list at:
    //     https://changelog.makerdao.com/releases/kovan/1.0.9/contracts.json
    address constant MCD_VAT             = 0xbA987bDB501d131f766fEe8180Da5d81b34b69d9;
    address constant MCD_CAT             = 0xdDb5F7A3A5558b9a6a1f3382BD75E2268d1c6958;
    address constant MCD_JUG             = 0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD;
    address constant MCD_SPOT            = 0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D;
    address constant MCD_END             = 0x24728AcF2E2C403F5d2db4Df6834B8998e56aA5F;
    address constant FLIPPER_MOM         = 0x50dC6120c67E456AdA2059cfADFF0601499cf681;
    address constant OSM_MOM             = 0x5dA9D1C3d4f1197E5c52Ff963916Fe84D2F5d8f3;
    address constant ILK_REGISTRY        = 0xedE45A0522CA19e979e217064629778d6Cc2d9Ea;

    // USDT-A TODO: update
    address constant USDT                = 0x9245BD36FA20fcD292F4765c4b5dF83Dc3fD5e86;
    address constant MCD_JOIN_USDT_A     = 0x9B011a74a690dFd9a1e4996168d3EcBDE73c2226;
    address constant MCD_FLIP_USDT_A     = 0x113733e00804e61D5fd8b107Ca11b4569B6DA95D;
    address constant PIP_USDT            = 0x3588A7973D41AaeA7B203549553C991C4311951e;

    // PAXUSD specific addresses
    address constant PAXUSD              = 0xa6383AF46c36219a472b9549d70E4768dfA8894c;
    address constant MCD_JOIN_PAXUSD_A   = 0x3d6a14C9542B429a4e3d255F6687754d4898D897;
    address constant MCD_FLIP_PAXUSD_A   = 0x88001b9C8192cbf43e14323B809Ae6C4e815E12E;
    address constant PIP_PAXUSD          = 0xD01fefed46eb21cd057bAa14Ff466842C31a0Cd9;

    // Decimals & precision
    uint256 constant THOUSAND = 10 ** 3;
    uint256 constant MILLION  = 10 ** 6;
    uint256 constant WAD      = 10 ** 18;
    uint256 constant RAY      = 10 ** 27;
    uint256 constant RAD      = 10 ** 45;

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    uint256 constant FOUR_PCT_RATE    = 1000000001243680656318820312;
    uint256 constant EIGHT_PCT_RATE   = 1000000002440418608258400030;

    function execute() external {
        VatAbstract(MCD_VAT).file("Line", VatAbstract(MCD_VAT).Line() + 15 * MILLION * RAD);

        ////////////////////////////////////////////////////////////////////////////////
        // USDT-A collateral deploy

        // Set ilk bytes32 variable
        bytes32 ilkUSDTA = "USDT-A";

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_USDT_A).vat() == MCD_VAT,  "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_USDT_A).ilk() == ilkUSDTA, "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_USDT_A).gem() == USDT,     "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_USDT_A).dec() == 6,        "join-dec-not-match");
        require(FlipAbstract(MCD_FLIP_USDT_A).vat()    == MCD_VAT,  "flip-vat-not-match");
        require(FlipAbstract(MCD_FLIP_USDT_A).ilk()    == ilkUSDTA, "flip-ilk-not-match");

        // Set price feed for USDT-A
        SpotAbstract(MCD_SPOT).file(ilkUSDTA, "pip", PIP_USDT);

        // Set the USDT-A flipper in the cat
        CatAbstract(MCD_CAT).file(ilkUSDTA, "flip", MCD_FLIP_USDT_A);

        // Init USDT-A in Vat
        VatAbstract(MCD_VAT).init(ilkUSDTA);
        // Init USDT-A in Jug
        JugAbstract(MCD_JUG).init(ilkUSDTA);

        // Allow USDT-A Join to modify Vat registry
        VatAbstract(MCD_VAT).rely(MCD_JOIN_USDT_A);

        // Allow cat to kick auctions in USDT-A Flipper
        FlipAbstract(MCD_FLIP_USDT_A).rely(MCD_CAT);

        // Allow End to yank auctions in USDT-A Flipper
        FlipAbstract(MCD_FLIP_USDT_A).rely(MCD_END);

        // Allow FlipperMom to access the USDT-A Flipper
        FlipAbstract(MCD_FLIP_USDT_A).rely(FLIPPER_MOM);

        // Update OSM
        OsmAbstract(PIP_USDT).rely(OSM_MOM);
        MedianAbstract(OsmAbstract(PIP_USDT).src()).kiss(PIP_USDT);
        OsmAbstract(PIP_USDT).kiss(MCD_SPOT);
        OsmAbstract(PIP_USDT).kiss(MCD_END);
        OsmMomAbstract(OSM_MOM).setOsm(ilkUSDTA, PIP_USDT);

        // since we're adding 2 collateral types in this spell, global line is at beginning
        VatAbstract(MCD_VAT).file( ilkUSDTA, "line", 10 * MILLION * RAD   ); // 10m debt ceiling
        VatAbstract(MCD_VAT).file( ilkUSDTA, "dust", 100 * RAD            ); // 100 Dai dust
        CatAbstract(MCD_CAT).file( ilkUSDTA, "dunk", 500 * RAD            ); // 50,000 dunk
        CatAbstract(MCD_CAT).file( ilkUSDTA, "chop", 113 * WAD / 100      ); // 13% liq. penalty
        JugAbstract(MCD_JUG).file( ilkUSDTA, "duty", EIGHT_PCT_RATE       ); // 8% stability fee

        FlipAbstract(MCD_FLIP_USDT_A).file(  "beg" , 103 * WAD / 100      ); // 3% bid increase
        FlipAbstract(MCD_FLIP_USDT_A).file(  "ttl" , 6 hours              ); // 6 hours ttl
        FlipAbstract(MCD_FLIP_USDT_A).file(  "tau" , 6 hours              ); // 6 hours tau

        SpotAbstract(MCD_SPOT).file(ilkUSDTA, "mat",  150 * RAY / 100     ); // 150% coll. ratio
        SpotAbstract(MCD_SPOT).poke(ilkUSDTA);

        IlkRegistryAbstract(ILK_REGISTRY).add(MCD_JOIN_USDT_A);

        ////////////////////////////////////////////////////////////////////////////////
        // PAXUSD-A collateral deploy
        // Set ilk bytes32 variable
        bytes32 ilkPAXUSDA = "PAXUSD-A";

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_PAXUSD_A).vat() == MCD_VAT,    "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_PAXUSD_A).ilk() == ilkPAXUSDA, "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_PAXUSD_A).gem() == PAXUSD,     "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_PAXUSD_A).dec() == 18,         "join-dec-not-match");
        require(FlipAbstract(MCD_FLIP_PAXUSD_A).vat()    == MCD_VAT,    "flip-vat-not-match");
        require(FlipAbstract(MCD_FLIP_PAXUSD_A).ilk()    == ilkPAXUSDA, "flip-ilk-not-match");

        // Set price feed for PAXUSD-A
        SpotAbstract(MCD_SPOT).file(ilkPAXUSDA, "pip", PIP_PAXUSD);

        // Set the PAXUSD-A flipper in the cat
        CatAbstract(MCD_CAT).file(ilkPAXUSDA, "flip", MCD_FLIP_PAXUSD_A);

        // Init PAXUSD-A in Vat
        VatAbstract(MCD_VAT).init(ilkPAXUSDA);
        // Init PAXUSD-A in Jug
        JugAbstract(MCD_JUG).init(ilkPAXUSDA);

        // Allow PAXUSD-A Join to modify Vat registry
        VatAbstract(MCD_VAT).rely(MCD_JOIN_PAXUSD_A);

        // Allow cat to kick auctions in PAXUSD-A Flipper
        // NOTE: this will be reverse later in spell, and is done only for explicitness.
        FlipAbstract(MCD_FLIP_PAXUSD_A).rely(MCD_CAT);

        // Allow End to yank auctions in PAXUSD-A Flipper
        FlipAbstract(MCD_FLIP_PAXUSD_A).rely(MCD_END);

        // Allow FlipperMom to access the PAXUSD-A Flipper
        FlipAbstract(MCD_FLIP_PAXUSD_A).rely(FLIPPER_MOM);

        // TODO: update these, we still don't have variables yet
        VatAbstract(MCD_VAT).file(ilkPAXUSDA,   "line"  , 5 * MILLION * RAD    ); // 5 MM debt ceiling
        VatAbstract(MCD_VAT).file(ilkPAXUSDA,   "dust"  , 100 * RAD            ); // 100 Dai dust
        CatAbstract(MCD_CAT).file(ilkPAXUSDA,   "dunk"  , 500 * RAD            ); // 50,000 dunk
        CatAbstract(MCD_CAT).file(ilkPAXUSDA,   "chop"  , 113 * WAD / 100      ); // 13% liq. penalty
        JugAbstract(MCD_JUG).file(ilkPAXUSDA,   "duty"  , FOUR_PCT_RATE        ); // 4% stability fee
        FlipAbstract(MCD_FLIP_PAXUSD_A).file(   "beg"   , 103 * WAD / 100      ); // 3% bid increase
        FlipAbstract(MCD_FLIP_PAXUSD_A).file(   "ttl"   , 6 hours              ); // 6 hours ttl
        FlipAbstract(MCD_FLIP_PAXUSD_A).file(   "tau"   , 6 hours              ); // 6 hours tau
        SpotAbstract(MCD_SPOT).file(ilkPAXUSDA, "mat"   , 120 * RAY / 100      ); // 120% coll. ratio
        SpotAbstract(MCD_SPOT).poke(ilkPAXUSDA);

        IlkRegistryAbstract(ILK_REGISTRY).add(MCD_JOIN_PAXUSD_A);

        // Consequently, deny PAXUSD-A Flipper
        FlipperMomAbstract(FLIPPER_MOM).deny(MCD_FLIP_PAXUSD_A);
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

    modifier officeHours {
        uint day = (now / 1 days + 3) % 7;
        require(day < 5, "Can only be cast on a weekday");
        uint hour = now / 1 hours % 24;
        require(hour >= 14 && hour < 21, "Outside office hours");
        _;
    }

    function schedule() public {
        require(now <= expiration, "This contract has expired");
        require(eta == 0, "This spell has already been scheduled");
        eta = now + DSPauseAbstract(pause).delay();
        pause.plot(action, tag, sig, eta);
    }

    // TODO: removing office hours for kovan deploy, fix for mainnet
    function cast() public /*officeHours*/ {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}
