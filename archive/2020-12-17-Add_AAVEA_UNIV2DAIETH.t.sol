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

import "ds-math/math.sol";
import "ds-test/test.sol";
import "lib/dss-interfaces/src/Interfaces.sol";
import "./test/rates.sol";
import "./test/addresses_kovan.sol";

import {DssSpell, SpellAction} from "./Kovan-DssSpell.sol";

interface Hevm {
    function warp(uint) external;
    function store(address,bytes32,bytes32) external;
}

interface SpellLike {
    function done() external view returns (bool);
    function cast() external;
}

contract DssSpellTest is DSTest, DSMath {
    // populate with kovan spell if needed
    address constant KOVAN_SPELL = address(0xCd27Fe5De52fF7Fe31cFF0C975B9a5c72311C459);
    // this needs to be updated
    uint256 constant SPELL_CREATED = 1608232308;

    struct CollateralValues {
        bool aL_enabled;
        uint256 aL_line;
        uint256 aL_gap;
        uint256 aL_ttl;
        uint256 line;
        uint256 dust;
        uint256 chop;
        uint256 dunk;
        uint256 pct;
        uint256 mat;
        uint256 beg;
        uint48 ttl;
        uint48 tau;
        uint256 liquidations;
    }

    struct SystemValues {
        uint256 pot_dsr;
        uint256 pause_delay;
        uint256 vow_wait;
        uint256 vow_dump;
        uint256 vow_sump;
        uint256 vow_bump;
        uint256 vow_hump;
        uint256 cat_box;
        address pause_authority;
        address osm_mom_authority;
        address flipper_mom_authority;
        uint256 ilk_count;
        mapping (bytes32 => CollateralValues) collaterals;
    }

    SystemValues afterSpell;

    Hevm      hevm;
    Rates     rates = new Rates();
    Addresses addr  = new Addresses();

    // KOVAN ADDRESSES
    ChainlogAbstract changelog   = ChainlogAbstract(    addr.addr("CHANGELOG"));
    DSPauseAbstract      pause   = DSPauseAbstract(     addr.addr("MCD_PAUSE"));
    address         pauseProxy   =                      addr.addr("MCD_PAUSE_PROXY");
    DSChiefAbstract      chief   = DSChiefAbstract(     addr.addr("MCD_ADM"));
    VatAbstract            vat   = VatAbstract(         addr.addr("MCD_VAT"));
    CatAbstract            cat   = CatAbstract(         addr.addr("MCD_CAT"));
    VowAbstract            vow   = VowAbstract(         addr.addr("MCD_VOW"));
    PotAbstract            pot   = PotAbstract(         addr.addr("MCD_POT"));
    JugAbstract            jug   = JugAbstract(         addr.addr("MCD_JUG"));
    SpotAbstract          spot   = SpotAbstract(        addr.addr("MCD_SPOT"));

    DSTokenAbstract        gov   = DSTokenAbstract(     addr.addr("MCD_GOV"));
    EndAbstract            end   = EndAbstract(         addr.addr("MCD_END"));
    IlkRegistryAbstract    reg   = IlkRegistryAbstract( addr.addr("ILK_REGISTRY"));

    OsmMomAbstract      osmMom   = OsmMomAbstract(      addr.addr("OSM_MOM"));
    FlipperMomAbstract flipMom   = FlipperMomAbstract(  addr.addr("FLIPPER_MOM"));
    DssAutoLineAbstract autoLine = DssAutoLineAbstract( addr.addr("MCD_IAM_AUTO_LINE"));

    // Faucet
    FaucetAbstract      faucet   = FaucetAbstract(      addr.addr("FAUCET"));

    // Spell-specific addresses

    // UNIV2DAIETH-A specific
    DSTokenAbstract     lp = DSTokenAbstract(addr.addr("UNIV2DAIETH"));
    GemJoinAbstract lpJoin = GemJoinAbstract(addr.addr("MCD_JOIN_UNIV2DAIETH_A"));
    FlipAbstract    lpFlip = FlipAbstract(   addr.addr("MCD_FLIP_UNIV2DAIETH_A"));
    LPOsmAbstract    lpPip = LPOsmAbstract(  addr.addr("PIP_UNIV2DAIETH"));
    MedianAbstract    orb0 = MedianAbstract( lpPip.orb0());
    MedianAbstract    orb1 = MedianAbstract( lpPip.orb0());

    // AAVE-A specific
    DSTokenAbstract       aave = DSTokenAbstract(      addr.addr("AAVE"));
    GemJoinAbstract  joinAAVEA = GemJoinAbstract(      addr.addr("MCD_JOIN_AAVE_A"));
    FlipAbstract     flipAAVEA = FlipAbstract(         addr.addr("MCD_FLIP_AAVE_A"));
    OsmAbstract        pipAAVE = OsmAbstract(          addr.addr("PIP_AAVE"));
    MedianAbstract    medAAVEA = MedianAbstract(0xad0421CE93652857fB0f75c8eB3e7DDB8C8AFAaa);


    DssSpell spell;

    // CHEAT_CODE = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
    bytes20 constant CHEAT_CODE =
        bytes20(uint160(uint256(keccak256('hevm cheat code'))));

    uint256 constant HUNDRED    = 10 ** 2;
    uint256 constant THOUSAND   = 10 ** 3;
    uint256 constant MILLION    = 10 ** 6;
    uint256 constant BILLION    = 10 ** 9;
    // TODO: figure out what to do with these.
    //   They error because they are defined in ds-math
    //uint256 constant WAD        = 10 ** 18;
    //uint256 constant RAY        = 10 ** 27;
    uint256 constant RAD        = 10 ** 45;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.01)/(60 * 60 * 24 * 365) )'
    //
    // Rates table is in ./test/rates.sol

    // not provided in DSMath
    function rpow(uint x, uint n, uint b) internal pure returns (uint z) {
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

    function setUp() public {
        hevm = Hevm(address(CHEAT_CODE));

        spell = KOVAN_SPELL != address(0) ? DssSpell(KOVAN_SPELL) : new DssSpell();

        //
        // Test for all system configuration changes
        //
        afterSpell = SystemValues({
            pot_dsr:               0,                   // In basis points
            pause_delay:           60,                  // In seconds
            vow_wait:              3600,                // In seconds
            vow_dump:              2,                   // In whole Dai units
            vow_sump:              50,                  // In whole Dai units
            vow_bump:              10,                  // In whole Dai units
            vow_hump:              500,                 // In whole Dai units
            cat_box:               10 * THOUSAND,       // In whole Dai units
            pause_authority:       address(chief),      // Pause authority
            osm_mom_authority:     address(chief),      // OsmMom authority
            flipper_mom_authority: address(chief),      // FlipperMom authority
            ilk_count:             22                   // Num expected in system
        });

        //
        // Test for all collateral based changes here
        //
        afterSpell.collaterals["ETH-A"] = CollateralValues({
            aL_enabled:   false,           // DssAutoLine is enabled?
            aL_line:      0 * MILLION,     // In whole Dai units
            aL_gap:       0 * MILLION,     // In whole Dai units
            aL_ttl:       0,               // In seconds
            line:         540 * MILLION,   // In whole Dai units
            dust:         100,             // In whole Dai units
            pct:          0,               // In basis points
            chop:         1300,            // In basis points
            dunk:         500,             // In whole Dai units
            mat:          15000,           // In basis points
            beg:          300,             // In basis points
            ttl:          1 hours,         // In seconds
            tau:          1 hours,         // In seconds
            liquidations: 1                // 1 if enabled
        });
        afterSpell.collaterals["ETH-B"] = CollateralValues({
            aL_enabled:   true,
            aL_line:      50 * MILLION,
            aL_gap:       5 * MILLION,
            aL_ttl:       12 hours,
            line:         0 * MILLION,     // Not being checked as there is auto line
            dust:         100,
            pct:          600,
            chop:         1300,
            dunk:         500,
            mat:          13000,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["BAT-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         5 * MILLION,
            dust:         100,
            pct:          400,
            chop:         1300,
            dunk:         500,
            mat:          15000,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["USDC-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         400 * MILLION,
            dust:         100,
            pct:          400,
            chop:         1300,
            dunk:         500,
            mat:          10100,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 0
        });
        afterSpell.collaterals["USDC-B"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         30 * MILLION,
            dust:         100,
            pct:          5000,
            chop:         1300,
            dunk:         500,
            mat:          12000,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 0
        });
        afterSpell.collaterals["WBTC-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         120 * MILLION,
            dust:         100,
            pct:          400,
            chop:         1300,
            dunk:         500,
            mat:          15000,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["TUSD-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         50 * MILLION,
            dust:         100,
            pct:          400,
            chop:         1300,
            dunk:         500,
            mat:          10100,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 0
        });
        afterSpell.collaterals["KNC-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         5 * MILLION,
            dust:         100,
            pct:          400,
            chop:         1300,
            dunk:         500,
            mat:          17500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["ZRX-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         5 * MILLION,
            dust:         100,
            pct:          400,
            chop:         1300,
            dunk:         500,
            mat:          17500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["MANA-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         1 * MILLION,
            dust:         100,
            pct:          1200,
            chop:         1300,
            dunk:         500,
            mat:          17500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["USDT-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         10 * MILLION,
            dust:         100,
            pct:          800,
            chop:         1300,
            dunk:         500,
            mat:          15000,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["PAXUSD-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         30 * MILLION,
            dust:         100,
            pct:          400,
            chop:         1300,
            dunk:         500,
            mat:          10100,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 0
        });
        afterSpell.collaterals["COMP-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         7 * MILLION,
            dust:         100,
            pct:          100,
            chop:         1300,
            dunk:         500,
            mat:          17500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["LRC-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         3 * MILLION,
            dust:         100,
            pct:          300,
            chop:         1300,
            dunk:         500,
            mat:          17500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["LINK-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         5 * MILLION,
            dust:         100,
            pct:          200,
            chop:         1300,
            dunk:         500,
            mat:          17500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["BAL-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         4 * MILLION,
            dust:         100,
            pct:          500,
            chop:         1300,
            dunk:         500,
            mat:          17500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["YFI-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         7 * MILLION,
            dust:         100,
            pct:          400,
            chop:         1300,
            dunk:         500,
            mat:          17500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["GUSD-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         5 * MILLION,
            dust:         100,
            pct:          400,
            chop:         1300,
            dunk:         500,
            mat:          10100,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 0
        });
        afterSpell.collaterals["UNI-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         15 * MILLION,
            dust:         100,
            pct:          300,
            chop:         1300,
            dunk:         500,
            mat:          17500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["RENBTC-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         2 * MILLION,
            dust:         100,
            pct:          600,
            chop:         1300,
            dunk:         500,
            mat:          17500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["AAVE-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         10 * MILLION,
            dust:         100,
            pct:          600,
            chop:         1300,
            dunk:         500,
            mat:          17500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["UNIV2DAIETH-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         3 * MILLION,
            dust:         100,
            pct:          100,
            chop:         1300,
            dunk:         500,
            mat:          12500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
    }

    function vote() private {
        if (chief.hat() != address(spell)) {
            hevm.store(
                address(gov),
                keccak256(abi.encode(address(this), uint256(1))),
                bytes32(uint256(999999999999 ether))
            );
            gov.approve(address(chief), uint256(-1));
            chief.lock(999999999999 ether);

            address[] memory slate = new address[](1);

            if (chief.live() == 0) {
                // Launch system
                slate[0] = address(0);
                chief.vote(slate);
                if (chief.hat() != address(0)) {
                    chief.lift(address(0));
                }
                assertEq(chief.live(), 0);
                assertTrue(!chief.isUserRoot(address(0)));
                chief.launch();
                assertEq(chief.live(), 1);
                assertTrue(chief.isUserRoot(address(0)));
            }

            assertTrue(!spell.done());

            slate[0] = address(spell);

            chief.vote(slate);
            chief.lift(address(spell));
        }
        assertEq(chief.hat(), address(spell));
    }

    function scheduleWaitAndCast() public {
        spell.schedule();

        uint256 castTime = now + pause.delay();

        uint256 day = (castTime / 1 days + 3) % 7;
        if(day >= 5) {
            castTime += 7 days - day * 86400;
        }

        uint256 hour = castTime / 1 hours % 24;
        if (hour >= 21) {
            castTime += 24 hours - hour * 3600 + 14 hours;
        } else if (hour < 14) {
            castTime += 14 hours - hour * 3600;
        }

        hevm.warp(castTime);
        spell.cast();
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }

    function checkSystemValues(SystemValues storage values) internal {
        // dsr
        uint expectedDSRRate = rates.rates(values.pot_dsr);
        // make sure dsr is less than 100% APR
        // bc -l <<< 'scale=27; e( l(2.00)/(60 * 60 * 24 * 365) )'
        // 1000000021979553151239153027
        assertTrue(
            pot.dsr() >= RAY && pot.dsr() < 1000000021979553151239153027
        );
        assertTrue(diffCalc(expectedRate(values.pot_dsr), yearlyYield(expectedDSRRate)) <= TOLERANCE);

        {
        // Line values in RAD
        assertTrue(
            (vat.Line() >= RAD && vat.Line() < 100 * BILLION * RAD) ||
            vat.Line() == 0
        );
        }

        // Pause delay
        assertEq(pause.delay(), values.pause_delay);

        // wait
        assertEq(vow.wait(), values.vow_wait);
        {
        // dump values in WAD
        uint normalizedDump = values.vow_dump * WAD;
        assertEq(vow.dump(), normalizedDump);
        assertTrue(
            (vow.dump() >= WAD && vow.dump() < 2 * THOUSAND * WAD) ||
            vow.dump() == 0
        );
        }
        {
        // sump values in RAD
        uint normalizedSump = values.vow_sump * RAD;
        assertEq(vow.sump(), normalizedSump);
        assertTrue(
            (vow.sump() >= RAD && vow.sump() < 500 * THOUSAND * RAD) ||
            vow.sump() == 0
        );
        }
        {
        // bump values in RAD
        uint normalizedBump = values.vow_bump * RAD;
        assertEq(vow.bump(), normalizedBump);
        assertTrue(
            (vow.bump() >= RAD && vow.bump() < HUNDRED * THOUSAND * RAD) ||
            vow.bump() == 0
        );
        }
        {
        // hump values in RAD
        uint normalizedHump = values.vow_hump * RAD;
        assertEq(vow.hump(), normalizedHump);
        assertTrue(
            (vow.hump() >= RAD && vow.hump() < HUNDRED * MILLION * RAD) ||
            vow.hump() == 0
        );
        }

        // box values in RAD
        {
            uint normalizedBox = values.cat_box * RAD;
            assertEq(cat.box(), normalizedBox);
        }

        // check Pause authority
        assertEq(pause.authority(), values.pause_authority);

        // check OsmMom authority
        assertEq(osmMom.authority(), values.osm_mom_authority);

        // check FlipperMom authority
        assertEq(flipMom.authority(), values.flipper_mom_authority);

        // check number of ilks
        assertEq(reg.count(), values.ilk_count);
    }

    function checkCollateralValues(SystemValues storage values) internal {
        uint256 sumlines;
        bytes32[] memory ilks = reg.list();
        for(uint256 i = 0; i < ilks.length; i++) {
            bytes32 ilk = ilks[i];
            (uint256 duty,)  = jug.ilks(ilk);

            assertEq(duty, rates.rates(values.collaterals[ilk].pct));
            // make sure duty is less than 1000% APR
            // bc -l <<< 'scale=27; e( l(10.00)/(60 * 60 * 24 * 365) )'
            // 1000000073014496989316680335
            assertTrue(duty >= RAY && duty < 1000000073014496989316680335);  // gt 0 and lt 1000%
            assertTrue(diffCalc(expectedRate(values.collaterals[ilk].pct), yearlyYield(rates.rates(values.collaterals[ilk].pct))) <= TOLERANCE);
            assertTrue(values.collaterals[ilk].pct < THOUSAND * THOUSAND);   // check value lt 1000%
            {
            (,,, uint256 line, uint256 dust) = vat.ilks(ilk);
            // Convert whole Dai units to expected RAD
            uint256 normalizedTestLine = values.collaterals[ilk].line * RAD;
            sumlines += line;
            (uint256 aL_line, uint256 aL_gap, uint256 aL_ttl,,) = autoLine.ilks(ilk);
            if (!values.collaterals[ilk].aL_enabled) {
                assertTrue(aL_line == 0);
                assertEq(line, normalizedTestLine);
                assertTrue((line >= RAD && line < BILLION * RAD) || line == 0);  // eq 0 or gt eq 1 RAD and lt 1B
            } else {
                assertTrue(aL_line > 0);
                assertEq(aL_line, values.collaterals[ilk].aL_line * RAD);
                assertEq(aL_gap, values.collaterals[ilk].aL_gap * RAD);
                assertEq(aL_ttl, values.collaterals[ilk].aL_ttl);
                assertTrue((aL_line >= RAD && aL_line < BILLION * RAD) || aL_line == 0);  // eq 0 or gt eq 1 RAD and lt 1B
            }
            uint256 normalizedTestDust = values.collaterals[ilk].dust * RAD;
            assertEq(dust, normalizedTestDust);
            assertTrue((dust >= RAD && dust < 10 * THOUSAND * RAD) || dust == 0); // eq 0 or gt eq 1 and lt 10k
            }
            {
            (, uint256 chop, uint256 dunk) = cat.ilks(ilk);
            // Convert BP to system expected value
            uint256 normalizedTestChop = (values.collaterals[ilk].chop * 10**14) + WAD;
            assertEq(chop, normalizedTestChop);
            // make sure chop is less than 100%
            assertTrue(chop >= WAD && chop < 2 * WAD);   // penalty gt eq 0% and lt 100%
            // Convert whole Dai units to expected RAD
            uint256 normalizedTestDunk = values.collaterals[ilk].dunk * RAD;
            assertEq(dunk, normalizedTestDunk);
            // put back in after LIQ-1.2
            assertTrue(dunk >= RAD && dunk < MILLION * RAD);
            }
            {
            (,uint256 mat) = spot.ilks(ilk);
            // Convert BP to system expected value
            uint256 normalizedTestMat = (values.collaterals[ilk].mat * 10**23);
            assertEq(mat, normalizedTestMat);
            assertTrue(mat >= RAY && mat < 10 * RAY);    // cr eq 100% and lt 1000%
            }
            {
            (address flipper,,) = cat.ilks(ilk);
            FlipAbstract flip = FlipAbstract(flipper);
            // Convert BP to system expected value
            uint256 normalizedTestBeg = (values.collaterals[ilk].beg + 10000)  * 10**14;
            assertEq(uint256(flip.beg()), normalizedTestBeg);
            assertTrue(flip.beg() >= WAD && flip.beg() < 105 * WAD / 100);  // gt eq 0% and lt 5%
            assertEq(uint256(flip.ttl()), values.collaterals[ilk].ttl);
            assertTrue(flip.ttl() >= 600 && flip.ttl() < 10 hours);         // gt eq 10 minutes and lt 10 hours
            assertEq(uint256(flip.tau()), values.collaterals[ilk].tau);
            assertTrue(flip.tau() >= 600 && flip.tau() <= 3 days);          // gt eq 10 minutes and lt eq 3 days

            assertEq(flip.wards(address(cat)), values.collaterals[ilk].liquidations);  // liquidations == 1 => on
            // assertEq(flip.wards(address(makerDeployer06)), 0); // Check deployer denied
            assertEq(flip.wards(address(pauseProxy)), 1); // Check pause_proxy ward
            }
            {
            GemJoinAbstract join = GemJoinAbstract(reg.join(ilk));
            // assertEq(join.wards(address(makerDeployer06)), 0); // Check deployer denied
            assertEq(join.wards(address(pauseProxy)), 1); // Check pause_proxy ward
            }
        }
        assertEq(sumlines, vat.Line());
    }

    function testSpellIsCast() public {
        string memory description = new DssSpell().description();
        assertTrue(bytes(description).length > 0);
        // DS-Test can't handle strings directly, so cast to a bytes32.
        assertEq(stringToBytes32(spell.description()),
                stringToBytes32(description));

        if(address(spell) != address(KOVAN_SPELL)) {
            assertEq(spell.expiration(), (now + 30 days));
        } else {
            assertEq(spell.expiration(), (SPELL_CREATED + 30 days));
        }

        vote();
        scheduleWaitAndCast();
        assertTrue(spell.done());

        checkSystemValues(afterSpell);

        checkCollateralValues(afterSpell);
    }

    // Test any Integrations

    // Aave integration
    function testSpellIsCast_AAVE_INTEGRATION() public {
        vote();
        scheduleWaitAndCast();
        assertTrue(spell.done());

        pipAAVE.poke();
        hevm.warp(now + 3601);
        pipAAVE.poke();
        spot.poke("AAVE-A");

        // Check faucet amount
        uint256 faucetAmount = faucet.amt(address(aave));
        uint256 faucetAmountWad = faucetAmount * (10 ** (18 - aave.decimals()));
        assertTrue(faucetAmount > 0);
        faucet.gulp(address(aave));
        assertEq(aave.balanceOf(address(this)), faucetAmount);

        // Check median matches pip.src()
        assertEq(pipAAVE.src(), address(medAAVEA));

        // Authorization
        assertEq(joinAAVEA.wards(pauseProxy), 1);
        assertEq(vat.wards(address(joinAAVEA)), 1);
        assertEq(flipAAVEA.wards(address(end)), 1);
        assertEq(flipAAVEA.wards(address(flipMom)), 1);
        assertEq(pipAAVE.wards(address(osmMom)), 1);
        assertEq(pipAAVE.bud(address(spot)), 1);
        assertEq(pipAAVE.bud(address(end)), 1);
        assertEq(MedianAbstract(pipAAVE.src()).bud(address(pipAAVE)), 1);

        // Join to adapter
        assertEq(vat.gem("AAVE-A", address(this)), 0);
        aave.approve(address(joinAAVEA), faucetAmount);
        joinAAVEA.join(address(this), faucetAmount);
        assertEq(aave.balanceOf(address(this)), 0);
        assertEq(vat.gem("AAVE-A", address(this)), faucetAmountWad);

        // Deposit collateral, generate DAI
        assertEq(vat.dai(address(this)), 0);
        vat.frob("AAVE-A", address(this), address(this), address(this), int(faucetAmountWad), int(100 * WAD));
        assertEq(vat.gem("AAVE-A", address(this)), 0);
        assertEq(vat.dai(address(this)), 100 * RAD);

        // Payback DAI, withdraw collateral
        vat.frob("AAVE-A", address(this), address(this), address(this), -int(faucetAmountWad), -int(100 * WAD));
        assertEq(vat.gem("AAVE-A", address(this)), faucetAmountWad);
        assertEq(vat.dai(address(this)), 0);

        // Withdraw from adapter
        joinAAVEA.exit(address(this), faucetAmount);
        assertEq(aave.balanceOf(address(this)), faucetAmount);
        assertEq(vat.gem("AAVE-A", address(this)), 0);

        // Generate new DAI to force a liquidation
        aave.approve(address(joinAAVEA), faucetAmount);
        joinAAVEA.join(address(this), faucetAmount);
        (,,uint256 spotV,,) = vat.ilks("AAVE-A");
        // dart max amount of DAI
        vat.frob("AAVE-A", address(this), address(this), address(this), int(faucetAmountWad), int(mul(faucetAmount, spotV) / RAY));
        hevm.warp(now + 1);
        jug.drip("AAVE-A");
        assertEq(flipAAVEA.kicks(), 0);
        cat.bite("AAVE-A", address(this));
        assertEq(flipAAVEA.kicks(), 1);
    }

    // Test any Integrations

    // TODO test Aave integration

    function testSpellIsCast_UNIV2DAIETH_INTEGRATION() public {
        vote();
        scheduleWaitAndCast();
        assertTrue(spell.done());

        bytes32 ilk = "UNIV2DAIETH-A";

        lpPip.poke();
        hevm.warp(now + 3601);
        lpPip.poke();
        spot.poke(ilk);

        // Check median matches pip.src()
        assertEq(lpPip.src(), address(lp));
        assertEq(lpPip.orb0(), address(0x91A8A02393cC21CeE04B482b0e4Aa26BfA1AA79c));
        assertEq(lpPip.orb1(), address(0x0E30F0FC91FDbc4594b1e2E5d64E6F1f94cAB23D));

        // Authorization
        assertEq(lpJoin.wards(pauseProxy), 1);
        assertEq(vat.wards(address(lpJoin)), 1);
        assertEq(lpFlip.wards(address(end)), 1);
        assertEq(lpFlip.wards(address(flipMom)), 1);
        assertEq(lpPip.wards(address(osmMom)), 1);
        assertEq(lpPip.bud(address(spot)), 1);
        assertEq(lpPip.bud(address(end)), 1);
        assertEq(MedianAbstract(lpPip.orb1()).bud(address(lpPip)), 1);

        // Join to adapter
        uint256 amount = 100 ether;
        hevm.store(
            address(lp),
            keccak256(abi.encode(address(this), uint256(1))),
            bytes32(amount)
        );
        assertEq(lp.balanceOf(address(this)), amount);
        assertEq(vat.gem(ilk, address(this)), 0);
        lp.approve(address(lpJoin), amount);
        lpJoin.join(address(this), amount);
        assertEq(lp.balanceOf(address(this)), 0);
        assertEq(vat.gem(ilk, address(this)), amount);

        // Deposit collateral, generate DAI
        assertEq(vat.dai(address(this)), 0);
        vat.frob(ilk, address(this), address(this), address(this), int(amount), int(100 * WAD));
        assertEq(vat.gem(ilk, address(this)), 0);
        assertEq(vat.dai(address(this)), 100 * RAD);

        // Payback DAI, withdraw collateral
        vat.frob(ilk, address(this), address(this), address(this), -int(amount), -int(100 * WAD));
        assertEq(vat.gem(ilk, address(this)), amount);
        assertEq(vat.dai(address(this)), 0);

        // Withdraw from adapter
        lpJoin.exit(address(this), amount);
        assertEq(lp.balanceOf(address(this)), amount);
        assertEq(vat.gem(ilk, address(this)), 0);

        // Generate new DAI to force a liquidation
        lp.approve(address(lpJoin), amount);
        lpJoin.join(address(this), amount);
        (,,uint256 spotV,,) = vat.ilks(ilk);
        // dart max amount of DAI
        vat.frob(ilk, address(this), address(this), address(this), int(amount), int(mul(amount, spotV) / RAY));
        hevm.warp(now + 1);
        jug.drip(ilk);
        assertEq(lpFlip.kicks(), 0);
        cat.bite(ilk, address(this));
        assertEq(lpFlip.kicks(), 1);
    }

    function testCastCost() public {
        vote();
        spell.schedule();

        uint256 castTime = now + pause.delay();

        hevm.warp(castTime);
        uint startGas = gasleft();
        spell.cast();
        uint endGas = gasleft();
        uint totalGas = startGas - endGas;

        assertTrue(spell.done());
        // Fail if cast is too expensive
        assertTrue(totalGas <= 8 * MILLION);
    }
}
