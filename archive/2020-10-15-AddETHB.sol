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

interface FaucetAbstract {
    function setAmt(address, uint256) external;
}

contract SpellAction {
    // KOVAN ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    //  against the current release list at:
    //     https://changelog.makerdao.com/releases/kovan/1.1.2/contracts.json

    address constant MCD_VAT         = 0xbA987bDB501d131f766fEe8180Da5d81b34b69d9;
    address constant MCD_CAT         = 0xdDb5F7A3A5558b9a6a1f3382BD75E2268d1c6958;
    address constant MCD_JUG         = 0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD;
    address constant MCD_SPOT        = 0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D;
    address constant MCD_POT         = 0xEA190DBDC7adF265260ec4dA6e9675Fd4f5A78bb;
    address constant MCD_END         = 0x24728AcF2E2C403F5d2db4Df6834B8998e56aA5F;
    address constant FLIPPER_MOM     = 0x50dC6120c67E456AdA2059cfADFF0601499cf681;
    address constant OSM_MOM         = 0x5dA9D1C3d4f1197E5c52Ff963916Fe84D2F5d8f3;
    address constant ILK_REGISTRY    = 0xedE45A0522CA19e979e217064629778d6Cc2d9Ea;
    address constant FAUCET          = 0x57aAeAE905376a4B1899bA81364b4cE2519CBfB3;

    // ETH-B specific addresses
    //   > seth --to-bytes32 $(seth --from-ascii "ETH-B")
    //   0x4554482d42000000000000000000000000000000000000000000000000000000
    address constant ETH            = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;
    address constant MCD_JOIN_ETH_B = 0xd19A770F00F89e6Dd1F12E6D6E6839b95C084D85;
    address constant MCD_FLIP_ETH_B = 0x360e15d419c14f6060c88Ac0741323C37fBfDa2D;
    address constant PIP_ETH        = 0x75dD74e8afE8110C8320eD397CcCff3B8134d981; // OSM



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
    // $ bc -l <<< 'scale=27; e( l(1.01)/(60 * 60 * 24 * 365) )'
    //
    uint256 constant    SIX_PERCENT_RATE = 1000000001847694957439350562;

    function execute() external {
        /*** ETH-B Collateral Onboarding ***/
        bytes32 ilk = "ETH-B";

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_ETH_B).vat() == MCD_VAT, "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_ETH_B).ilk() == ilk, "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_ETH_B).gem() == ETH, "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_ETH_B).dec() == 18, "join-dec-not-match");
        require(FlipAbstract(MCD_FLIP_ETH_B).vat() == MCD_VAT, "flip-vat-not-match");
        require(FlipAbstract(MCD_FLIP_ETH_B).cat() == MCD_CAT, "flip-cat-not-match");
        require(FlipAbstract(MCD_FLIP_ETH_B).ilk() == ilk, "flip-ilk-not-match");

        // Set the TOKEN PIP in the Spotter
        SpotAbstract(MCD_SPOT).file(ilk, "pip", PIP_ETH);

        // Set the TOKEN-LETTER Flipper in the Cat
        CatAbstract(MCD_CAT).file(ilk, "flip", MCD_FLIP_ETH_B);

        // Init TOKEN-LETTER ilk in Vat & Jug
        VatAbstract(MCD_VAT).init(ilk);
        JugAbstract(MCD_JUG).init(ilk);

        // Allow TOKEN-LETTER Join to modify Vat registry
        VatAbstract(MCD_VAT).rely(MCD_JOIN_ETH_B);
        // Allow the TOKEN-LETTER Flipper to reduce the Cat litterbox on deal()
        CatAbstract(MCD_CAT).rely(MCD_FLIP_ETH_B);
        // Allow Cat to kick auctions in TOKEN-LETTER Flipper
        FlipAbstract(MCD_FLIP_ETH_B).rely(MCD_CAT);
        // Allow End to yank auctions in TOKEN-LETTER Flipper
        FlipAbstract(MCD_FLIP_ETH_B).rely(MCD_END);
        // Allow FlipperMom to access to the TOKEN-LETTER Flipper
        FlipAbstract(MCD_FLIP_ETH_B).rely(FLIPPER_MOM);
        // Disallow Cat to kick auctions in TOKEN-LETTER Flipper
        // !!!!!!!! Only for certain collaterals that do not trigger liquidations like USDC-A)
        //FlipperMomAbstract(FLIPPER_MOM).deny(MCD_FLIP_ETH_B);

        // Allow OsmMom to access to the TOKEN Osm
        // !!!!!!!! Only if PIP_TOKEN = Osm and hasn't been already relied due a previous deployed ilk
        //OsmAbstract(PIP_TOKEN).rely(OSM_MOM);
        // Whitelist Osm to read the Median data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_TOKEN = Osm, its src is a Median and hasn't been already whitelisted due a previous deployed ilk
        //MedianAbstract(OsmAbstract(PIP_TOKEN).src()).kiss(PIP_TOKEN);
        // Whitelist Spotter to read the Osm data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_TOKEN = Osm or PIP_TOKEN = Median and hasn't been already whitelisted due a previous deployed ilk
        //OsmAbstract(PIP_TOKEN).kiss(MCD_SPOT);
        // Whitelist End to read the Osm data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_TOKEN = Osm or PIP_TOKEN = Median and hasn't been already whitelisted due a previous deployed ilk
        //OsmAbstract(PIP_TOKEN).kiss(MCD_END);
        // Set TOKEN Osm in the OsmMom for new ilk
        // !!!!!!!! Only if PIP_TOKEN = Osm
        OsmMomAbstract(OSM_MOM).setOsm(ilk, PIP_ETH);

        // Set the global debt ceiling
        VatAbstract(MCD_VAT).file("Line", 1216 * MILLION * RAD);
        // Set the TOKEN-LETTER debt ceiling
        VatAbstract(MCD_VAT).file(ilk, "line", 20 * MILLION * RAD);
        // Set the TOKEN-LETTER dust
        VatAbstract(MCD_VAT).file(ilk, "dust", 100 * RAD);
        // Set the Lot size
        CatAbstract(MCD_CAT).file(ilk, "dunk", 500 * RAD); // Should be 50000 on mainnet
        // Set the TOKEN-LETTER liquidation penalty (e.g. 13% => X = 113)
        CatAbstract(MCD_CAT).file(ilk, "chop", 113 * WAD / 100);
        // Set the TOKEN-LETTER stability fee (e.g. 1% = 1000000000315522921573372069)
        JugAbstract(MCD_JUG).file(ilk, "duty", SIX_PERCENT_RATE);
        // Set the TOKEN-LETTER percentage between bids (e.g. 3% => X = 103)
        FlipAbstract(MCD_FLIP_ETH_B).file("beg", 103 * WAD / 100);
        // Set the TOKEN-LETTER time max time between bids
        FlipAbstract(MCD_FLIP_ETH_B).file("ttl", 1 hours); // 6 hours mainnet
        // Set the TOKEN-LETTER max auction duration to
        FlipAbstract(MCD_FLIP_ETH_B).file("tau", 1 hours); // 6 hours mainnet
        // Set the TOKEN-LETTER min collateralization ratio (e.g. 150% => X = 150)
        SpotAbstract(MCD_SPOT).file(ilk, "mat", 130 * RAY / 100);

        // Update TOKEN-LETTER spot value in Vat
        SpotAbstract(MCD_SPOT).poke(ilk);

        // Add new ilk to the IlkRegistry
        IlkRegistryAbstract(ILK_REGISTRY).add(MCD_JOIN_ETH_B);
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
