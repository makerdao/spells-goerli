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
import "lib/dss-interfaces/src/dss/FlipperMomAbstract.sol";
import "lib/dss-interfaces/src/dss/JugAbstract.sol";
import "lib/dss-interfaces/src/dss/CatAbstract.sol";
import "lib/dss-interfaces/src/dss/IlkRegistryAbstract.sol";
import "lib/dss-interfaces/src/dss/FaucetAbstract.sol";
import "lib/dss-interfaces/src/dss/GemJoinAbstract.sol";
import "lib/dss-interfaces/src/dss/OsmAbstract.sol";
import "lib/dss-interfaces/src/dss/OsmMomAbstract.sol";
import "lib/dss-interfaces/src/dss/MedianAbstract.sol";
import "lib/dss-interfaces/src/dss/DssAutoLineAbstract.sol";

interface PsmAbstract {
    function wards(address) external returns (uint256);
    function vat() external returns (address);
    function gemJoin() external returns (address);
    function dai() external returns (address);
    function daiJoin() external returns (address);
    function ilk() external returns (bytes32);
    function vow() external returns (address);
    function tin() external returns (uint256);
    function tout() external returns (uint256);
    function file(bytes32 what, uint256 data) external;
    function sellGem(address usr, uint256 gemAmt) external;
    function buyGem(address usr, uint256 gemAmt) external;
}

interface LerpAbstract {
    function wards(address) external returns (uint256);
    function target() external returns (address);
    function what() external returns (bytes32);
    function start() external returns (uint256);
    function end() external returns (uint256);
    function duration() external returns (uint256);
    function started() external returns (bool);
    function done() external returns (bool);
    function startTime() external returns (uint256);
    function init() external;
    function tick() external;
}

contract SpellAction {
    // KOVAN ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    //  against the current release list at:
    //     https://changelog.makerdao.com/releases/kovan/active/contracts.json
    ChainlogAbstract constant CHANGELOG =
        ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);

    // PSM-USDC-A
    address constant USDC               = 0xBD84be3C303f6821ab297b840a99Bd0d4c4da6b5;
    address constant MCD_JOIN_USDC_PSM  = 0x4BA159Ad37FD80D235b4a948A8682747c74fDc0E;
    address constant MCD_FLIP_USDC_PSM  = 0xe9eef655494F63802e9C7A7F1006547c4De3e713;
    address constant MCD_PSM_USDC_PSM   = 0xe4dC42e438879987e287A6d9519379936d7b065A;
    address constant LERP               = 0x489f89E54a807BE8fe531C1663FA9A39Bbdde4F4;
    address constant PIP_USDC           = 0x4c51c2584309b7BF328F89609FDd03B3b95fC677;
    bytes32 constant ILK_PSM_USDC_A     = "PSM-USDC-A";

    // decimals & precision
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
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmefQMseb3AiTapiAKKexdKHig8wroKuZbmLtPLv4u2YwW
    //
    uint256 constant ZERO_PERCENT_RATE = 1000000000000000000000000000;

    function execute() external {
        address MCD_VAT      = CHANGELOG.getAddress("MCD_VAT");
        address MCD_CAT      = CHANGELOG.getAddress("MCD_CAT");
        address MCD_JUG      = CHANGELOG.getAddress("MCD_JUG");
        address MCD_SPOT     = CHANGELOG.getAddress("MCD_SPOT");
        address MCD_END      = CHANGELOG.getAddress("MCD_END");
        address MCD_VOW      = CHANGELOG.getAddress("MCD_VOW");
        address MCD_DAI      = CHANGELOG.getAddress("MCD_DAI");
        address MCD_JOIN_DAI = CHANGELOG.getAddress("MCD_JOIN_DAI");
        address FLIPPER_MOM  = CHANGELOG.getAddress("FLIPPER_MOM");
        address ILK_REGISTRY = CHANGELOG.getAddress("ILK_REGISTRY");

        //
        // Add PSM-USDC-A
        //

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_USDC_PSM).vat() == MCD_VAT, "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_USDC_PSM).ilk() == ILK_PSM_USDC_A, "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_USDC_PSM).gem() == USDC, "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_USDC_PSM).dec() == DSTokenAbstract(USDC).decimals(), "join-dec-not-match");
        require(FlipAbstract(MCD_FLIP_USDC_PSM).vat() == MCD_VAT, "flip-vat-not-match");
        require(FlipAbstract(MCD_FLIP_USDC_PSM).cat() == MCD_CAT, "flip-cat-not-match");
        require(FlipAbstract(MCD_FLIP_USDC_PSM).ilk() == ILK_PSM_USDC_A, "flip-ilk-not-match");
        require(PsmAbstract(MCD_PSM_USDC_PSM).vat() == MCD_VAT, "psm-vat-not-match");
        require(PsmAbstract(MCD_PSM_USDC_PSM).gemJoin() == MCD_JOIN_USDC_PSM, "psm-join-not-match");
        require(PsmAbstract(MCD_PSM_USDC_PSM).dai() == MCD_DAI, "psm-dai-not-match");
        require(PsmAbstract(MCD_PSM_USDC_PSM).daiJoin() == MCD_JOIN_DAI, "psm-dai-join-not-match");
        require(PsmAbstract(MCD_PSM_USDC_PSM).ilk() == ILK_PSM_USDC_A, "psm-ilk-not-match");
        require(PsmAbstract(MCD_PSM_USDC_PSM).vow() == MCD_VOW, "psm-vow-not-match");
        require(LerpAbstract(LERP).target() == MCD_PSM_USDC_PSM, "lerp-target-not-match");
        require(LerpAbstract(LERP).what() == "tin", "lerp-what-not-match");
        require(LerpAbstract(LERP).start() == 1 * WAD / 100, "lerp-start-not-match");
        require(LerpAbstract(LERP).end() == 1 * WAD / 1000, "lerp-end-not-match");
        require(LerpAbstract(LERP).duration() ==  7 days, "lerp-duration-not-match");
        require(!LerpAbstract(LERP).started(), "lerp-not-started");
        require(!LerpAbstract(LERP).done(), "lerp-not-done");

        // Set the USDC PIP in the Spotter
        SpotAbstract(MCD_SPOT).file(ILK_PSM_USDC_A, "pip", PIP_USDC);

        // Set the PSM-USDC-A Flipper in the Cat
        CatAbstract(MCD_CAT).file(ILK_PSM_USDC_A, "flip", MCD_FLIP_USDC_PSM);

        // Init PSM-USDC-A ilk in Vat & Jug
        // VatAbstract(MCD_VAT).init(ilk);
        JugAbstract(MCD_JUG).init(ILK_PSM_USDC_A);

        // Allow PSM-USDC-A Join to modify Vat registry
        VatAbstract(MCD_VAT).rely(MCD_JOIN_USDC_PSM);
        // Allow the PSM-USDC-A Flipper to reduce the Cat litterbox on deal()
        CatAbstract(MCD_CAT).rely(MCD_FLIP_USDC_PSM);
        // Allow Cat to kick auctions in PSM-USDC-A Flipper
        FlipAbstract(MCD_FLIP_USDC_PSM).rely(MCD_CAT);
        // Allow End to yank auctions in PSM-USDC-A Flipper
        FlipAbstract(MCD_FLIP_USDC_PSM).rely(MCD_END);
        // Allow FlipperMom to access to the PSM-USDC-A Flipper
        FlipAbstract(MCD_FLIP_USDC_PSM).rely(FLIPPER_MOM);
        // Disallow Cat to kick auctions in PSM-USDC-A Flipper
        // !!!!!!!! Only for certain collaterals that do not trigger liquidations like USDC-A)
        FlipperMomAbstract(FLIPPER_MOM).deny(MCD_FLIP_USDC_PSM);

        // Set the global debt ceiling
        VatAbstract(MCD_VAT).file("Line", VatAbstract(MCD_VAT).Line() + 500 * MILLION * RAD);
        // Set the PSM-USDC-A debt ceiling
        VatAbstract(MCD_VAT).file(ILK_PSM_USDC_A, "line", 500 * MILLION * RAD);
        // No dust limit for PSM
        // VatAbstract(MCD_VAT).file(ILK_PSM_USDC_A, "dust", 10 * RAD);
        // Set the Lot size
        CatAbstract(MCD_CAT).file(ILK_PSM_USDC_A, "dunk", 500 * RAD);
        // Set the PSM-USDC-A liquidation penalty (e.g. 13% => X = 113)
        CatAbstract(MCD_CAT).file(ILK_PSM_USDC_A, "chop", 113 * WAD / 100);
        // Set the PSM-USDC-A stability fee (e.g. 1% = 1000000000315522921573372069)
        JugAbstract(MCD_JUG).file(ILK_PSM_USDC_A, "duty", ZERO_PERCENT_RATE);
        // Set the PSM-USDC-A percentage between bids (e.g. 3% => X = 103)
        FlipAbstract(MCD_FLIP_USDC_PSM).file("beg", 103 * WAD / 100);
        // Set the PSM-USDC-A time max time between bids
        FlipAbstract(MCD_FLIP_USDC_PSM).file("ttl", 1 hours);
        // Set the PSM-USDC-A max auction duration to
        FlipAbstract(MCD_FLIP_USDC_PSM).file("tau", 1 hours);
        // Set the PSM-USDC-A min collateralization ratio (e.g. 150% => X = 150)
        SpotAbstract(MCD_SPOT).file(ILK_PSM_USDC_A, "mat", 100 * RAY / 100);
        // Set the PSM-USDC-A fee in (tin)
        PsmAbstract(MCD_PSM_USDC_PSM).file("tin", 1 * WAD / 100);
        // Set the PSM-USDC-A fee out (tout)
        PsmAbstract(MCD_PSM_USDC_PSM).file("tout", 1 * WAD / 1000);

        // Update PSM-USDC-A spot value in Vat
        SpotAbstract(MCD_SPOT).poke(ILK_PSM_USDC_A);

        // Add new ilk to the IlkRegistry
        IlkRegistryAbstract(ILK_REGISTRY).add(MCD_JOIN_USDC_PSM);

        // Initialize the lerp module to start the clock
        LerpAbstract(LERP).init();

        // Update the changelog
        CHANGELOG.setAddress("MCD_JOIN_USDC_PSM", MCD_JOIN_USDC_PSM);
        CHANGELOG.setAddress("MCD_FLIP_USDC_PSM", MCD_FLIP_USDC_PSM);
        CHANGELOG.setAddress("MCD_PSM_USDC_PSM", MCD_PSM_USDC_PSM);

        // Bump version
        CHANGELOG.setVersion("1.2.3");
    }
}

contract DssSpell {
    ChainlogAbstract constant CHANGELOG =
        ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);
    DSPauseAbstract public pause =
        DSPauseAbstract(CHANGELOG.getAddress("MCD_PAUSE"));

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
