// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.6.12;

import "ds-math/math.sol";
import "ds-test/test.sol";
import "lib/dss-interfaces/src/Interfaces.sol";
import "./test/rates.sol";
import "./test/addresses_goerli.sol";

import {DssSpell} from "./Goerli-DssSpell.sol";

interface Hevm {
    function warp(uint) external;
    function store(address,bytes32,bytes32) external;
    function load(address,bytes32) external view returns (bytes32);
}

interface SpellLike {
    function done() external view returns (bool);
    function cast() external;
    function eta() external view returns (uint256);
    function nextCastTime() external returns (uint256);
}

interface AuthLike {
    function wards(address) external view returns (uint256);
}

interface FlashLike {
    function vat() external view returns (address);
    function daiJoin() external view returns (address);
    function dai() external view returns (address);
    function vow() external view returns (address);
    function max() external view returns (uint256);
    function toll() external view returns (uint256);
    function locked() external view returns (uint256);
    function maxFlashLoan(address) external view returns (uint256);
    function flashFee(address, uint256) external view returns (uint256);
    function flashLoan(address, address, uint256, bytes calldata) external returns (bool);
    function vatDaiFlashLoan(address, uint256, bytes calldata) external returns (bool);
    function convert() external;
    function accrue() external;
}

interface RwaLiquidationLike {
    function ilks(bytes32) external returns (string memory,address,uint48,uint48);
}

interface RwaUrnLike {
    function hope(address) external;
    function draw(uint256) external;
    function lock(uint256 wad) external;
    function outputConduit() external view returns (address);
}

interface TinlakeManagerLike {
    function lock(uint256 wad) external;
    function file(bytes32 what, address data) external;
}

contract DssSpellTest is DSTest, DSMath {

    struct SpellValues {
        address deployed_spell;
        uint256 deployed_spell_created;
        address previous_spell;
        bool    office_hours_enabled;
        uint256 expiration_threshold;
    }

    struct CollateralValues {
        bool aL_enabled;
        uint256 aL_line;
        uint256 aL_gap;
        uint256 aL_ttl;
        uint256 line;
        uint256 dust;
        uint256 pct;
        uint256 mat;
        bytes32 liqType;
        bool    liqOn;
        uint256 chop;
        uint256 cat_dunk;
        uint256 flip_beg;
        uint48  flip_ttl;
        uint48  flip_tau;
        uint256 flipper_mom;
        uint256 dog_hole;
        uint256 clip_buf;
        uint256 clip_tail;
        uint256 clip_cusp;
        uint256 clip_chip;
        uint256 clip_tip;
        uint256 clipper_mom;
        uint256 cm_tolerance;
        uint256 calc_tau;
        uint256 calc_step;
        uint256 calc_cut;
    }

    struct SystemValues {
        uint256 line_offset;
        uint256 pot_dsr;
        uint256 pause_delay;
        uint256 vow_wait;
        uint256 vow_dump;
        uint256 vow_sump;
        uint256 vow_bump;
        uint256 vow_hump_min;
        uint256 vow_hump_max;
        uint256 flap_beg;
        uint256 flap_ttl;
        uint256 flap_tau;
        uint256 cat_box;
        uint256 dog_Hole;
        address pause_authority;
        address osm_mom_authority;
        address flipper_mom_authority;
        address clipper_mom_authority;
        uint256 ilk_count;
        mapping (bytes32 => CollateralValues) collaterals;
    }

    SystemValues afterSpell;
    SpellValues  spellValues;

    Hevm hevm;
    Rates     rates = new Rates();
    Addresses addr  = new Addresses();
    
    // KOVAN ADDRESSES
    DSPauseAbstract        pause = DSPauseAbstract(    addr.addr("MCD_PAUSE"));
    address           pauseProxy =                     addr.addr("MCD_PAUSE_PROXY");
    DSChiefAbstract        chief = DSChiefAbstract(    addr.addr("MCD_ADM"));
    VatAbstract              vat = VatAbstract(        addr.addr("MCD_VAT"));
    VowAbstract              vow = VowAbstract(        addr.addr("MCD_VOW"));
    CatAbstract              cat = CatAbstract(        addr.addr("MCD_CAT"));
    DogAbstract              dog = DogAbstract(        addr.addr("MCD_DOG"));
    PotAbstract              pot = PotAbstract(        addr.addr("MCD_POT"));
    JugAbstract              jug = JugAbstract(        addr.addr("MCD_JUG"));
    SpotAbstract         spotter = SpotAbstract(       addr.addr("MCD_SPOT"));
    DaiAbstract              dai = DaiAbstract(        addr.addr("MCD_DAI"));
    DaiJoinAbstract      daiJoin = DaiJoinAbstract(    addr.addr("MCD_JOIN_DAI"));
    DSTokenAbstract          gov = DSTokenAbstract(    addr.addr("MCD_GOV"));
    EndAbstract              end = EndAbstract(        addr.addr("MCD_END"));
    ESMAbstract              esm = ESMAbstract(        addr.addr("MCD_ESM"));
    IlkRegistryAbstract      reg = IlkRegistryAbstract(addr.addr("ILK_REGISTRY"));
    FlapAbstract            flap = FlapAbstract(       addr.addr("MCD_FLAP"));

    OsmMomAbstract        osmMom = OsmMomAbstract(     addr.addr("OSM_MOM"));
    FlipperMomAbstract   flipMom = FlipperMomAbstract( addr.addr("FLIPPER_MOM"));
    ClipperMomAbstract   clipMom = ClipperMomAbstract( addr.addr("CLIPPER_MOM"));
    DssAutoLineAbstract autoLine = DssAutoLineAbstract(addr.addr("MCD_IAM_AUTO_LINE"));

    DssSpell spell;

    // CHEAT_CODE = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
    bytes20 constant CHEAT_CODE =
        bytes20(uint160(uint256(keccak256('hevm cheat code'))));

    uint256 constant HUNDRED    = 10 ** 2;
    uint256 constant THOUSAND   = 10 ** 3;
    uint256 constant MILLION    = 10 ** 6;
    uint256 constant BILLION    = 10 ** 9;
    uint256 constant RAD        = 10 ** 45;


    uint256 constant monthly_expiration = 4 days;
    uint256 constant weekly_expiration = 30 days;

    event Debug(uint256 index, uint256 val);
    event Debug(uint256 index, address addr);
    event Debug(uint256 index, bytes32 what);
    event Log(string message, address deployer, string contractName);

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.01)/(60 * 60 * 24 * 365) )'
    //
    // Rates table is in ./test/rates.sol

    // not provided in DSMath
    function rpow(uint256 x, uint256 n, uint256 b) internal pure returns (uint256 z) {
      assembly {
        switch x case 0 {switch n case 0 {z := b} default {z := 0}}
        default {
          switch mod(n, 2) case 0 { z := b } default { z := x }
          let half := div(b, 2)  // for rounding.
          for { n := div(n, 2) } n { n := div(n,2) } {
            let xx := mul(x, x)
            if iszero(eq(div(xx, x), x)) { revert(0,0) }
            let xxRound := add(xx, half)
            if lt(xxRound, xx) { revert(0,0) }
            x := div(xxRound, b)
            if mod(n,2) {
              let zx := mul(z, x)
              if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) { revert(0,0) }
              let zxRound := add(zx, half)
              if lt(zxRound, zx) { revert(0,0) }
              z := div(zxRound, b)
            }
          }
        }
      }
    }
    function divup(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(x, sub(y, 1)) / y;
    }

    // 10^-5 (tenth of a basis point) as a RAY
    uint256 TOLERANCE = 10 ** 22;

    function yearlyYield(uint256 duty) public pure returns (uint256) {
        return rpow(duty, (365 * 24 * 60 *60), RAY);
    }

    function expectedRate(uint256 percentValue) public pure returns (uint256) {
        return (10000 + percentValue) * (10 ** 23);
    }

    function diffCalc(uint256 expectedRate_, uint256 yearlyYield_) public pure returns (uint256) {
        return (expectedRate_ > yearlyYield_) ? expectedRate_ - yearlyYield_ : yearlyYield_ - expectedRate_;
    }

    function castPreviousSpell() internal {
        SpellLike prevSpell = SpellLike(spellValues.previous_spell);
        // warp and cast previous spell so values are up-to-date to test against
        if (prevSpell != SpellLike(0) && !prevSpell.done()) {
            if (prevSpell.eta() == 0) {
                vote(address(prevSpell));
                scheduleWaitAndCast(address(prevSpell));
            }
            else {
                // jump to nextCastTime to be a little more forgiving on the spell execution time
                hevm.warp(prevSpell.nextCastTime());
                prevSpell.cast();
            }
        }
    }

    function setUp() public {
        hevm = Hevm(address(CHEAT_CODE));

        //
        // Test for spell-specific parameters
        //
        spellValues = SpellValues({
            deployed_spell:                 address(0xaBba6C2c63b2d5CfeB544769B75Cc336f0aB9E2A),        // populate with deployed spell if deployed
            deployed_spell_created:         1628799113,                 // use get-created-timestamp.sh if deployed
            previous_spell:                 address(0),        // supply if there is a need to test prior to its cast() function being called on-chain.
            office_hours_enabled:           false,              // true if officehours is expected to be enabled in the spell
            expiration_threshold:           weekly_expiration  // (weekly_expiration,monthly_expiration) if weekly or monthly spell
        });
        spell = spellValues.deployed_spell != address(0) ?
            DssSpell(spellValues.deployed_spell) : new DssSpell();

        //
        // Test for all system configuration changes
        //
        afterSpell = SystemValues({
            line_offset:           0,                       // Offset between the global line against the sum of local lines
            pot_dsr:               1,                       // In basis points
            pause_delay:           60 seconds,              // In seconds
            vow_wait:              156 hours,               // In seconds
            vow_dump:              250,                     // In whole Dai units
            vow_sump:              50 * THOUSAND,           // In whole Dai units
            vow_bump:              30 * THOUSAND,           // In whole Dai units
            vow_hump_min:          30 * MILLION,            // In whole Dai units
            vow_hump_max:          60 * MILLION,            // In whole Dai units
            flap_beg:              400,                     // in basis points
            flap_ttl:              30 minutes,              // in seconds
            flap_tau:              72 hours,                // in seconds
            cat_box:               20 * MILLION,            // In whole Dai units
            dog_Hole:              100 * MILLION,           // In whole Dai units
            pause_authority:       address(chief),          // Pause authority
            osm_mom_authority:     address(chief),          // OsmMom authority
            flipper_mom_authority: address(chief),          // FlipperMom authority
            clipper_mom_authority: address(chief),          // ClipperMom authority
            ilk_count:             22                       // Num expected in system
        });

        afterSpell.collaterals["ETH-A"] = CollateralValues({
            aL_enabled:   true,            // DssAutoLine is enabled?
            aL_line:      15 * BILLION,    // In whole Dai units
            aL_gap:       100 * MILLION,   // In whole Dai units
            aL_ttl:       8 hours,         // In seconds
            line:         0,               // In whole Dai units  // Not checked here as there is auto line
            dust:         10 * THOUSAND,   // In whole Dai units
            pct:          200,             // In basis points
            mat:          15000,           // In basis points
            liqType:      "clip",          // "" or "flip" or "clip"
            liqOn:        true,            // If liquidations are enabled
            chop:         1300,            // In basis points
            cat_dunk:     0,               // In whole Dai units
            flip_beg:     0,               // In basis points
            flip_ttl:     0,               // In seconds
            flip_tau:     0,               // In seconds
            flipper_mom:  0,               // 1 if circuit breaker enabled
            dog_hole:     30 * MILLION,
            clip_buf:     13000,
            clip_tail:    140 minutes,
            clip_cusp:    4000,
            clip_chip:    10,
            clip_tip:     300,
            clipper_mom:  1,
            cm_tolerance: 5000,
            calc_tau:     0,
            calc_step:    90,
            calc_cut:     9900
        });
        afterSpell.collaterals["ETH-B"] = CollateralValues({
            aL_enabled:   true,
            aL_line:      300 * MILLION,
            aL_gap:       10 * MILLION,
            aL_ttl:       8 hours,
            line:         0,
            dust:         30 * THOUSAND,
            pct:          600,
            mat:          13000,
            liqType:      "clip",
            liqOn:        true,
            chop:         1300,
            cat_dunk:     0,
            flip_beg:     0,
            flip_ttl:     0,
            flip_tau:     0,
            flipper_mom:  0,
            dog_hole:     15 * MILLION,
            clip_buf:     12000,
            clip_tail:    140 minutes,
            clip_cusp:    4000,
            clip_chip:    10,
            clip_tip:     300,
            clipper_mom:  1,
            cm_tolerance: 5000,
            calc_tau:     0,
            calc_step:    60,
            calc_cut:     9900
        });
        afterSpell.collaterals["ETH-C"] = CollateralValues({
            aL_enabled:   true,
            aL_line:      2 * BILLION,
            aL_gap:       100 * MILLION,
            aL_ttl:       8 hours,
            line:         0,
            dust:         5 * THOUSAND,
            pct:          50,
            mat:          17500,
            liqType:      "clip",
            liqOn:        true,
            chop:         1300,
            cat_dunk:     0,
            flip_beg:     0,
            flip_ttl:     0,
            flip_tau:     0,
            flipper_mom:  0,
            dog_hole:     20 * MILLION,
            clip_buf:     13000,
            clip_tail:    140 minutes,
            clip_cusp:    4000,
            clip_chip:    10,
            clip_tip:     300,
            clipper_mom:  1,
            cm_tolerance: 5000,
            calc_tau:     0,
            calc_step:    90,
            calc_cut:     9900
        });
        afterSpell.collaterals["BAT-A"] = CollateralValues({
            aL_enabled:   true,
            aL_line:      7 * MILLION,
            aL_gap:       1 * MILLION,
            aL_ttl:       8 hours,
            line:         0,
            dust:         10 * THOUSAND,
            pct:          400,
            mat:          15000,
            liqType:      "clip",
            liqOn:        true,
            chop:         1300,
            cat_dunk:     0,
            flip_beg:     0,
            flip_ttl:     0,
            flip_tau:     0,
            flipper_mom:  0,
            dog_hole:     1 * MILLION + 500 * THOUSAND,
            clip_buf:     13000,
            clip_tail:    140 minutes,
            clip_cusp:    4000,
            clip_chip:    10,
            clip_tip:     300,
            clipper_mom:  1,
            cm_tolerance: 5000,
            calc_tau:     0,
            calc_step:    90,
            calc_cut:     9900
        });
        afterSpell.collaterals["USDC-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0,
            aL_gap:       0,
            aL_ttl:       0,
            line:         0,
            dust:         10 * THOUSAND,
            pct:          0,
            mat:          10100,
            liqType:      "clip",
            liqOn:        false,
            chop:         1300,
            cat_dunk:     0,
            flip_beg:     0,
            flip_ttl:     0,
            flip_tau:     0,
            flipper_mom:  0,
            dog_hole:     0,
            clip_buf:     10500,
            clip_tail:    220 minutes,
            clip_cusp:    9000,
            clip_chip:    10,
            clip_tip:     300,
            clipper_mom:  0,
            cm_tolerance: 9500,
            calc_tau:     0,
            calc_step:    120,
            calc_cut:     9990
        });
        afterSpell.collaterals["USDC-B"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0,
            aL_gap:       0,
            aL_ttl:       0,
            line:         0,
            dust:         10 * THOUSAND,
            pct:          5000,
            mat:          12000,
            liqType:      "clip",
            liqOn:        false,
            chop:         1300,
            cat_dunk:     0,
            flip_beg:     0,
            flip_ttl:     0,
            flip_tau:     0,
            flipper_mom:  0,
            dog_hole:     0,
            clip_buf:     10500,
            clip_tail:    220 minutes,
            clip_cusp:    9000,
            clip_chip:    10,
            clip_tip:     300,
            clipper_mom:  0,
            cm_tolerance: 9500,
            calc_tau:     0,
            calc_step:    120,
            calc_cut:     9990
        });
        afterSpell.collaterals["WBTC-A"] = CollateralValues({
            aL_enabled:   true,
            aL_line:      750 * MILLION,
            aL_gap:       30 * MILLION,
            aL_ttl:       8 hours,
            line:         0,
            dust:         10 * THOUSAND,
            pct:          200,
            mat:          15000,
            liqType:      "clip",
            liqOn:        true,
            chop:         1300,
            cat_dunk:     0,
            flip_beg:     0,
            flip_ttl:     0,
            flip_tau:     0,
            flipper_mom:  0,
            dog_hole:     15 * MILLION,
            clip_buf:     13000,
            clip_tail:    140 minutes,
            clip_cusp:    4000,
            clip_chip:    10,
            clip_tip:     300,
            clipper_mom:  1,
            cm_tolerance: 5000,
            calc_tau:     0,
            calc_step:    90,
            calc_cut:     9900
        });
        afterSpell.collaterals["TUSD-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0,
            aL_gap:       0,
            aL_ttl:       0,
            line:         0,
            dust:         10 * THOUSAND,
            pct:          100,
            mat:          10100,
            liqType:      "clip",
            liqOn:        false,
            chop:         1300,
            cat_dunk:     0,
            flip_beg:     0,
            flip_ttl:     0,
            flip_tau:     0,
            flipper_mom:  0,
            dog_hole:     0,
            clip_buf:     10500,
            clip_tail:    220 minutes,
            clip_cusp:    9000,
            clip_chip:    10,
            clip_tip:     300,
            clipper_mom:  0,
            cm_tolerance: 9500,
            calc_tau:     0,
            calc_step:    120,
            calc_cut:     9990
        });
        afterSpell.collaterals["KNC-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0,
            aL_gap:       0,
            aL_ttl:       0,
            line:         0,
            dust:         10 * THOUSAND,
            pct:          500,
            mat:          17500,
            liqType:      "clip",
            liqOn:        true,
            chop:         1300,
            cat_dunk:     0,
            flip_beg:     0,
            flip_ttl:     0,
            flip_tau:     0,
            flipper_mom:  0,
            dog_hole:     500 * THOUSAND,
            clip_buf:     13000,
            clip_tail:    140 minutes,
            clip_cusp:    4000,
            clip_chip:    10,
            clip_tip:     300,
            clipper_mom:  1,
            cm_tolerance: 5000,
            calc_tau:     0,
            calc_step:    90,
            calc_cut:     9900
        });
        afterSpell.collaterals["ZRX-A"] = CollateralValues({
            aL_enabled:   true,
            aL_line:      3 * MILLION,
            aL_gap:       500 * THOUSAND,
            aL_ttl:       8 hours,
            line:         0,
            dust:         10 * THOUSAND,
            pct:          400,
            mat:          17500,
            liqType:      "clip",
            liqOn:        true,
            chop:         1300,
            cat_dunk:     0,
            flip_beg:     0,
            flip_ttl:     0,
            flip_tau:     0,
            flipper_mom:  0,
            dog_hole:     1 * MILLION,
            clip_buf:     13000,
            clip_tail:    140 minutes,
            clip_cusp:    4000,
            clip_chip:    10,
            clip_tip:     300,
            clipper_mom:  1,
            cm_tolerance: 5000,
            calc_tau:     0,
            calc_step:    90,
            calc_cut:     9900
        });
        afterSpell.collaterals["MANA-A"] = CollateralValues({
            aL_enabled:   true,
            aL_line:      5 * MILLION,
            aL_gap:       1 * MILLION,
            aL_ttl:       8 hours,
            line:         0,
            dust:         10 * THOUSAND,
            pct:          300,
            mat:          17500,
            liqType:      "clip",
            liqOn:        true,
            chop:         1300,
            cat_dunk:     0,
            flip_beg:     0,
            flip_ttl:     0,
            flip_tau:     0,
            flipper_mom:  0,
            dog_hole:     1 * MILLION,
            clip_buf:     13000,
            clip_tail:    140 minutes,
            clip_cusp:    4000,
            clip_chip:    10,
            clip_tip:     300,
            clipper_mom:  1,
            cm_tolerance: 5000,
            calc_tau:     0,
            calc_step:    90,
            calc_cut:     9900
        });
        afterSpell.collaterals["USDT-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0,
            aL_gap:       0,
            aL_ttl:       0,
            line:         0,
            dust:         10 * THOUSAND,
            pct:          800,
            mat:          15000,
            liqType:      "clip",
            liqOn:        false,
            chop:         1300,
            cat_dunk:     0,
            flip_beg:     0,
            flip_ttl:     0,
            flip_tau:     0,
            flipper_mom:  0,
            dog_hole:     0,
            clip_buf:     10500,
            clip_tail:    220 minutes,
            clip_cusp:    9000,
            clip_chip:    10,
            clip_tip:     300,
            clipper_mom:  0,
            cm_tolerance: 9500,
            calc_tau:     0,
            calc_step:    120,
            calc_cut:     9990
        });
        afterSpell.collaterals["PAXUSD-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0,
            aL_gap:       0,
            aL_ttl:       0,
            line:         0,
            dust:         10 * THOUSAND,
            pct:          100,
            mat:          10100,
            liqType:      "clip",
            liqOn:        false,
            chop:         1300,
            cat_dunk:     0,
            flip_beg:     0,
            flip_ttl:     0,
            flip_tau:     0,
            flipper_mom:  0,
            dog_hole:     0,
            clip_buf:     10500,
            clip_tail:    220 minutes,
            clip_cusp:    9000,
            clip_chip:    10,
            clip_tip:     300,
            clipper_mom:  0,
            cm_tolerance: 9500,
            calc_tau:     0,
            calc_step:    120,
            calc_cut:     9990
        });
        afterSpell.collaterals["COMP-A"] = CollateralValues({
            aL_enabled:   true,
            aL_line:      20 * MILLION,
            aL_gap:       2 * MILLION,
            aL_ttl:       8 hours,
            line:         0,
            dust:         10 * THOUSAND,
            pct:          100,
            mat:          17500,
            liqType:      "clip",
            liqOn:        true,
            chop:         1300,
            cat_dunk:     0,
            flip_beg:     0,
            flip_ttl:     0,
            flip_tau:     0,
            flipper_mom:  0,
            dog_hole:     2 * MILLION,
            clip_buf:     13000,
            clip_tail:    140 minutes,
            clip_cusp:    4000,
            clip_chip:    10,
            clip_tip:     300,
            clipper_mom:  1,
            cm_tolerance: 5000,
            calc_tau:     0,
            calc_step:    90,
            calc_cut:     9900
        });
        afterSpell.collaterals["LRC-A"] = CollateralValues({
            aL_enabled:   true,
            aL_line:      3 * MILLION,
            aL_gap:       500 * THOUSAND,
            aL_ttl:       8 hours,
            line:         0,
            dust:         10 * THOUSAND,
            pct:          400,
            mat:          17500,
            liqType:      "clip",
            liqOn:        true,
            chop:         1300,
            cat_dunk:     0,
            flip_beg:     0,
            flip_ttl:     0,
            flip_tau:     0,
            flipper_mom:  0,
            dog_hole:     500 * THOUSAND,
            clip_buf:     13000,
            clip_tail:    140 minutes,
            clip_cusp:    4000,
            clip_chip:    10,
            clip_tip:     300,
            clipper_mom:  1,
            cm_tolerance: 5000,
            calc_tau:     0,
            calc_step:    90,
            calc_cut:     9900
        });
        afterSpell.collaterals["LINK-A"] = CollateralValues({
            aL_enabled:   true,
            aL_line:      140 * MILLION,
            aL_gap:       7 * MILLION,
            aL_ttl:       8 hours,
            line:         0,
            dust:         10 * THOUSAND,
            pct:          100,
            mat:          17500,
            liqType:      "clip",
            liqOn:        true,
            chop:         1300,
            cat_dunk:     0,
            flip_beg:     0,
            flip_ttl:     0,
            flip_tau:     0,
            flipper_mom:  0,
            dog_hole:     6 * MILLION,
            clip_buf:     13000,
            clip_tail:    140 minutes,
            clip_cusp:    4000,
            clip_chip:    10,
            clip_tip:     300,
            clipper_mom:  1,
            cm_tolerance: 5000,
            calc_tau:     0,
            calc_step:    90,
            calc_cut:     9900
        });
        afterSpell.collaterals["BAL-A"] = CollateralValues({
            aL_enabled:   true,
            aL_line:      30 * MILLION,
            aL_gap:       3 * MILLION,
            aL_ttl:       8 hours,
            line:         0,
            dust:         10 * THOUSAND,
            pct:          100,
            mat:          17500,
            liqType:      "clip",
            liqOn:        true,
            chop:         1300,
            cat_dunk:     0,
            flip_beg:     0,
            flip_ttl:     0,
            flip_tau:     0,
            flipper_mom:  0,
            dog_hole:     3 * MILLION,
            clip_buf:     13000,
            clip_tail:    140 minutes,
            clip_cusp:    4000,
            clip_chip:    10,
            clip_tip:     300,
            clipper_mom:  1,
            cm_tolerance: 5000,
            calc_tau:     0,
            calc_step:    90,
            calc_cut:     9900
        });
        afterSpell.collaterals["YFI-A"] = CollateralValues({
            aL_enabled:   true,
            aL_line:      130 * MILLION,
            aL_gap:       7 * MILLION,
            aL_ttl:       8 hours,
            line:         0,
            dust:         10 * THOUSAND,
            pct:          100,
            mat:          17500,
            liqType:      "clip",
            liqOn:        true,
            chop:         1300,
            cat_dunk:     0,
            flip_beg:     0,
            flip_ttl:     0,
            flip_tau:     0,
            flipper_mom:  0,
            dog_hole:     5 * MILLION,
            clip_buf:     13000,
            clip_tail:    140 minutes,
            clip_cusp:    4000,
            clip_chip:    10,
            clip_tip:     300,
            clipper_mom:  1,
            cm_tolerance: 5000,
            calc_tau:     0,
            calc_step:    90,
            calc_cut:     9900
        });
        afterSpell.collaterals["GUSD-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0,
            aL_gap:       0,
            aL_ttl:       0,
            line:         5 * MILLION,
            dust:         10 * THOUSAND,
            pct:          0,
            mat:          10100,
            liqType:      "clip",
            liqOn:        false,
            chop:         1300,
            cat_dunk:     0,
            flip_beg:     0,
            flip_ttl:     0,
            flip_tau:     0,
            flipper_mom:  0,
            dog_hole:     0,
            clip_buf:     10500,
            clip_tail:    220 minutes,
            clip_cusp:    9000,
            clip_chip:    10,
            clip_tip:     300,
            clipper_mom:  0,
            cm_tolerance: 9500,
            calc_tau:     0,
            calc_step:    120,
            calc_cut:     9990
        });
        afterSpell.collaterals["UNI-A"] = CollateralValues({
            aL_enabled:   true,
            aL_line:      50 * MILLION,
            aL_gap:       5 * MILLION,
            aL_ttl:       8 hours,
            line:         0,
            dust:         10 * THOUSAND,
            pct:          100,
            mat:          17500,
            liqType:      "clip",
            liqOn:        true,
            chop:         1300,
            cat_dunk:     0,
            flip_beg:     0,
            flip_ttl:     0,
            flip_tau:     0,
            flipper_mom:  0,
            dog_hole:     5 * MILLION,
            clip_buf:     13000,
            clip_tail:    140 minutes,
            clip_cusp:    4000,
            clip_chip:    10,
            clip_tip:     300,
            clipper_mom:  1,
            cm_tolerance: 5000,
            calc_tau:     0,
            calc_step:    90,
            calc_cut:     9900
        });
        afterSpell.collaterals["RENBTC-A"] = CollateralValues({
            aL_enabled:   true,
            aL_line:      10 * MILLION,
            aL_gap:       1 * MILLION,
            aL_ttl:       8 hours,
            line:         0,
            dust:         10 * THOUSAND,
            pct:          200,
            mat:          17500,
            liqType:      "clip",
            liqOn:        true,
            chop:         1300,
            cat_dunk:     0,
            flip_beg:     0,
            flip_ttl:     0,
            flip_tau:     0,
            flipper_mom:  0,
            dog_hole:     3 * MILLION,
            clip_buf:     13000,
            clip_tail:    140 minutes,
            clip_cusp:    4000,
            clip_chip:    10,
            clip_tip:     300,
            clipper_mom:  1,
            cm_tolerance: 5000,
            calc_tau:     0,
            calc_step:    90,
            calc_cut:     9900
        });
        afterSpell.collaterals["AAVE-A"] = CollateralValues({
            aL_enabled:   true,
            aL_line:      50 * MILLION,
            aL_gap:       5 * MILLION,
            aL_ttl:       8 hours,
            line:         0,
            dust:         10 * THOUSAND,
            pct:          100,
            mat:          17500,
            liqType:      "clip",
            liqOn:        true,
            chop:         1300,
            cat_dunk:     0,
            flip_beg:     0,
            flip_ttl:     0,
            flip_tau:     0,
            flipper_mom:  0,
            dog_hole:     5 * MILLION,
            clip_buf:     13000,
            clip_tail:    140 minutes,
            clip_cusp:    4000,
            clip_chip:    10,
            clip_tip:     300,
            clipper_mom:  1,
            cm_tolerance: 5000,
            calc_tau:     0,
            calc_step:    90,
            calc_cut:     9900
        });
    }

    function scheduleWaitAndCastFailDay() public {
        spell.schedule();

        uint256 castTime = block.timestamp + pause.delay();
        uint256 day = (castTime / 1 days + 3) % 7;
        if (day < 5) {
            castTime += 5 days - day * 86400;
        }

        hevm.warp(castTime);
        spell.cast();
    }

    function scheduleWaitAndCastFailEarly() public {
        spell.schedule();

        uint256 castTime = block.timestamp + pause.delay() + 24 hours;
        uint256 hour = castTime / 1 hours % 24;
        if (hour >= 14) {
            castTime -= hour * 3600 - 13 hours;
        }

        hevm.warp(castTime);
        spell.cast();
    }

    function scheduleWaitAndCastFailLate() public {
        spell.schedule();

        uint256 castTime = block.timestamp + pause.delay();
        uint256 hour = castTime / 1 hours % 24;
        if (hour < 21) {
            castTime += 21 hours - hour * 3600;
        }

        hevm.warp(castTime);
        spell.cast();
    }

    function vote(address spell_) internal {
        if (chief.hat() != spell_) {
            giveTokens(gov, 999999999999 ether);
            gov.approve(address(chief), uint256(-1));
            chief.lock(999999999999 ether);

            address[] memory slate = new address[](1);

            assertTrue(!DssSpell(spell_).done());

            slate[0] = spell_;

            chief.vote(slate);
            chief.lift(spell_);
        }
        assertEq(chief.hat(), spell_);
    }

    function scheduleWaitAndCast(address spell_) public {
        DssSpell(spell_).schedule();
        hevm.warp(DssSpell(spell_).nextCastTime());

        DssSpell(spell_).cast();
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }

    function checkSystemValues(SystemValues storage values) internal {
        // dsr
        uint256 expectedDSRRate = rates.rates(values.pot_dsr);
        // make sure dsr is less than 100% APR
        // bc -l <<< 'scale=27; e( l(2.00)/(60 * 60 * 24 * 365) )'
        // 1000000021979553151239153027
        assertEq(pot.dsr(), expectedDSRRate, "TestError/pot-dsr-expected-value");
        assertTrue(
            pot.dsr() >= RAY && pot.dsr() < 1000000021979553151239153027,
            "TestError/pot-dsr-range"
        );
        assertTrue(
            diffCalc(expectedRate(values.pot_dsr), yearlyYield(expectedDSRRate)) <= TOLERANCE,
            "TestError/pot-dsr-rates-table"
        );

        {
        // Line values in RAD
        assertTrue(
            (vat.Line() >= RAD && vat.Line() < 100 * BILLION * RAD) ||
            vat.Line() == 0,
            "TestError/vat-Line-range"
        );
        }

        // Pause delay
        assertEq(pause.delay(), values.pause_delay, "TestError/pause-delay");

        // wait
        assertEq(vow.wait(), values.vow_wait, "TestError/vow-wait");
        {
        // dump values in WAD
        uint256 normalizedDump = values.vow_dump * WAD;
        assertEq(vow.dump(), normalizedDump, "TestError/vow-dump");
        assertTrue(
            (vow.dump() >= WAD && vow.dump() < 2 * THOUSAND * WAD) ||
            vow.dump() == 0,
            "TestError/vow-dump-range"
        );
        }
        {
        // sump values in RAD
        uint256 normalizedSump = values.vow_sump * RAD;
        assertEq(vow.sump(), normalizedSump, "TestError/vow-sump");
        assertTrue(
            (vow.sump() >= RAD && vow.sump() < 500 * THOUSAND * RAD) ||
            vow.sump() == 0,
            "TestError/vow-sump-range"
        );
        }
        {
        // bump values in RAD
        uint256 normalizedBump = values.vow_bump * RAD;
        assertEq(vow.bump(), normalizedBump, "TestError/vow-bump");
        assertTrue(
            (vow.bump() >= RAD && vow.bump() < HUNDRED * THOUSAND * RAD) ||
            vow.bump() == 0,
            "TestError/vow-bump-range"
        );
        }
        {
        // hump values in RAD
        uint256 normalizedHumpMin = values.vow_hump_min * RAD;
        uint256 normalizedHumpMax = values.vow_hump_max * RAD;
        assertTrue(vow.hump() >= normalizedHumpMin && vow.hump() <= normalizedHumpMax, "TestError/vow-hump-min-max");
        assertTrue(
            (vow.hump() >= RAD && vow.hump() < HUNDRED * MILLION * RAD) ||
            vow.hump() == 0,
            "TestError/vow-hump-range"
        );
        }

        // box value in RAD
        {
            uint256 normalizedBox = values.cat_box * RAD;
            assertEq(cat.box(), normalizedBox, "TestError/cat-box");
            assertTrue(cat.box() >= THOUSAND * RAD && cat.box() <= 50 * MILLION * RAD, "TestError/cat-box-range");
        }

        // Hole value in RAD
        {
            uint256 normalizedHole = values.dog_Hole * RAD;
            assertEq(dog.Hole(), normalizedHole, "TestError/dog-Hole");
            assertTrue(dog.Hole() >= THOUSAND * RAD && dog.Hole() <= 200 * MILLION * RAD, "TestError/dog-Hole-range");
        }

        // check Pause authority
        assertEq(pause.authority(), values.pause_authority, "TestError/pause-authority");

        // check OsmMom authority
        assertEq(osmMom.authority(), values.osm_mom_authority, "TestError/osmMom-authority");

        // check FlipperMom authority
        assertEq(flipMom.authority(), values.flipper_mom_authority, "TestError/flipperMom-authority");

        // check ClipperMom authority
        assertEq(clipMom.authority(), values.clipper_mom_authority, "TestError/clipperMom-authority");

        // check number of ilks
        assertEq(reg.count(), values.ilk_count, "TestError/ilks-count");

        // flap
        // check beg value
        uint256 normalizedTestBeg = (values.flap_beg + 10000)  * 10**14;
        assertEq(flap.beg(), normalizedTestBeg, "TestError/flap-beg");
        assertTrue(flap.beg() >= WAD && flap.beg() <= 110 * WAD / 100, "TestError/flap-beg-range"); // gte 0% and lte 10%
        // Check flap ttl and sanity checks
        assertEq(flap.ttl(), values.flap_ttl, "TestError/flap-ttl");
        assertTrue(flap.ttl() > 0 && flap.ttl() < 86400, "TestError/flap-ttl-range"); // gt 0 && lt 1 day
        // Check flap tau and sanity checks
        assertEq(flap.tau(), values.flap_tau, "TestError/flap-tau");
        assertTrue(flap.tau() > 0 && flap.tau() < 2678400, "TestError/flap-tau-range"); // gt 0 && lt 1 month
        assertTrue(flap.tau() >= flap.ttl(), "TestError/flap-tau-ttl");
    }
    
function checkCollateralValues(SystemValues storage values) internal {
        uint256 sumlines;
        bytes32[] memory ilks = reg.list();
        for(uint256 i = 0; i < ilks.length; i++) {
            bytes32 ilk = ilks[i];
            (uint256 duty,)  = jug.ilks(ilk);

            assertEq(duty, rates.rates(values.collaterals[ilk].pct), string(abi.encodePacked("TestError/jug-duty-", ilk)));
            // make sure duty is less than 1000% APR
            // bc -l <<< 'scale=27; e( l(10.00)/(60 * 60 * 24 * 365) )'
            // 1000000073014496989316680335
            assertTrue(duty >= RAY && duty < 1000000073014496989316680335, string(abi.encodePacked("TestError/jug-duty-range-", ilk)));  // gt 0 and lt 1000%
            assertTrue(
                diffCalc(expectedRate(values.collaterals[ilk].pct), yearlyYield(rates.rates(values.collaterals[ilk].pct))) <= TOLERANCE,
                string(abi.encodePacked("TestError/rates-", ilk))
            );
            assertTrue(values.collaterals[ilk].pct < THOUSAND * THOUSAND, string(abi.encodePacked("TestError/pct-max-", ilk)));   // check value lt 1000%
            {
            (,,, uint256 line, uint256 dust) = vat.ilks(ilk);
            // Convert whole Dai units to expected RAD
            uint256 normalizedTestLine = values.collaterals[ilk].line * RAD;
            sumlines += line;
            (uint256 aL_line, uint256 aL_gap, uint256 aL_ttl,,) = autoLine.ilks(ilk);
            if (!values.collaterals[ilk].aL_enabled) {
                assertTrue(aL_line == 0, string(abi.encodePacked("TestError/al-Line-not-zero-", ilk)));
                assertEq(line, normalizedTestLine, string(abi.encodePacked("TestError/vat-line-", ilk)));
                assertTrue((line >= RAD && line < 10 * BILLION * RAD) || line == 0, string(abi.encodePacked("TestError/vat-line-range-", ilk)));  // eq 0 or gt eq 1 RAD and lt 10B
            } else {
                assertTrue(aL_line > 0, string(abi.encodePacked("TestError/al-Line-is-zero-", ilk)));
                assertEq(aL_line, values.collaterals[ilk].aL_line * RAD, string(abi.encodePacked("TestError/al-line-", ilk)));
                assertEq(aL_gap, values.collaterals[ilk].aL_gap * RAD, string(abi.encodePacked("TestError/al-gap-", ilk)));
                assertEq(aL_ttl, values.collaterals[ilk].aL_ttl, string(abi.encodePacked("TestError/al-ttl-", ilk)));
                assertTrue((aL_line >= RAD && aL_line < 20 * BILLION * RAD) || aL_line == 0, string(abi.encodePacked("TestError/al-line-range-", ilk))); // eq 0 or gt eq 1 RAD and lt 10B
            }
            uint256 normalizedTestDust = values.collaterals[ilk].dust * RAD;
            assertEq(dust, normalizedTestDust, string(abi.encodePacked("TestError/vat-dust-", ilk)));
            assertTrue((dust >= RAD && dust < 100 * THOUSAND * RAD) || dust == 0, string(abi.encodePacked("TestError/vat-dust-range-", ilk))); // eq 0 or gt eq 1 and lt 100k
            }

            {
            (,uint256 mat) = spotter.ilks(ilk);
            // Convert BP to system expected value
            uint256 normalizedTestMat = (values.collaterals[ilk].mat * 10**23);
            assertEq(mat, normalizedTestMat, string(abi.encodePacked("TestError/vat-mat-", ilk)));
            assertTrue(mat >= RAY && mat < 10 * RAY, string(abi.encodePacked("TestError/vat-mat-range-", ilk)));    // cr eq 100% and lt 1000%
            }

            if (values.collaterals[ilk].liqType == "flip") {
                {
                assertEq(reg.class(ilk), 2, string(abi.encodePacked("TestError/reg-class-", ilk)));
                (bool ok, bytes memory val) = reg.xlip(ilk).call(abi.encodeWithSignature("cat()"));
                assertTrue(ok, string(abi.encodePacked("TestError/reg-xlip-cat-", ilk)));
                assertEq(abi.decode(val, (address)), address(cat), string(abi.encodePacked("TestError/reg-xlip-cat-", ilk)));
                }
                {
                (, uint256 chop, uint256 dunk) = cat.ilks(ilk);
                // Convert BP to system expected value
                uint256 normalizedTestChop = (values.collaterals[ilk].chop * 10**14) + WAD;
                assertEq(chop, normalizedTestChop, string(abi.encodePacked("TestError/cat-chop-", ilk)));
                // make sure chop is less than 100%
                assertTrue(chop >= WAD && chop < 2 * WAD, string(abi.encodePacked("TestError/cat-chop-range-", ilk)));   // penalty gt eq 0% and lt 100%

                // Convert whole Dai units to expected RAD
                uint256 normalizedTestDunk = values.collaterals[ilk].cat_dunk * RAD;
                assertEq(dunk, normalizedTestDunk, string(abi.encodePacked("TestError/cat-dunk-", ilk)));
                assertTrue(dunk >= RAD && dunk < MILLION * RAD, string(abi.encodePacked("TestError/cat-dunk-range-", ilk)));

                (address flipper,,) = cat.ilks(ilk);
                if (flipper != address(0)) {
                    FlipAbstract flip = FlipAbstract(flipper);
                    // Convert BP to system expected value
                    uint256 normalizedTestBeg = (values.collaterals[ilk].flip_beg + 10000)  * 10**14;
                    assertEq(uint256(flip.beg()), normalizedTestBeg, string(abi.encodePacked("TestError/flip-beg-", ilk)));
                    assertTrue(flip.beg() >= WAD && flip.beg() <= 110 * WAD / 100, string(abi.encodePacked("TestError/flip-beg-range-", ilk))); // gte 0% and lte 10%
                    assertEq(uint256(flip.ttl()), values.collaterals[ilk].flip_ttl, string(abi.encodePacked("TestError/flip-ttl-", ilk)));
                    assertTrue(flip.ttl() >= 600 && flip.ttl() < 10 hours, string(abi.encodePacked("TestError/flip-ttl-range-", ilk)));         // gt eq 10 minutes and lt 10 hours
                    assertEq(uint256(flip.tau()), values.collaterals[ilk].flip_tau, string(abi.encodePacked("TestError/flip-tau-", ilk)));
                    assertTrue(flip.tau() >= 600 && flip.tau() <= 3 days, string(abi.encodePacked("TestError/flip-tau-range-", ilk)));          // gt eq 10 minutes and lt eq 3 days

                    assertEq(flip.wards(address(flipMom)), values.collaterals[ilk].flipper_mom, string(abi.encodePacked("TestError/flip-flipperMom-auth-", ilk)));

                    assertEq(flip.wards(address(cat)), values.collaterals[ilk].liqOn ? 1 : 0, string(abi.encodePacked("TestError/flip-liqOn-", ilk)));
                    assertEq(flip.wards(address(pauseProxy)), 1, string(abi.encodePacked("TestError/flip-pause-proxy-auth-", ilk))); // Check pause_proxy ward
                }
                }
            }
            if (values.collaterals[ilk].liqType == "clip") {
                {
                assertEq(reg.class(ilk), 1, string(abi.encodePacked("TestError/reg-class-", ilk)));
                (bool ok, bytes memory val) = reg.xlip(ilk).call(abi.encodeWithSignature("dog()"));
                assertTrue(ok, string(abi.encodePacked("TestError/reg-xlip-dog-", ilk)));
                assertEq(abi.decode(val, (address)), address(dog), string(abi.encodePacked("TestError/reg-xlip-dog-", ilk)));
                }
                {
                (, uint256 chop, uint256 hole,) = dog.ilks(ilk);
                // Convert BP to system expected value
                uint256 normalizedTestChop = (values.collaterals[ilk].chop * 10**14) + WAD;
                assertEq(chop, normalizedTestChop, string(abi.encodePacked("TestError/dog-chop-", ilk)));
                // make sure chop is less than 100%
                assertTrue(chop >= WAD && chop < 2 * WAD, string(abi.encodePacked("TestError/dog-chop-range-", ilk)));   // penalty gt eq 0% and lt 100%

                // Convert whole Dai units to expected RAD
                uint256 normalizedTesthole = values.collaterals[ilk].dog_hole * RAD;
                assertEq(hole, normalizedTesthole, string(abi.encodePacked("TestError/dog-hole-", ilk)));
                assertTrue(hole == 0 || hole >= RAD && hole <= 50 * MILLION * RAD, string(abi.encodePacked("TestError/dog-hole-range-", ilk)));
                }
                (address clipper,,,) = dog.ilks(ilk);
                ClipAbstract clip = ClipAbstract(clipper);
                {
                // Convert BP to system expected value
                uint256 normalizedTestBuf = values.collaterals[ilk].clip_buf * 10**23;
                assertEq(uint256(clip.buf()), normalizedTestBuf, string(abi.encodePacked("TestError/clip-buf-", ilk)));
                assertTrue(clip.buf() >= RAY && clip.buf() <= 2 * RAY, string(abi.encodePacked("TestError/clip-buf-range-", ilk))); // gte 0% and lte 100%
                assertEq(uint256(clip.tail()), values.collaterals[ilk].clip_tail, string(abi.encodePacked("TestError/clip-tail-", ilk)));
                assertTrue(clip.tail() >= 1200 && clip.tail() < 10 hours, string(abi.encodePacked("TestError/clip-tail-range-", ilk))); // gt eq 20 minutes and lt 10 hours
                uint256 normalizedTestCusp = (values.collaterals[ilk].clip_cusp)  * 10**23;
                assertEq(uint256(clip.cusp()), normalizedTestCusp, string(abi.encodePacked("TestError/clip-cusp-", ilk)));
                assertTrue(clip.cusp() >= RAY / 10 && clip.cusp() < RAY, string(abi.encodePacked("TestError/clip-cusp-range-", ilk))); // gte 10% and lt 100%
                assertTrue(rmul(clip.buf(), clip.cusp()) <= RAY, string(abi.encodePacked("TestError/clip-buf-cusp-limit-", ilk)));
                uint256 normalizedTestChip = (values.collaterals[ilk].clip_chip)  * 10**14;
                assertEq(uint256(clip.chip()), normalizedTestChip, string(abi.encodePacked("TestError/clip-chip-", ilk)));
                assertTrue(clip.chip() < 1 * WAD / 100, string(abi.encodePacked("TestError/clip-chip-range-", ilk))); // lt 1%
                uint256 normalizedTestTip = values.collaterals[ilk].clip_tip * RAD;
                assertEq(uint256(clip.tip()), normalizedTestTip, string(abi.encodePacked("TestError/clip-tip-", ilk)));
                assertTrue(clip.tip() == 0 || clip.tip() >= RAD && clip.tip() <= 300 * RAD, string(abi.encodePacked("TestError/clip-tip-range-", ilk)));

                assertEq(clip.wards(address(clipMom)), values.collaterals[ilk].clipper_mom, string(abi.encodePacked("TestError/clip-clipperMom-auth-", ilk)));

                assertEq(clipMom.tolerance(address(clip)), values.collaterals[ilk].cm_tolerance * RAY / 10000, string(abi.encodePacked("TestError/clipperMom-tolerance-", ilk)));

                if (values.collaterals[ilk].liqOn) {
                    assertEq(clip.stopped(), 0, string(abi.encodePacked("TestError/clip-liqOn-", ilk)));
                } else {
                    assertTrue(clip.stopped() > 0, string(abi.encodePacked("TestError/clip-liqOn-", ilk)));
                }

                assertEq(clip.wards(address(pauseProxy)), 1, string(abi.encodePacked("TestError/clip-pause-proxy-auth-", ilk))); // Check pause_proxy ward
                }
                {
                    (bool exists, bytes memory value) = clip.calc().call(abi.encodeWithSignature("tau()"));
                    assertEq(exists ? abi.decode(value, (uint256)) : 0, values.collaterals[ilk].calc_tau, string(abi.encodePacked("TestError/calc-tau-", ilk)));
                    (exists, value) = clip.calc().call(abi.encodeWithSignature("step()"));
                    assertEq(exists ? abi.decode(value, (uint256)) : 0, values.collaterals[ilk].calc_step, string(abi.encodePacked("TestError/calc-step-", ilk)));
                    if (exists) {
                       assertTrue(abi.decode(value, (uint256)) > 0, string(abi.encodePacked("TestError/calc-step-is-zero-", ilk)));
                    }
                    (exists, value) = clip.calc().call(abi.encodeWithSignature("cut()"));
                    uint256 normalizedTestCut = values.collaterals[ilk].calc_cut * 10**23;
                    assertEq(exists ? abi.decode(value, (uint256)) : 0, normalizedTestCut, string(abi.encodePacked("TestError/calc-cut-", ilk)));
                    if (exists) {
                       assertTrue(abi.decode(value, (uint256)) > 0 && abi.decode(value, (uint256)) < RAY, string(abi.encodePacked("TestError/calc-cut-range-", ilk)));
                    }
                }
            }
            if (reg.class(ilk) < 3) {
                {
                GemJoinAbstract join = GemJoinAbstract(reg.join(ilk));
                assertEq(join.wards(address(pauseProxy)), 1, string(abi.encodePacked("TestError/join-pause-proxy-auth-", ilk))); // Check pause_proxy ward
                }
            }
        }
        assertEq(sumlines + values.line_offset * RAD, vat.Line(), "TestError/vat-Line");
    }

    function getOSMPrice(address pip) internal returns (uint256) {
        // hevm.load is to pull the price from the LP Oracle storage bypassing the whitelist
        uint256 price = uint256(hevm.load(
            pip,
            bytes32(uint256(3))
        )) & uint128(-1);   // Price is in the second half of the 32-byte storage slot

        // Price is bounded in the spot by around 10^23
        // Give a 10^9 buffer for price appreciation over time
        // Note: This currently can't be hit due to the uint112, but we want to backstop
        //       once the PIP uint256 size is increased
        assertTrue(price <= (10 ** 14) * WAD);

        return price;
    }

    function getUNIV2LPPrice(address pip) internal returns (uint256) {
        // hevm.load is to pull the price from the LP Oracle storage bypassing the whitelist
        uint256 price = uint256(hevm.load(
            pip,
            bytes32(uint256(6))
        )) & uint128(-1);   // Price is in the second half of the 32-byte storage slot

        // Price is bounded in the spot by around 10^23
        // Give a 10^9 buffer for price appreciation over time
        // Note: This currently can't be hit due to the uint112, but we want to backstop
        //       once the PIP uint256 size is increased
        assertTrue(price <= (10 ** 14) * WAD);

        return price;
    }

    function giveTokens(DSTokenAbstract token, uint256 amount) internal {
        // Edge case - balance is already set for some reason
        if (token.balanceOf(address(this)) == amount) return;

        for (int i = 0; i < 200; i++) {
            // Scan the storage for the balance storage slot
            bytes32 prevValue = hevm.load(
                address(token),
                keccak256(abi.encode(address(this), uint256(i)))
            );
            hevm.store(
                address(token),
                keccak256(abi.encode(address(this), uint256(i))),
                bytes32(amount)
            );
            if (token.balanceOf(address(this)) == amount) {
                // Found it
                return;
            } else {
                // Keep going after restoring the original value
                hevm.store(
                    address(token),
                    keccak256(abi.encode(address(this), uint256(i))),
                    prevValue
                );
            }
        }

        // We have failed if we reach here
        assertTrue(false);
    }

    function giveAuth(address _base, address target) internal {
        AuthLike base = AuthLike(_base);

        // Edge case - ward is already set
        if (base.wards(target) == 1) return;

        for (int i = 0; i < 100; i++) {
            // Scan the storage for the ward storage slot
            bytes32 prevValue = hevm.load(
                address(base),
                keccak256(abi.encode(target, uint256(i)))
            );
            hevm.store(
                address(base),
                keccak256(abi.encode(target, uint256(i))),
                bytes32(uint256(1))
            );
            if (base.wards(target) == 1) {
                // Found it
                return;
            } else {
                // Keep going after restoring the original value
                hevm.store(
                    address(base),
                    keccak256(abi.encode(target, uint256(i))),
                    prevValue
                );
            }
        }

        // We have failed if we reach here
        assertTrue(false);
    }

    function getExtcodesize(address target) public view returns (uint256 exsize) {
        assembly {
            exsize := extcodesize(target)
        }
    }

    function testSpellIsCast_GENERAL() public {
        string memory description = new DssSpell().description();
        assertTrue(bytes(description).length > 0, "TestError/spell-description-length");
        // DS-Test can't handle strings directly, so cast to a bytes32.
        assertEq(stringToBytes32(spell.description()),
                stringToBytes32(description), "TestError/spell-description");

        if(address(spell) != address(spellValues.deployed_spell)) {
            assertEq(spell.expiration(), block.timestamp + spellValues.expiration_threshold, "TestError/spell-expiration");
        } else {
            assertEq(spell.expiration(), spellValues.deployed_spell_created + spellValues.expiration_threshold, "TestError/spell-expiration");

            // If the spell is deployed compare the on-chain bytecode size with the generated bytecode size.
            // extcodehash doesn't match, potentially because it's address-specific, avenue for further research.
            address depl_spell = spellValues.deployed_spell;
            address code_spell = address(new DssSpell());
            assertEq(getExtcodesize(depl_spell), getExtcodesize(code_spell), "TestError/spell-codesize");
        }

        assertTrue(spell.officeHours() == spellValues.office_hours_enabled, "TestError/spell-office-hours");

        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done(), "TestError/spell-not-done");

        checkSystemValues(afterSpell);

        checkCollateralValues(afterSpell);
    }

    function testNewIlkRegistryValues() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        IlkRegistryAbstract ilkRegistry = IlkRegistryAbstract(addr.addr("ILK_REGISTRY"));

        assertEq(ilkRegistry.join("ETH-A"), addr.addr("MCD_JOIN_ETH_A"));
        assertEq(ilkRegistry.gem("ETH-A"), addr.addr("ETH"));
        assertEq(ilkRegistry.dec("ETH-A"), DSTokenAbstract(addr.addr("ETH")).decimals());
        assertEq(ilkRegistry.class("ETH-A"), 1);
        assertEq(ilkRegistry.pip("ETH-A"), addr.addr("PIP_ETH"));
        assertEq(ilkRegistry.xlip("ETH-A"), addr.addr("MCD_CLIP_ETH_A"));
        // assertEq(ilkRegistry.name("ETH-A"), "Wrapped Ether");
        assertEq(ilkRegistry.symbol("ETH-A"), "WETH");

        assertEq(ilkRegistry.join("ETH-B"), addr.addr("MCD_JOIN_ETH_B"));
        assertEq(ilkRegistry.gem("ETH-B"), addr.addr("ETH"));
        assertEq(ilkRegistry.dec("ETH-B"), DSTokenAbstract(addr.addr("ETH")).decimals());
        assertEq(ilkRegistry.class("ETH-B"), 1);
        assertEq(ilkRegistry.pip("ETH-B"), addr.addr("PIP_ETH"));
        assertEq(ilkRegistry.xlip("ETH-B"), addr.addr("MCD_CLIP_ETH_B"));
        // assertEq(ilkRegistry.name("ETH-B"), "Wrapped Ether");
        assertEq(ilkRegistry.symbol("ETH-B"), "WETH");

        assertEq(ilkRegistry.join("ETH-C"), addr.addr("MCD_JOIN_ETH_C"));
        assertEq(ilkRegistry.gem("ETH-C"), addr.addr("ETH"));
        assertEq(ilkRegistry.dec("ETH-C"), DSTokenAbstract(addr.addr("ETH")).decimals());
        assertEq(ilkRegistry.class("ETH-C"), 1);
        assertEq(ilkRegistry.pip("ETH-C"), addr.addr("PIP_ETH"));
        assertEq(ilkRegistry.xlip("ETH-C"), addr.addr("MCD_CLIP_ETH_C"));
        // assertEq(ilkRegistry.name("ETH-C"), "Wrapped Ether");
        assertEq(ilkRegistry.symbol("ETH-C"), "WETH");

        assertEq(ilkRegistry.join("BAT-A"), addr.addr("MCD_JOIN_BAT_A"));
        assertEq(ilkRegistry.gem("BAT-A"), addr.addr("BAT"));
        assertEq(ilkRegistry.dec("BAT-A"), DSTokenAbstract(addr.addr("BAT")).decimals());
        assertEq(ilkRegistry.class("BAT-A"), 1);
        assertEq(ilkRegistry.pip("BAT-A"), addr.addr("PIP_BAT"));
        assertEq(ilkRegistry.xlip("BAT-A"), addr.addr("MCD_CLIP_BAT_A"));
        // assertEq(ilkRegistry.name("BAT-A"), "BAT-A");
        assertEq(ilkRegistry.symbol("BAT-A"), "BAT");

        assertEq(ilkRegistry.join("USDC-A"), addr.addr("MCD_JOIN_USDC_A"));
        assertEq(ilkRegistry.gem("USDC-A"), addr.addr("USDC"));
        assertEq(ilkRegistry.dec("USDC-A"), DSTokenAbstract(addr.addr("USDC")).decimals());
        assertEq(ilkRegistry.class("USDC-A"), 1);
        assertEq(ilkRegistry.pip("USDC-A"), addr.addr("PIP_USDC"));
        assertEq(ilkRegistry.xlip("USDC-A"), addr.addr("MCD_CLIP_USDC_A"));
        // assertEq(ilkRegistry.name("USDC-A"), "USDC-A");
        assertEq(ilkRegistry.symbol("USDC-A"), "USDC");

        assertEq(ilkRegistry.join("USDC-B"), addr.addr("MCD_JOIN_USDC_B"));
        assertEq(ilkRegistry.gem("USDC-B"), addr.addr("USDC"));
        assertEq(ilkRegistry.dec("USDC-B"), DSTokenAbstract(addr.addr("USDC")).decimals());
        assertEq(ilkRegistry.class("USDC-B"), 1);
        assertEq(ilkRegistry.pip("USDC-B"), addr.addr("PIP_USDC"));
        assertEq(ilkRegistry.xlip("USDC-B"), addr.addr("MCD_CLIP_USDC_B"));
        // assertEq(ilkRegistry.name("USDC-B"), "USDC-B");
        assertEq(ilkRegistry.symbol("USDC-B"), "USDC");

        assertEq(ilkRegistry.join("TUSD-A"), addr.addr("MCD_JOIN_TUSD_A"));
        assertEq(ilkRegistry.gem("TUSD-A"), addr.addr("TUSD"));
        assertEq(ilkRegistry.dec("TUSD-A"), DSTokenAbstract(addr.addr("TUSD")).decimals());
        assertEq(ilkRegistry.class("TUSD-A"), 1);
        assertEq(ilkRegistry.pip("TUSD-A"), addr.addr("PIP_TUSD"));
        assertEq(ilkRegistry.xlip("TUSD-A"), addr.addr("MCD_CLIP_TUSD_A"));
        // assertEq(ilkRegistry.name("TUSD-A"), "TUSD-A");
        assertEq(ilkRegistry.symbol("TUSD-A"), "TUSD");

        assertEq(ilkRegistry.join("WBTC-A"), addr.addr("MCD_JOIN_WBTC_A"));
        assertEq(ilkRegistry.gem("WBTC-A"), addr.addr("WBTC"));
        assertEq(ilkRegistry.dec("WBTC-A"), DSTokenAbstract(addr.addr("WBTC")).decimals());
        assertEq(ilkRegistry.class("WBTC-A"), 1);
        assertEq(ilkRegistry.pip("WBTC-A"), addr.addr("PIP_WBTC"));
        assertEq(ilkRegistry.xlip("WBTC-A"), addr.addr("MCD_CLIP_WBTC_A"));
        // assertEq(ilkRegistry.name("WBTC-A"), "WBTC-A");
        assertEq(ilkRegistry.symbol("WBTC-A"), "WBTC");

        assertEq(ilkRegistry.join("ZRX-A"), addr.addr("MCD_JOIN_ZRX_A"));
        assertEq(ilkRegistry.gem("ZRX-A"), addr.addr("ZRX"));
        assertEq(ilkRegistry.dec("ZRX-A"), DSTokenAbstract(addr.addr("ZRX")).decimals());
        assertEq(ilkRegistry.class("ZRX-A"), 1);
        assertEq(ilkRegistry.pip("ZRX-A"), addr.addr("PIP_ZRX"));
        assertEq(ilkRegistry.xlip("ZRX-A"), addr.addr("MCD_CLIP_ZRX_A"));
        // assertEq(ilkRegistry.name("ZRX-A"), "ZRX-A");
        assertEq(ilkRegistry.symbol("ZRX-A"), "ZRX");

        assertEq(ilkRegistry.join("KNC-A"), addr.addr("MCD_JOIN_KNC_A"));
        assertEq(ilkRegistry.gem("KNC-A"), addr.addr("KNC"));
        assertEq(ilkRegistry.dec("KNC-A"), DSTokenAbstract(addr.addr("KNC")).decimals());
        assertEq(ilkRegistry.class("KNC-A"), 1);
        assertEq(ilkRegistry.pip("KNC-A"), addr.addr("PIP_KNC"));
        assertEq(ilkRegistry.xlip("KNC-A"), addr.addr("MCD_CLIP_KNC_A"));
        // assertEq(ilkRegistry.name("KNC-A"), "KNC-A");
        assertEq(ilkRegistry.symbol("KNC-A"), "KNC");

        assertEq(ilkRegistry.join("MANA-A"), addr.addr("MCD_JOIN_MANA_A"));
        assertEq(ilkRegistry.gem("MANA-A"), addr.addr("MANA"));
        assertEq(ilkRegistry.dec("MANA-A"), DSTokenAbstract(addr.addr("MANA")).decimals());
        assertEq(ilkRegistry.class("MANA-A"), 1);
        assertEq(ilkRegistry.pip("MANA-A"), addr.addr("PIP_MANA"));
        assertEq(ilkRegistry.xlip("MANA-A"), addr.addr("MCD_CLIP_MANA_A"));
        // assertEq(ilkRegistry.name("MANA-A"), "MANA-A");
        assertEq(ilkRegistry.symbol("MANA-A"), "MANA");

        assertEq(ilkRegistry.join("USDT-A"), addr.addr("MCD_JOIN_USDT_A"));
        assertEq(ilkRegistry.gem("USDT-A"), addr.addr("USDT"));
        assertEq(ilkRegistry.dec("USDT-A"), DSTokenAbstract(addr.addr("USDT")).decimals());
        assertEq(ilkRegistry.class("USDT-A"), 1);
        assertEq(ilkRegistry.pip("USDT-A"), addr.addr("PIP_USDT"));
        assertEq(ilkRegistry.xlip("USDT-A"), addr.addr("MCD_CLIP_USDT_A"));
        // assertEq(ilkRegistry.name("USDT-A"), "USDT-A");
        assertEq(ilkRegistry.symbol("USDT-A"), "USDT");

        assertEq(ilkRegistry.join("PAXUSD-A"), addr.addr("MCD_JOIN_PAXUSD_A"));
        assertEq(ilkRegistry.gem("PAXUSD-A"), addr.addr("PAXUSD"));
        assertEq(ilkRegistry.dec("PAXUSD-A"), DSTokenAbstract(addr.addr("PAXUSD")).decimals());
        assertEq(ilkRegistry.class("PAXUSD-A"), 1);
        assertEq(ilkRegistry.pip("PAXUSD-A"), addr.addr("PIP_PAXUSD"));
        assertEq(ilkRegistry.xlip("PAXUSD-A"), addr.addr("MCD_CLIP_PAXUSD_A"));
        // assertEq(ilkRegistry.name("PAXUSD-A"), "PAXUSD-A");
        assertEq(ilkRegistry.symbol("PAXUSD-A"), "PAX");

        assertEq(ilkRegistry.join("COMP-A"), addr.addr("MCD_JOIN_COMP_A"));
        assertEq(ilkRegistry.gem("COMP-A"), addr.addr("COMP"));
        assertEq(ilkRegistry.dec("COMP-A"), DSTokenAbstract(addr.addr("COMP")).decimals());
        assertEq(ilkRegistry.class("COMP-A"), 1);
        assertEq(ilkRegistry.pip("COMP-A"), addr.addr("PIP_COMP"));
        assertEq(ilkRegistry.xlip("COMP-A"), addr.addr("MCD_CLIP_COMP_A"));
        // assertEq(ilkRegistry.name("COMP-A"), "COMP-A");
        assertEq(ilkRegistry.symbol("COMP-A"), "COMP");

        assertEq(ilkRegistry.join("LRC-A"), addr.addr("MCD_JOIN_LRC_A"));
        assertEq(ilkRegistry.gem("LRC-A"), addr.addr("LRC"));
        assertEq(ilkRegistry.dec("LRC-A"), DSTokenAbstract(addr.addr("LRC")).decimals());
        assertEq(ilkRegistry.class("LRC-A"), 1);
        assertEq(ilkRegistry.pip("LRC-A"), addr.addr("PIP_LRC"));
        assertEq(ilkRegistry.xlip("LRC-A"), addr.addr("MCD_CLIP_LRC_A"));
        // assertEq(ilkRegistry.name("LRC-A"), "LRC-A");
        assertEq(ilkRegistry.symbol("LRC-A"), "LRC");

        assertEq(ilkRegistry.join("LINK-A"), addr.addr("MCD_JOIN_LINK_A"));
        assertEq(ilkRegistry.gem("LINK-A"), addr.addr("LINK"));
        assertEq(ilkRegistry.dec("LINK-A"), DSTokenAbstract(addr.addr("LINK")).decimals());
        assertEq(ilkRegistry.class("LINK-A"), 1);
        assertEq(ilkRegistry.pip("LINK-A"), addr.addr("PIP_LINK"));
        assertEq(ilkRegistry.xlip("LINK-A"), addr.addr("MCD_CLIP_LINK_A"));
        // assertEq(ilkRegistry.name("LINK-A"), "LINK-A");
        assertEq(ilkRegistry.symbol("LINK-A"), "LINK");

        assertEq(ilkRegistry.join("BAL-A"), addr.addr("MCD_JOIN_BAL_A"));
        assertEq(ilkRegistry.gem("BAL-A"), addr.addr("BAL"));
        assertEq(ilkRegistry.dec("BAL-A"), DSTokenAbstract(addr.addr("BAL")).decimals());
        assertEq(ilkRegistry.class("BAL-A"), 1);
        assertEq(ilkRegistry.pip("BAL-A"), addr.addr("PIP_BAL"));
        assertEq(ilkRegistry.xlip("BAL-A"), addr.addr("MCD_CLIP_BAL_A"));
        // assertEq(ilkRegistry.name("BAL-A"), "BAL-A");
        assertEq(ilkRegistry.symbol("BAL-A"), "BAL");

        assertEq(ilkRegistry.join("YFI-A"), addr.addr("MCD_JOIN_YFI_A"));
        assertEq(ilkRegistry.gem("YFI-A"), addr.addr("YFI"));
        assertEq(ilkRegistry.dec("YFI-A"), DSTokenAbstract(addr.addr("YFI")).decimals());
        assertEq(ilkRegistry.class("YFI-A"), 1);
        assertEq(ilkRegistry.pip("YFI-A"), addr.addr("PIP_YFI"));
        assertEq(ilkRegistry.xlip("YFI-A"), addr.addr("MCD_CLIP_YFI_A"));
        // assertEq(ilkRegistry.name("YFI-A"), "YFI-A");
        assertEq(ilkRegistry.symbol("YFI-A"), "YFI");

        assertEq(ilkRegistry.join("GUSD-A"), addr.addr("MCD_JOIN_GUSD_A"));
        assertEq(ilkRegistry.gem("GUSD-A"), addr.addr("GUSD"));
        assertEq(ilkRegistry.dec("GUSD-A"), DSTokenAbstract(addr.addr("GUSD")).decimals());
        assertEq(ilkRegistry.class("GUSD-A"), 1);
        assertEq(ilkRegistry.pip("GUSD-A"), addr.addr("PIP_GUSD"));
        assertEq(ilkRegistry.xlip("GUSD-A"), addr.addr("MCD_CLIP_GUSD_A"));
        // assertEq(ilkRegistry.name("GUSD-A"), "GUSD-A");
        assertEq(ilkRegistry.symbol("GUSD-A"), "GUSD");

        assertEq(ilkRegistry.join("UNI-A"), addr.addr("MCD_JOIN_UNI_A"));
        assertEq(ilkRegistry.gem("UNI-A"), addr.addr("UNI"));
        assertEq(ilkRegistry.dec("UNI-A"), DSTokenAbstract(addr.addr("UNI")).decimals());
        assertEq(ilkRegistry.class("UNI-A"), 1);
        assertEq(ilkRegistry.pip("UNI-A"), addr.addr("PIP_UNI"));
        assertEq(ilkRegistry.xlip("UNI-A"), addr.addr("MCD_CLIP_UNI_A"));
        // assertEq(ilkRegistry.name("UNI-A"), "UNI-A");
        assertEq(ilkRegistry.symbol("UNI-A"), "UNI");

        assertEq(ilkRegistry.join("RENBTC-A"), addr.addr("MCD_JOIN_RENBTC_A"));
        assertEq(ilkRegistry.gem("RENBTC-A"), addr.addr("RENBTC"));
        assertEq(ilkRegistry.dec("RENBTC-A"), DSTokenAbstract(addr.addr("RENBTC")).decimals());
        assertEq(ilkRegistry.class("RENBTC-A"), 1);
        assertEq(ilkRegistry.pip("RENBTC-A"), addr.addr("PIP_RENBTC"));
        assertEq(ilkRegistry.xlip("RENBTC-A"), addr.addr("MCD_CLIP_RENBTC_A"));
        // assertEq(ilkRegistry.name("RENBTC-A"), "RENBTC-A");
        assertEq(ilkRegistry.symbol("RENBTC-A"), "RENBTC");

        assertEq(ilkRegistry.join("AAVE-A"), addr.addr("MCD_JOIN_AAVE_A"));
        assertEq(ilkRegistry.gem("AAVE-A"), addr.addr("AAVE"));
        assertEq(ilkRegistry.dec("AAVE-A"), DSTokenAbstract(addr.addr("AAVE")).decimals());
        assertEq(ilkRegistry.class("AAVE-A"), 1);
        assertEq(ilkRegistry.pip("AAVE-A"), addr.addr("PIP_AAVE"));
        assertEq(ilkRegistry.xlip("AAVE-A"), addr.addr("MCD_CLIP_AAVE_A"));
        // assertEq(ilkRegistry.name("AAVE-A"), "AAVE-A");
        assertEq(ilkRegistry.symbol("AAVE-A"), "AAVE");
    }

    function testNewChainlogValues() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        ChainlogAbstract chainLog = ChainlogAbstract(addr.addr("CHANGELOG"));

        assertEq(chainLog.getAddress("MULTICALL"), addr.addr("MULTICALL"));
        assertEq(chainLog.getAddress("FAUCET"), addr.addr("FAUCET"));
        assertEq(chainLog.getAddress("MCD_DEPLOY"), addr.addr("MCD_DEPLOY"));
        assertEq(chainLog.getAddress("MCD_GOV"), addr.addr("MCD_GOV"));
        assertEq(chainLog.getAddress("GOV_GUARD"), addr.addr("GOV_GUARD"));
        assertEq(chainLog.getAddress("MCD_IOU"), addr.addr("MCD_IOU"));
        assertEq(chainLog.getAddress("MCD_ADM"), addr.addr("MCD_ADM"));
        assertEq(chainLog.getAddress("VOTE_PROXY_FACTORY"), addr.addr("VOTE_PROXY_FACTORY"));
        assertEq(chainLog.getAddress("MCD_VAT"), addr.addr("MCD_VAT"));
        assertEq(chainLog.getAddress("MCD_JUG"), addr.addr("MCD_JUG"));
        assertEq(chainLog.getAddress("MCD_CAT"), addr.addr("MCD_CAT"));
        assertEq(chainLog.getAddress("MCD_DOG"), addr.addr("MCD_DOG"));
        assertEq(chainLog.getAddress("MCD_VOW"), addr.addr("MCD_VOW"));
        assertEq(chainLog.getAddress("MCD_JOIN_DAI"), addr.addr("MCD_JOIN_DAI"));
        assertEq(chainLog.getAddress("MCD_FLAP"), addr.addr("MCD_FLAP"));
        assertEq(chainLog.getAddress("MCD_FLOP"), addr.addr("MCD_FLOP"));
        assertEq(chainLog.getAddress("MCD_PAUSE"), addr.addr("MCD_PAUSE"));
        assertEq(chainLog.getAddress("MCD_PAUSE_PROXY"), addr.addr("MCD_PAUSE_PROXY"));
        assertEq(chainLog.getAddress("MCD_GOV_ACTIONS"), addr.addr("MCD_GOV_ACTIONS"));
        assertEq(chainLog.getAddress("MCD_DAI"), addr.addr("MCD_DAI"));
        assertEq(chainLog.getAddress("MCD_SPOT"), addr.addr("MCD_SPOT"));
        assertEq(chainLog.getAddress("MCD_POT"), addr.addr("MCD_POT"));
        assertEq(chainLog.getAddress("MCD_END"), addr.addr("MCD_END"));
        assertEq(chainLog.getAddress("MCD_ESM"), addr.addr("MCD_ESM"));
        assertEq(chainLog.getAddress("PROXY_ACTIONS"), addr.addr("PROXY_ACTIONS"));
        assertEq(chainLog.getAddress("PROXY_ACTIONS_END"), addr.addr("PROXY_ACTIONS_END"));
        assertEq(chainLog.getAddress("PROXY_ACTIONS_DSR"), addr.addr("PROXY_ACTIONS_DSR"));
        assertEq(chainLog.getAddress("CDP_MANAGER"), addr.addr("CDP_MANAGER"));
        assertEq(chainLog.getAddress("DSR_MANAGER"), addr.addr("DSR_MANAGER"));
        assertEq(chainLog.getAddress("GET_CDPS"), addr.addr("GET_CDPS"));
        assertEq(chainLog.getAddress("ILK_REGISTRY"), addr.addr("ILK_REGISTRY"));
        assertEq(chainLog.getAddress("OSM_MOM"), addr.addr("OSM_MOM"));
        assertEq(chainLog.getAddress("FLIPPER_MOM"), addr.addr("FLIPPER_MOM"));
        assertEq(chainLog.getAddress("CLIPPER_MOM"), addr.addr("CLIPPER_MOM"));
        assertEq(chainLog.getAddress("MCD_IAM_AUTO_LINE"), addr.addr("MCD_IAM_AUTO_LINE"));
        assertEq(chainLog.getAddress("MCD_FLASH"), addr.addr("MCD_FLASH"));
        assertEq(chainLog.getAddress("PROXY_FACTORY"), addr.addr("PROXY_FACTORY"));
        assertEq(chainLog.getAddress("PROXY_REGISTRY"), addr.addr("PROXY_REGISTRY"));
        assertEq(chainLog.getAddress("ETH"), addr.addr("ETH"));
        assertEq(chainLog.getAddress("PIP_ETH"), addr.addr("PIP_ETH"));
        assertEq(chainLog.getAddress("MCD_JOIN_ETH_A"), addr.addr("MCD_JOIN_ETH_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_ETH_A"), addr.addr("MCD_CLIP_ETH_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_ETH_A"), addr.addr("MCD_CLIP_CALC_ETH_A"));
        assertEq(chainLog.getAddress("MCD_JOIN_ETH_B"), addr.addr("MCD_JOIN_ETH_B"));
        assertEq(chainLog.getAddress("MCD_CLIP_ETH_B"), addr.addr("MCD_CLIP_ETH_B"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_ETH_B"), addr.addr("MCD_CLIP_CALC_ETH_B"));
        assertEq(chainLog.getAddress("MCD_JOIN_ETH_C"), addr.addr("MCD_JOIN_ETH_C"));
        assertEq(chainLog.getAddress("MCD_CLIP_ETH_C"), addr.addr("MCD_CLIP_ETH_C"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_ETH_C"), addr.addr("MCD_CLIP_CALC_ETH_C"));
        assertEq(chainLog.getAddress("BAT"), addr.addr("BAT"));
        assertEq(chainLog.getAddress("PIP_BAT"), addr.addr("PIP_BAT"));
        assertEq(chainLog.getAddress("MCD_JOIN_BAT_A"), addr.addr("MCD_JOIN_BAT_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_BAT_A"), addr.addr("MCD_CLIP_BAT_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_BAT_A"), addr.addr("MCD_CLIP_CALC_BAT_A"));
        assertEq(chainLog.getAddress("USDC"), addr.addr("USDC"));
        assertEq(chainLog.getAddress("PIP_USDC"), addr.addr("PIP_USDC"));
        assertEq(chainLog.getAddress("MCD_JOIN_USDC_A"), addr.addr("MCD_JOIN_USDC_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_USDC_A"), addr.addr("MCD_CLIP_USDC_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_USDC_A"), addr.addr("MCD_CLIP_CALC_USDC_A"));
        assertEq(chainLog.getAddress("MCD_JOIN_USDC_B"), addr.addr("MCD_JOIN_USDC_B"));
        assertEq(chainLog.getAddress("MCD_CLIP_USDC_B"), addr.addr("MCD_CLIP_USDC_B"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_USDC_B"), addr.addr("MCD_CLIP_CALC_USDC_B"));
        assertEq(chainLog.getAddress("TUSD"), addr.addr("TUSD"));
        assertEq(chainLog.getAddress("PIP_TUSD"), addr.addr("PIP_TUSD"));
        assertEq(chainLog.getAddress("MCD_JOIN_TUSD_A"), addr.addr("MCD_JOIN_TUSD_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_TUSD_A"), addr.addr("MCD_CLIP_TUSD_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_TUSD_A"), addr.addr("MCD_CLIP_CALC_TUSD_A"));
        assertEq(chainLog.getAddress("WBTC"), addr.addr("WBTC"));
        assertEq(chainLog.getAddress("PIP_WBTC"), addr.addr("PIP_WBTC"));
        assertEq(chainLog.getAddress("MCD_JOIN_WBTC_A"), addr.addr("MCD_JOIN_WBTC_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_WBTC_A"), addr.addr("MCD_CLIP_WBTC_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_WBTC_A"), addr.addr("MCD_CLIP_CALC_WBTC_A"));
        assertEq(chainLog.getAddress("ZRX"), addr.addr("ZRX"));
        assertEq(chainLog.getAddress("PIP_ZRX"), addr.addr("PIP_ZRX"));
        assertEq(chainLog.getAddress("MCD_JOIN_ZRX_A"), addr.addr("MCD_JOIN_ZRX_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_ZRX_A"), addr.addr("MCD_CLIP_ZRX_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_ZRX_A"), addr.addr("MCD_CLIP_CALC_ZRX_A"));
        assertEq(chainLog.getAddress("KNC"), addr.addr("KNC"));
        assertEq(chainLog.getAddress("PIP_KNC"), addr.addr("PIP_KNC"));
        assertEq(chainLog.getAddress("MCD_JOIN_KNC_A"), addr.addr("MCD_JOIN_KNC_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_KNC_A"), addr.addr("MCD_CLIP_KNC_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_KNC_A"), addr.addr("MCD_CLIP_CALC_KNC_A"));
        assertEq(chainLog.getAddress("MANA"), addr.addr("MANA"));
        assertEq(chainLog.getAddress("PIP_MANA"), addr.addr("PIP_MANA"));
        assertEq(chainLog.getAddress("MCD_JOIN_MANA_A"), addr.addr("MCD_JOIN_MANA_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_MANA_A"), addr.addr("MCD_CLIP_MANA_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_MANA_A"), addr.addr("MCD_CLIP_CALC_MANA_A"));
        assertEq(chainLog.getAddress("USDT"), addr.addr("USDT"));
        assertEq(chainLog.getAddress("PIP_USDT"), addr.addr("PIP_USDT"));
        assertEq(chainLog.getAddress("MCD_JOIN_USDT_A"), addr.addr("MCD_JOIN_USDT_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_USDT_A"), addr.addr("MCD_CLIP_USDT_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_USDT_A"), addr.addr("MCD_CLIP_CALC_USDT_A"));
        assertEq(chainLog.getAddress("PAXUSD"), addr.addr("PAXUSD"));
        assertEq(chainLog.getAddress("PIP_PAXUSD"), addr.addr("PIP_PAXUSD"));
        assertEq(chainLog.getAddress("MCD_JOIN_PAXUSD_A"), addr.addr("MCD_JOIN_PAXUSD_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_PAXUSD_A"), addr.addr("MCD_CLIP_PAXUSD_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_PAXUSD_A"), addr.addr("MCD_CLIP_CALC_PAXUSD_A"));
        assertEq(chainLog.getAddress("COMP"), addr.addr("COMP"));
        assertEq(chainLog.getAddress("PIP_COMP"), addr.addr("PIP_COMP"));
        assertEq(chainLog.getAddress("MCD_JOIN_COMP_A"), addr.addr("MCD_JOIN_COMP_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_COMP_A"), addr.addr("MCD_CLIP_COMP_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_COMP_A"), addr.addr("MCD_CLIP_CALC_COMP_A"));
        assertEq(chainLog.getAddress("LRC"), addr.addr("LRC"));
        assertEq(chainLog.getAddress("PIP_LRC"), addr.addr("PIP_LRC"));
        assertEq(chainLog.getAddress("MCD_JOIN_LRC_A"), addr.addr("MCD_JOIN_LRC_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_LRC_A"), addr.addr("MCD_CLIP_LRC_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_LRC_A"), addr.addr("MCD_CLIP_CALC_LRC_A"));
        assertEq(chainLog.getAddress("LINK"), addr.addr("LINK"));
        assertEq(chainLog.getAddress("PIP_LINK"), addr.addr("PIP_LINK"));
        assertEq(chainLog.getAddress("MCD_JOIN_LINK_A"), addr.addr("MCD_JOIN_LINK_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_LINK_A"), addr.addr("MCD_CLIP_LINK_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_LINK_A"), addr.addr("MCD_CLIP_CALC_LINK_A"));
        assertEq(chainLog.getAddress("BAL"), addr.addr("BAL"));
        assertEq(chainLog.getAddress("PIP_BAL"), addr.addr("PIP_BAL"));
        assertEq(chainLog.getAddress("MCD_JOIN_BAL_A"), addr.addr("MCD_JOIN_BAL_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_BAL_A"), addr.addr("MCD_CLIP_BAL_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_BAL_A"), addr.addr("MCD_CLIP_CALC_BAL_A"));
        assertEq(chainLog.getAddress("YFI"), addr.addr("YFI"));
        assertEq(chainLog.getAddress("PIP_YFI"), addr.addr("PIP_YFI"));
        assertEq(chainLog.getAddress("MCD_JOIN_YFI_A"), addr.addr("MCD_JOIN_YFI_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_YFI_A"), addr.addr("MCD_CLIP_YFI_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_YFI_A"), addr.addr("MCD_CLIP_CALC_YFI_A"));
        assertEq(chainLog.getAddress("GUSD"), addr.addr("GUSD"));
        assertEq(chainLog.getAddress("PIP_GUSD"), addr.addr("PIP_GUSD"));
        assertEq(chainLog.getAddress("MCD_JOIN_GUSD_A"), addr.addr("MCD_JOIN_GUSD_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_GUSD_A"), addr.addr("MCD_CLIP_GUSD_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_GUSD_A"), addr.addr("MCD_CLIP_CALC_GUSD_A"));
        assertEq(chainLog.getAddress("UNI"), addr.addr("UNI"));
        assertEq(chainLog.getAddress("PIP_UNI"), addr.addr("PIP_UNI"));
        assertEq(chainLog.getAddress("MCD_JOIN_UNI_A"), addr.addr("MCD_JOIN_UNI_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_UNI_A"), addr.addr("MCD_CLIP_UNI_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_UNI_A"), addr.addr("MCD_CLIP_CALC_UNI_A"));
        assertEq(chainLog.getAddress("RENBTC"), addr.addr("RENBTC"));
        assertEq(chainLog.getAddress("PIP_RENBTC"), addr.addr("PIP_RENBTC"));
        assertEq(chainLog.getAddress("MCD_JOIN_RENBTC_A"), addr.addr("MCD_JOIN_RENBTC_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_RENBTC_A"), addr.addr("MCD_CLIP_RENBTC_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_RENBTC_A"), addr.addr("MCD_CLIP_CALC_RENBTC_A"));
        assertEq(chainLog.getAddress("AAVE"), addr.addr("AAVE"));
        assertEq(chainLog.getAddress("PIP_AAVE"), addr.addr("PIP_AAVE"));
        assertEq(chainLog.getAddress("MCD_JOIN_AAVE_A"), addr.addr("MCD_JOIN_AAVE_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_AAVE_A"), addr.addr("MCD_CLIP_AAVE_A"));
        assertEq(chainLog.getAddress("MCD_CLIP_CALC_AAVE_A"), addr.addr("MCD_CLIP_CALC_AAVE_A"));
        assertEq(chainLog.getAddress("PROXY_PAUSE_ACTIONS"), addr.addr("PROXY_PAUSE_ACTIONS"));
        assertEq(chainLog.getAddress("PROXY_DEPLOYER"), addr.addr("PROXY_DEPLOYER"));

        // assertEq(chainLog.getAddress(""), addr.addr(""));
    }

    function testFailWrongDay() public {
        require(spell.officeHours() == spellValues.office_hours_enabled);
        if (spell.officeHours()) {
            vote(address(spell));
            scheduleWaitAndCastFailDay();
        } else {
            revert("Office Hours Disabled");
        }
    }

    function testFailTooEarly() public {
        require(spell.officeHours() == spellValues.office_hours_enabled);
        if (spell.officeHours()) {
            vote(address(spell));
            scheduleWaitAndCastFailEarly();
        } else {
            revert("Office Hours Disabled");
        }
    }

    function testFailTooLate() public {
        require(spell.officeHours() == spellValues.office_hours_enabled);
        if (spell.officeHours()) {
            vote(address(spell));
            scheduleWaitAndCastFailLate();
        } else {
            revert("Office Hours Disabled");
        }
    }

    function testOnTime() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
    }

    function testCastCost() public {
        vote(address(spell));
        spell.schedule();

        castPreviousSpell();

        hevm.warp(spell.nextCastTime());
        uint256 startGas = gasleft();
        spell.cast();
        uint256 endGas = gasleft();
        uint256 totalGas = startGas - endGas;

        assertTrue(spell.done());
        // Fail if cast is too expensive
        assertTrue(totalGas <= 10 * MILLION);
    }
}
