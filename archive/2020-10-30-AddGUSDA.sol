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
import "lib/dss-interfaces/src/dss/CatAbstract.sol";
import "lib/dss-interfaces/src/dss/FlipAbstract.sol";
import "lib/dss-interfaces/src/dss/IlkRegistryAbstract.sol";
import "lib/dss-interfaces/src/dss/GemJoinAbstract.sol";
import "lib/dss-interfaces/src/dss/JugAbstract.sol";
import "lib/dss-interfaces/src/dss/MedianAbstract.sol";
import "lib/dss-interfaces/src/dss/OsmAbstract.sol";
import "lib/dss-interfaces/src/dss/OsmMomAbstract.sol";
import "lib/dss-interfaces/src/dss/SpotAbstract.sol";
import "lib/dss-interfaces/src/dss/VatAbstract.sol";
import "lib/dss-interfaces/src/dss/FaucetAbstract.sol";
import "lib/dss-interfaces/src/dss/FlipperMomAbstract.sol";

contract SpellAction {
    // KOVAN ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    //  against the current release list at:
    //     https://changelog.makerdao.com/releases/kovan/1.1.3/contracts.json

    address constant MCD_VAT      = 0xbA987bDB501d131f766fEe8180Da5d81b34b69d9;
    address constant MCD_CAT      = 0xdDb5F7A3A5558b9a6a1f3382BD75E2268d1c6958;
    address constant MCD_JUG      = 0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD;
    address constant MCD_SPOT     = 0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D;
    address constant MCD_POT      = 0xEA190DBDC7adF265260ec4dA6e9675Fd4f5A78bb;
    address constant MCD_END      = 0x24728AcF2E2C403F5d2db4Df6834B8998e56aA5F;
    address constant FLIPPER_MOM  = 0x50dC6120c67E456AdA2059cfADFF0601499cf681;
    address constant OSM_MOM      = 0x5dA9D1C3d4f1197E5c52Ff963916Fe84D2F5d8f3;
    address constant ILK_REGISTRY = 0xedE45A0522CA19e979e217064629778d6Cc2d9Ea;

    address constant FAUCET       = 0x57aAeAE905376a4B1899bA81364b4cE2519CBfB3;

    address constant GUSD            = 0x31D8EdbF6F33ef858c80d68D06Ec83f33c2aA150;
    address constant MCD_JOIN_GUSD_A = 0xC32fb81a573C1DAC509443e86759330f893dA8bD;
    address constant MCD_FLIP_GUSD_A = 0xf6c0e36a76F2B9F7Bd568155F3fDc53ff1be1Aeb;
    address constant PIP_GUSD        = 0xb6630DE6Eda0f3f3d96Db4639914565d6b82CfEF;

    uint256 constant THOUSAND = 10**3;
    uint256 constant MILLION = 10**6;
    uint256 constant WAD = 10**18;
    uint256 constant RAY = 10**27;
    uint256 constant RAD = 10**45;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    uint256 constant FOUR_PERCENT_RATE = 1000000001243680656318820312;

    function execute() external {
        bytes32 ilk = "GUSD-A";

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_GUSD_A).vat() == MCD_VAT, "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_GUSD_A).ilk() == ilk, "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_GUSD_A).gem() == GUSD, "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_GUSD_A).dec() == 2, "join-dec-not-match");
        require(FlipAbstract(MCD_FLIP_GUSD_A).vat() == MCD_VAT, "flip-vat-not-match");
        require(FlipAbstract(MCD_FLIP_GUSD_A).cat() == MCD_CAT, "flip-cat-not-match");
        require(FlipAbstract(MCD_FLIP_GUSD_A).ilk() == ilk, "flip-ilk-not-match");

        // Set the GUSD PIP in the Spotter
        SpotAbstract(MCD_SPOT).file(ilk, "pip", PIP_GUSD);

        // Set the GUSD-A Flipper in the Cat
        CatAbstract(MCD_CAT).file(ilk, "flip", MCD_FLIP_GUSD_A);

        // Init GUSD-A ilk in Vat & Jug
        VatAbstract(MCD_VAT).init(ilk);
        JugAbstract(MCD_JUG).init(ilk);

        // Allow GUSD-A Join to modify Vat registry
        VatAbstract(MCD_VAT).rely(MCD_JOIN_GUSD_A);
        // Allow the GUSD-A Flipper to reduce the Cat litterbox on deal()
        CatAbstract(MCD_CAT).rely(MCD_FLIP_GUSD_A);
        // Allow Cat to kick auctions in GUSD-A Flipper
        FlipAbstract(MCD_FLIP_GUSD_A).rely(MCD_CAT);
        // Allow End to yank auctions in GUSD-A Flipper
        FlipAbstract(MCD_FLIP_GUSD_A).rely(MCD_END);
        // Allow FlipperMom to access to the GUSD-A Flipper
        FlipAbstract(MCD_FLIP_GUSD_A).rely(FLIPPER_MOM);
        // Disallow Cat to kick auctions in GUSD-A Flipper
        // !!!!!!!! Only for certain collaterals that do not trigger liquidations like USDC-A)
        FlipperMomAbstract(FLIPPER_MOM).deny(MCD_FLIP_GUSD_A);

        // Allow OsmMom to access to the GUSD Osm
        // !!!!!!!! Only if PIP_GUSD = Osm and hasn't been already relied due a previous deployed ilk
        //OsmAbstract(PIP_GUSD).rely(OSM_MOM);
        // Whitelist Osm to read the Median data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_GUSD = Osm, its src is a Median and hasn't been already whitelisted due a previous deployed ilk
        //MedianAbstract(OsmAbstract(PIP_GUSD).src()).kiss(PIP_GUSD);
        // Whitelist Spotter to read the Osm data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_GUSD = Osm or PIP_GUSD = Median and hasn't been already whitelisted due a previous deployed ilk
        //OsmAbstract(PIP_GUSD).kiss(MCD_SPOT);
        // Whitelist End to read the Osm data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_GUSD = Osm or PIP_GUSD = Median and hasn't been already whitelisted due a previous deployed ilk
        //OsmAbstract(PIP_GUSD).kiss(MCD_END);
        // Set GUSD Osm in the OsmMom for new ilk
        // !!!!!!!! Only if PIP_GUSD = Osm
        //OsmMomAbstract(OSM_MOM).setOsm(ilk, PIP_GUSD);

        // Set the global debt ceiling
        VatAbstract(MCD_VAT).file("Line", 1232 * MILLION * RAD);
        // Set the GUSD-A debt ceiling
        VatAbstract(MCD_VAT).file(ilk, "line", 5 * MILLION * RAD);
        // Set the GUSD-A dust
        VatAbstract(MCD_VAT).file(ilk, "dust", 100 * RAD);
        // Set the Lot size
        CatAbstract(MCD_CAT).file(ilk, "dunk", 500 * RAD);
        // Set the GUSD-A liquidation penalty (e.g. 13% => X = 113)
        CatAbstract(MCD_CAT).file(ilk, "chop", 113 * WAD / 100);
        // Set the GUSD-A stability fee (e.g. 1% = 1000000000315522921573372069)
        JugAbstract(MCD_JUG).file(ilk, "duty", FOUR_PERCENT_RATE);
        // Set the GUSD-A percentage between bids (e.g. 3% => X = 103)
        FlipAbstract(MCD_FLIP_GUSD_A).file("beg", 103 * WAD / 100);
        // Set the GUSD-A time max time between bids
        FlipAbstract(MCD_FLIP_GUSD_A).file("ttl", 1 hours);
        // Set the GUSD-A max auction duration to
        FlipAbstract(MCD_FLIP_GUSD_A).file("tau", 1 hours);
        // Set the GUSD-A min collateralization ratio (e.g. 150% => X = 150)
        SpotAbstract(MCD_SPOT).file(ilk, "mat", 101 * RAY / 100);

        // Update GUSD-A spot value in Vat
        SpotAbstract(MCD_SPOT).poke(ilk);

        // Add new ilk to the IlkRegistry
        IlkRegistryAbstract(ILK_REGISTRY).add(MCD_JOIN_GUSD_A);

        // Set gulp amount in faucet on kovan
        FaucetAbstract(FAUCET).setAmt(GUSD, 100000);
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
