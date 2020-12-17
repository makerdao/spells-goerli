// SPDX-License-Identifier: GPL-3.0-or-later

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

pragma solidity 0.6.11;

import "lib/dss-interfaces/src/dapp/DSPauseAbstract.sol";
import "lib/dss-interfaces/src/dapp/DSTokenAbstract.sol";
import "lib/dss-interfaces/src/dss/ChainlogAbstract.sol";
import "lib/dss-interfaces/src/dss/VatAbstract.sol";
import "lib/dss-interfaces/src/dss/SpotAbstract.sol";
import "lib/dss-interfaces/src/dss/FlipAbstract.sol";
import "lib/dss-interfaces/src/dss/JugAbstract.sol";
import "lib/dss-interfaces/src/dss/CatAbstract.sol";
import "lib/dss-interfaces/src/dss/IlkRegistryAbstract.sol";
import "lib/dss-interfaces/src/dss/FaucetAbstract.sol";
import "lib/dss-interfaces/src/dss/GemJoinAbstract.sol";
import "lib/dss-interfaces/src/dss/OsmAbstract.sol";
import "lib/dss-interfaces/src/dss/LPOsmAbstract.sol";
import "lib/dss-interfaces/src/dss/OsmMomAbstract.sol";
import "lib/dss-interfaces/src/dss/MedianAbstract.sol";
import "lib/dss-interfaces/src/dss/DssAutoLineAbstract.sol";


contract SpellAction {
    // KOVAN ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    //  against the current release list at:
    //     https://changelog.makerdao.com/releases/kovan/active/contracts.json
    ChainlogAbstract constant CHANGELOG =
        ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);

    // AAVE-A
    address constant AAVE                   = 0x7B339a530Eed72683F56868deDa87BbC64fD9a12;
    address constant MCD_JOIN_AAVE_A        = 0x9f1Ed3219035e6bDb19E0D95d316c7c39ad302EC;
    address constant MCD_FLIP_AAVE_A        = 0x3c84d572749096b67e4899A95430201DF79b8403;
    address constant PIP_AAVE               = 0xd2d9B1355Ea96567E7D6C7A6945f5c7ec8150Cc9;
    bytes32 constant ILK_AAVE_A             = "AAVE-A";

    address constant UNIV2DAIETH            = 0xB10cf58E08b94480fCb81d341A63295eBb2062C2;
    address constant MCD_JOIN_UNIV2DAIETH_A = 0x03f18d97D25c13FecB15aBee143276D3bD2742De;
    address constant MCD_FLIP_UNIV2DAIETH_A = 0x0B6C3512C8D4300d566b286FC4a554dAC217AaA6;
    address constant PIP_UNIV2DAIETH        = 0x1AE7D6891a5fdAafAd2FE6D894bffEa48F8b2454;
    bytes32 constant ILK_UNIV2DAIETH_A      = "UNIV2DAIETH-A";

    // decimals & precision
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
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmefQMseb3AiTapiAKKexdKHig8wroKuZbmLtPLv4u2YwW
    //
    uint256 constant ONE_PERCENT_RATE   = 1000000000315522921573372069;
    uint256 constant SIX_PERCENT_RATE   = 1000000001847694957439350562;

    function execute() external {
        address MCD_VAT      = CHANGELOG.getAddress("MCD_VAT");
        address MCD_CAT      = CHANGELOG.getAddress("MCD_CAT");
        address MCD_JUG      = CHANGELOG.getAddress("MCD_JUG");
        address MCD_SPOT     = CHANGELOG.getAddress("MCD_SPOT");
        address MCD_END      = CHANGELOG.getAddress("MCD_END");
        address FLIPPER_MOM  = CHANGELOG.getAddress("FLIPPER_MOM");
        address OSM_MOM      = CHANGELOG.getAddress("OSM_MOM"); // Only if PIP_TOKEN = Osm
        address ILK_REGISTRY = CHANGELOG.getAddress("ILK_REGISTRY");
        address FAUCET       = CHANGELOG.getAddress("FAUCET");

        // Set the global debt ceiling
        // + 20 M to fix an error introduced in previous spell not counting the previous 20M of ETH-B (before introducing IAM)
        // + 10 M for AAVE-A
        // +  3 M for UNIV2DAIETH-A
        VatAbstract(MCD_VAT).file("Line", VatAbstract(MCD_VAT).Line() + 20 * MILLION * RAD + 10 * MILLION * RAD + 3 * MILLION * RAD);

        //
        // Add Aave
        //

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_AAVE_A).vat() == MCD_VAT, "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_AAVE_A).ilk() == ILK_AAVE_A, "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_AAVE_A).gem() == AAVE, "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_AAVE_A).dec() == DSTokenAbstract(AAVE).decimals(), "join-dec-not-match");
        require(FlipAbstract(MCD_FLIP_AAVE_A).vat() == MCD_VAT, "flip-vat-not-match");
        require(FlipAbstract(MCD_FLIP_AAVE_A).cat() == MCD_CAT, "flip-cat-not-match");
        require(FlipAbstract(MCD_FLIP_AAVE_A).ilk() == ILK_AAVE_A, "flip-ilk-not-match");

        // Set the AAVE PIP in the Spotter
        SpotAbstract(MCD_SPOT).file(ILK_AAVE_A, "pip", PIP_AAVE);

        // Set the AAVE-A Flipper in the Cat
        CatAbstract(MCD_CAT).file(ILK_AAVE_A, "flip", MCD_FLIP_AAVE_A);

        // Init AAVE-A ilk in Vat & Jug
        VatAbstract(MCD_VAT).init(ILK_AAVE_A);
        JugAbstract(MCD_JUG).init(ILK_AAVE_A);

        // Allow AAVE-A Join to modify Vat registry
        VatAbstract(MCD_VAT).rely(MCD_JOIN_AAVE_A);
        // Allow the AAVE-A Flipper to reduce the Cat litterbox on deal()
        CatAbstract(MCD_CAT).rely(MCD_FLIP_AAVE_A);
        // Allow Cat to kick auctions in AAVE-A Flipper
        FlipAbstract(MCD_FLIP_AAVE_A).rely(MCD_CAT);
        // Allow End to yank auctions in AAVE-A Flipper
        FlipAbstract(MCD_FLIP_AAVE_A).rely(MCD_END);
        // Allow FlipperMom to access to the AAVE-A Flipper
        FlipAbstract(MCD_FLIP_AAVE_A).rely(FLIPPER_MOM);
        // Disallow Cat to kick auctions in AAVE-A Flipper
        // !!!!!!!! Only for certain collaterals that do not trigger liquidations like USDC-A)
        //FlipperMomAbstract(FLIPPER_MOM).deny(MCD_FLIP_AAVE_A);

        // Allow OsmMom to access to the AAVE Osm
        // !!!!!!!! Only if PIP_AAVE = Osm and hasn't been already relied due a previous deployed ilk
        OsmAbstract(PIP_AAVE).rely(OSM_MOM);
        // Whitelist Osm to read the Median data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_AAVE = Osm, its src is a Median and hasn't been already whitelisted due a previous deployed ilk
        MedianAbstract(OsmAbstract(PIP_AAVE).src()).kiss(PIP_AAVE);
        // Whitelist Spotter to read the Osm data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_AAVE = Osm or PIP_AAVE = Median and hasn't been already whitelisted due a previous deployed ilk
        OsmAbstract(PIP_AAVE).kiss(MCD_SPOT);
        // Whitelist End to read the Osm data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_AAVE = Osm or PIP_AAVE = Median and hasn't been already whitelisted due a previous deployed ilk
        OsmAbstract(PIP_AAVE).kiss(MCD_END);
        // Set AAVE Osm in the OsmMom for new ilk
        // !!!!!!!! Only if PIP_AAVE = Osm
        OsmMomAbstract(OSM_MOM).setOsm(ILK_AAVE_A, PIP_AAVE);

        // Set the AAVE-A debt ceiling
        VatAbstract(MCD_VAT).file(ILK_AAVE_A, "line", 10 * MILLION * RAD);
        // Set the AAVE-A dust
        VatAbstract(MCD_VAT).file(ILK_AAVE_A, "dust", 100 * RAD);
        // Set the Lot size
        CatAbstract(MCD_CAT).file(ILK_AAVE_A, "dunk", 500 * RAD);
        // Set the AAVE-A liquidation penalty (e.g. 13% => X = 113)
        CatAbstract(MCD_CAT).file(ILK_AAVE_A, "chop", 113 * WAD / 100);
        // Set the AAVE-A stability fee (e.g. 1% = 1000000000315522921573372069)
        JugAbstract(MCD_JUG).file(ILK_AAVE_A, "duty", SIX_PERCENT_RATE);
        // Set the AAVE-A percentage between bids (e.g. 3% => X = 103)
        FlipAbstract(MCD_FLIP_AAVE_A).file("beg", 103 * WAD / 100);
        // Set the AAVE-A time max time between bids
        FlipAbstract(MCD_FLIP_AAVE_A).file("ttl", 1 hours);
        // Set the AAVE-A max auction duration to
        FlipAbstract(MCD_FLIP_AAVE_A).file("tau", 1 hours);
        // Set the AAVE-A min collateralization ratio (e.g. 150% => X = 150)
        SpotAbstract(MCD_SPOT).file(ILK_AAVE_A, "mat", 175 * RAY / 100);

        // Update AAVE-A spot value in Vat
        SpotAbstract(MCD_SPOT).poke(ILK_AAVE_A);

        // Add new ilk to the IlkRegistry
        IlkRegistryAbstract(ILK_REGISTRY).add(MCD_JOIN_AAVE_A);

        // Set gulp amount in faucet on kovan (only use WAD for decimals = 18)
        FaucetAbstract(FAUCET).setAmt(AAVE, 2500 * WAD);

        // Update the changelog
        CHANGELOG.setAddress("AAVE", AAVE);
        CHANGELOG.setAddress("MCD_JOIN_AAVE_A", MCD_JOIN_AAVE_A);
        CHANGELOG.setAddress("MCD_FLIP_AAVE_A", MCD_FLIP_AAVE_A);
        CHANGELOG.setAddress("PIP_AAVE", PIP_AAVE);

        //
        // Add UniswapV2 ETH/DAI
        //

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_UNIV2DAIETH_A).vat() == MCD_VAT, "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_UNIV2DAIETH_A).ilk() == ILK_UNIV2DAIETH_A, "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_UNIV2DAIETH_A).gem() == UNIV2DAIETH, "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_UNIV2DAIETH_A).dec() == DSTokenAbstract(UNIV2DAIETH).decimals(), "join-dec-not-match");
        require(FlipAbstract(MCD_FLIP_UNIV2DAIETH_A).vat() == MCD_VAT, "flip-vat-not-match");
        require(FlipAbstract(MCD_FLIP_UNIV2DAIETH_A).cat() == MCD_CAT, "flip-cat-not-match");
        require(FlipAbstract(MCD_FLIP_UNIV2DAIETH_A).ilk() == ILK_UNIV2DAIETH_A, "flip-ilk-not-match");

        // Set the UNIV2DAIETH PIP in the Spotter
        SpotAbstract(MCD_SPOT).file(ILK_UNIV2DAIETH_A, "pip", PIP_UNIV2DAIETH);

        // Set the UNIV2DAIETH-A Flipper in the Cat
        CatAbstract(MCD_CAT).file(ILK_UNIV2DAIETH_A, "flip", MCD_FLIP_UNIV2DAIETH_A);

        // Init UNIV2DAIETH-A ilk in Vat & Jug
        VatAbstract(MCD_VAT).init(ILK_UNIV2DAIETH_A);
        JugAbstract(MCD_JUG).init(ILK_UNIV2DAIETH_A);

        // Allow UNIV2DAIETH-A Join to modify Vat registry
        VatAbstract(MCD_VAT).rely(MCD_JOIN_UNIV2DAIETH_A);
        // Allow the UNIV2DAIETH-A Flipper to reduce the Cat litterbox on deal()
        CatAbstract(MCD_CAT).rely(MCD_FLIP_UNIV2DAIETH_A);
        // Allow Cat to kick auctions in UNIV2DAIETH-A Flipper
        FlipAbstract(MCD_FLIP_UNIV2DAIETH_A).rely(MCD_CAT);
        // Allow End to yank auctions in UNIV2DAIETH-A Flipper
        FlipAbstract(MCD_FLIP_UNIV2DAIETH_A).rely(MCD_END);
        // Allow FlipperMom to access to the UNIV2DAIETH-A Flipper
        FlipAbstract(MCD_FLIP_UNIV2DAIETH_A).rely(FLIPPER_MOM);
        // Disallow Cat to kick auctions in UNIV2DAIETH-A Flipper
        // !!!!!!!! Only for certain collaterals that do not trigger liquidations like USDC-A)
        //FlipperMomAbstract(FLIPPER_MOM).deny(MCD_FLIP_UNIV2DAIETH_A);

        // Allow OsmMom to access to the UNIV2DAIETH Osm
        // !!!!!!!! Only if PIP_UNIV2DAIETH = Osm and hasn't been already relied due a previous deployed ilk
        LPOsmAbstract(PIP_UNIV2DAIETH).rely(OSM_MOM);
        // Whitelist Osm to read the Median data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_UNIV2DAIETH = Osm, its src is a Median and hasn't been already whitelisted due a previous deployed ilk
        MedianAbstract(LPOsmAbstract(PIP_UNIV2DAIETH).orb1()).kiss(PIP_UNIV2DAIETH);
        // Whitelist Spotter to read the Osm data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_UNIV2DAIETH = Osm or PIP_UNIV2DAIETH = Median and hasn't been already whitelisted due a previous deployed ilk
        LPOsmAbstract(PIP_UNIV2DAIETH).kiss(MCD_SPOT);
        // Whitelist End to read the Osm data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_UNIV2DAIETH = Osm or PIP_UNIV2DAIETH = Median and hasn't been already whitelisted due a previous deployed ilk
        LPOsmAbstract(PIP_UNIV2DAIETH).kiss(MCD_END);
        // Set UNIV2DAIETH Osm in the OsmMom for new ilk
        // !!!!!!!! Only if PIP_UNIV2DAIETH = Osm
        OsmMomAbstract(OSM_MOM).setOsm(ILK_UNIV2DAIETH_A, PIP_UNIV2DAIETH);

        // Set the UNIV2DAIETH-A debt ceiling
        VatAbstract(MCD_VAT).file(ILK_UNIV2DAIETH_A, "line", 3 * MILLION * RAD);
        // Set the UNIV2DAIETH-A dust
        VatAbstract(MCD_VAT).file(ILK_UNIV2DAIETH_A, "dust", 100 * RAD);
        // Set the Lot size
        CatAbstract(MCD_CAT).file(ILK_UNIV2DAIETH_A, "dunk", 500 * RAD);
        // Set the UNIV2DAIETH-A liquidation penalty (e.g. 13% => X = 113)
        CatAbstract(MCD_CAT).file(ILK_UNIV2DAIETH_A, "chop", 113 * WAD / 100);
        // Set the UNIV2DAIETH-A stability fee (e.g. 1% = 1000000000315522921573372069)
        JugAbstract(MCD_JUG).file(ILK_UNIV2DAIETH_A, "duty", ONE_PERCENT_RATE);
        // Set the UNIV2DAIETH-A percentage between bids (e.g. 3% => X = 103)
        FlipAbstract(MCD_FLIP_UNIV2DAIETH_A).file("beg", 103 * WAD / 100);
        // Set the UNIV2DAIETH-A time max time between bids
        FlipAbstract(MCD_FLIP_UNIV2DAIETH_A).file("ttl", 1 hours);
        // Set the UNIV2DAIETH-A max auction duration to
        FlipAbstract(MCD_FLIP_UNIV2DAIETH_A).file("tau", 1 hours);
        // Set the UNIV2DAIETH-A min collateralization ratio (e.g. 150% => X = 150)
        SpotAbstract(MCD_SPOT).file(ILK_UNIV2DAIETH_A, "mat", 125 * RAY / 100);

        // Update UNIV2DAIETH-A spot value in Vat
        SpotAbstract(MCD_SPOT).poke(ILK_UNIV2DAIETH_A);

        // Add new ilk to the IlkRegistry
        IlkRegistryAbstract(ILK_REGISTRY).add(MCD_JOIN_UNIV2DAIETH_A);

        // Set gulp amount in faucet on kovan (only use WAD for decimals = 18) NO FAUCET FOR LP TOKENS
        // FaucetAbstract(FAUCET).setAmt(UNIV2DAIETH, 2500 * WAD);

        // Update the changelog
        CHANGELOG.setAddress("UNIV2DAIETH", UNIV2DAIETH);
        CHANGELOG.setAddress("MCD_JOIN_UNIV2DAIETH_A", MCD_JOIN_UNIV2DAIETH_A);
        CHANGELOG.setAddress("MCD_FLIP_UNIV2DAIETH_A", MCD_FLIP_UNIV2DAIETH_A);
        CHANGELOG.setAddress("PIP_UNIV2DAIETH", PIP_UNIV2DAIETH);

        // Bump version
        CHANGELOG.setVersion("1.2.2");
    }
}

contract DssSpell {
    ChainlogAbstract  constant CHANGELOG =
        ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);
    DSPauseAbstract immutable public pause;
    address         immutable public action;
    bytes32         immutable public tag;
    uint256         immutable public expiration;
    uint256                   public eta;
    bytes                     public sig;
    bool                      public done;

    string   constant public description = "Kovan Spell Deploy";

    constructor() public {
        pause = DSPauseAbstract(CHANGELOG.getAddress("MCD_PAUSE"));
        sig = abi.encodeWithSignature("execute()");
        bytes32 _tag;
        address _action = action = address(new SpellAction());
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
