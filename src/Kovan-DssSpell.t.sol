pragma solidity 0.5.12;

import "ds-math/math.sol";
import "ds-test/test.sol";
import "lib/dss-interfaces/src/Interfaces.sol";

import {DssSpell, SpellAction} from "./Kovan-DssSpell.sol";

contract Hevm {
    function warp(uint) public;
    function store(address,bytes32,bytes32) public;
}

contract DssSpellTest is DSTest, DSMath {
    // populate with mainnet spell if needed
    address constant KOVAN_SPELL = address(0);
    uint    constant SPELL_CREATED = 0;

    struct CollateralValues {
        uint line;
        uint dust;
        uint duty;
        uint chop;
        uint lump;
        uint pct;
        uint mat;
        uint beg;
        uint48 ttl;
        uint48 tau;
        uint liquidations;
    }

    struct SystemValues {
        uint dsr;
        uint dsrPct;
        uint Line;
        uint pauseDelay;
        uint hump;
        mapping (bytes32 => CollateralValues) collaterals;
    }

    SystemValues beforeSpell;
    SystemValues afterSpell;

    Hevm hevm;

    // MAINNET ADDRESSES
    DSPauseAbstract      pause = DSPauseAbstract(    0x8754E6ecb4fe68DaA5132c2886aB39297a5c7189);
    address         pauseProxy =                     0x0e4725db88Bb038bBa4C4723e91Ba183BE11eDf3;
    DSChiefAbstract      chief = DSChiefAbstract(    0xbBFFC76e94B34F72D96D054b31f6424249c1337d);
    VatAbstract            vat = VatAbstract(        0xbA987bDB501d131f766fEe8180Da5d81b34b69d9);
    VowAbstract            vow = VowAbstract(        0x0F4Cbe6CBA918b7488C26E29d9ECd7368F38EA3b);
    CatAbstract            cat = CatAbstract(        0x0511674A67192FE51e86fE55Ed660eB4f995BDd6);
    PotAbstract            pot = PotAbstract(        0xEA190DBDC7adF265260ec4dA6e9675Fd4f5A78bb);
    JugAbstract            jug = JugAbstract(        0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD);
    SpotAbstract          spot = SpotAbstract(       0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D);

    DSTokenAbstract        gov = DSTokenAbstract(    0xAaF64BFCC32d0F15873a02163e7E500671a4ffcD);
    EndAbstract            end = EndAbstract(        0x24728AcF2E2C403F5d2db4Df6834B8998e56aA5F);
    DSTokenAbstract       weth = DSTokenAbstract(    0xd0A1E359811322d97991E03f863a0C30C2cF029C);
    GemJoinAbstract   wethJoin = GemJoinAbstract(    0x775787933e92b709f2a3C70aa87999696e74A9F8);
    IlkRegistryAbstract    reg = IlkRegistryAbstract(0x6618BD7bBaBFacC518Fdec43542E4a73629B0819);


    DssSpell spell;

    // CHEAT_CODE = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
    bytes20 constant CHEAT_CODE =
        bytes20(uint160(uint(keccak256('hevm cheat code'))));

    uint constant HUNDRED  = 10 ** 2;
    uint constant THOUSAND = 10 ** 3;
    uint constant MILLION  = 10 ** 6;
    uint constant BILLION  = 10 ** 9;
    uint constant WAD      = 10 ** 18;
    uint constant RAY      = 10 ** 27;
    uint constant RAD      = 10 ** 45;

    // Not provided in DSMath
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
    uint TOLERANCE = 10 ** 22;

    function yearlyYield(uint duty) public pure returns (uint) {
        return rpow(duty, (365 * 24 * 60 *60), RAY);
    }

    function expectedRate(uint percentValue) public pure returns (uint) {
        return (100000 + percentValue) * (10 ** 22);
    }

    function diffCalc(uint expectedRate_, uint yearlyYield_) public pure returns (uint) {
        return (expectedRate_ > yearlyYield_) ? expectedRate_ - yearlyYield_ : yearlyYield_ - expectedRate_;
    }

    function setUp() public {
        hevm = Hevm(address(CHEAT_CODE));

        spell = KOVAN_SPELL != address(0) ? DssSpell(KOVAN_SPELL) : new DssSpell();

        beforeSpell = SystemValues({
            dsr: 1000000000000000000000000000,
            dsrPct: 0 * 1000,
            Line: 608 * MILLION * RAD,
            pauseDelay: 60,
            hump: 500 * RAD
        });

        bytes32[] memory ilks = reg.list();

        //
        // set before spell config
        //
        for(uint i = 0; i < ilks.length; i++) {
            (,,, uint line, uint dust) = vat.ilks(ilks[i]);
            (address flip_address, uint chop, uint lump) = cat.ilks(ilks[i]);
            (, uint mat) = spot.ilks(ilks[i]);
            (uint duty,) = jug.ilks(ilks[i]);
            FlipAbstract flip = FlipAbstract(flip_address);

            beforeSpell.collaterals[ilks[i]] = CollateralValues({
                line: line,
                dust: dust,
                duty: duty,
                pct: 0 * 1000,
                chop: chop,
                lump: lump,
                mat: mat,
                beg: flip.beg(),
                ttl: flip.ttl(),
                tau: flip.tau(),
                liquidations: flip.wards(address(cat))
            });

            if (ilks[i] == "USDC-B") {
                beforeSpell.collaterals[ilks[i]].pct = 46 * 1000;
            }

            if (ilks[i] == "MANA-A") {
                beforeSpell.collaterals[ilks[i]].pct =  8 * 1000;
            }
        }

        //
        // Test for all system configuration changes
        //
        afterSpell = SystemValues({
            dsr: 1000000000000000000000000000,
            dsrPct: 0 * 1000,
            Line: 608 * MILLION * RAD,
            pauseDelay: 60,
            hump: 2 * MILLION * RAD
        });

        //
        // Test for all collateral based changes here
        //
        afterSpell.collaterals["ETH-A"] = CollateralValues({
            line:         340 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000000000000000000000000,
            pct:          0 * 1000,
            chop:         113 * RAY / 100,
            lump:         1 * WAD,
            mat:          150 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["BAT-A"] = CollateralValues({
            line:         5 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000000000000000000000000,
            pct:          0 * 1000,
            chop:         113 * RAY / 100,
            lump:         1500 * WAD,
            mat:          150 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["USDC-A"] = CollateralValues({
            line:         140 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000000000000000000000000,
            pct:          0,
            chop:         113 * RAY / 100,
            lump:         500 * WAD,
            mat:          110 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 0
        });
        afterSpell.collaterals["USDC-B"] = CollateralValues({
            line:         30 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000011562757347033522598,
            pct:          44 * 1000,
            chop:         113 * RAY / 100,
            lump:         500 * WAD,
            mat:          120 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 0
        });
        afterSpell.collaterals["WBTC-A"] = CollateralValues({
            line:         80 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000000000000000000000000,
            pct:          0,
            chop:         113 * RAY / 100,
            lump:         1 * WAD / 100,
            mat:          150 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["TUSD-A"] = CollateralValues({
            line:         2 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000000000000000000000000,
            pct:          0 * 1000,
            chop:         113 * RAY / 100,
            lump:         500 * WAD,
            mat:          120 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1 // This is an Error, liquidations should be off
        });
        afterSpell.collaterals["KNC-A"] = CollateralValues({
            line:         5 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000000000000000000000000,
            pct:          0,
            chop:         113 * RAY / 100,
            lump:         50  * WAD,
            mat:          175 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["ZRX-A"] = CollateralValues({
            line:         5 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000000000000000000000000,
            pct:          0,
            chop:         113 * RAY / 100,
            lump:         100 * WAD,
            mat:          175 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["MANA-A"] = CollateralValues({
            line:         1 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000001847694957439350562,
            pct:          6 * 1000,
            chop:         113 * RAY / 100,
            lump:         500 * WAD,
            mat:          175 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
    }

    function vote() private {
        if (chief.hat() != address(spell)) {
            hevm.store(
                address(gov),
                keccak256(abi.encode(address(this), uint(1))),
                bytes32(uint(999999999999 ether))
            );
            gov.approve(address(chief), uint(-1));
            chief.lock(sub(gov.balanceOf(address(this)), 1 ether));

            assertTrue(!spell.done());

            address[] memory yays = new address[](1);
            yays[0] = address(spell);

            chief.vote(yays);
            chief.lift(address(spell));
        }
        assertEq(chief.hat(), address(spell));
    }

    function scheduleWaitAndCast() public {
        spell.schedule();
        hevm.warp(now + pause.delay());
        spell.cast();
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }

    function checkSystemValues(SystemValues storage values) internal {
        // dsr
        assertEq(pot.dsr(), values.dsr);
        // make sure dsr is less than 100% APR
        // bc -l <<< 'scale=27; e( l(2.00)/(60 * 60 * 24 * 365) )'
        // 1000000021979553151239153027
        assertTrue(
            pot.dsr() >= RAY && pot.dsr() < 1000000021979553151239153027
        );
        assertTrue(diffCalc(expectedRate(values.dsrPct), yearlyYield(values.dsr)) <= TOLERANCE);

        // Line
        assertEq(vat.Line(), values.Line);
        assertTrue(
            (vat.Line() >= RAD && vat.Line() < BILLION * RAD) ||
            vat.Line() == 0
        );

        // Pause delay
        assertEq(pause.delay(), values.pauseDelay);

        // hump
        assertEq(vow.hump(), values.hump);
        
        assertTrue(
            (vow.hump() >= RAD && vow.hump() < HUNDRED * MILLION * RAD) ||
            vow.hump() == 0
        );
    }

    function checkCollateralValues(bytes32 ilk, SystemValues storage values) internal {
        (uint duty,)  = jug.ilks(ilk);
        assertEq(duty,   values.collaterals[ilk].duty);
        // make sure duty is less than 1000% APR
        // bc -l <<< 'scale=27; e( l(10.00)/(60 * 60 * 24 * 365) )'
        // 1000000073014496989316680335
        assertTrue(duty >= RAY && duty < 1000000073014496989316680335);  // gt 0 and lt 1000%
        assertTrue(diffCalc(expectedRate(values.collaterals[ilk].pct), yearlyYield(values.collaterals[ilk].duty)) <= TOLERANCE);
        assertTrue(values.collaterals[ilk].pct < THOUSAND * THOUSAND);   // check value lt 1000%

        (,,, uint line, uint dust) = vat.ilks(ilk);
        assertEq(line, values.collaterals[ilk].line);
        assertTrue((line >= RAD && line < BILLION * RAD) || line == 0);  // eq 0 or gt eq 1 RAD and lt 1B
        assertEq(dust, values.collaterals[ilk].dust);
        assertTrue((dust >= RAD && dust < 10 * THOUSAND * RAD) || dust == 0); // eq 0 or gt eq 1 and lt 10k

        (, uint chop, uint lump) = cat.ilks(ilk);
        assertEq(chop, values.collaterals[ilk].chop);
        // make sure chop is less than 100%
        assertTrue(chop >= RAY && chop < 2 * RAY);   // penalty gt eq 0% and lt 100%
        assertEq(lump, values.collaterals[ilk].lump);
        // put back in after LIQ-1.2
        // assertTrue(lump >= WAD && lump < MILLION * WAD);

        (,uint mat) = spot.ilks(ilk);
        assertEq(mat, values.collaterals[ilk].mat);
        assertTrue(mat >= RAY && mat < 10 * RAY);    // cr eq 100% and lt 1000%

        (address flipper,,) = cat.ilks(ilk);
        FlipAbstract flip = FlipAbstract(flipper);
        assertEq(uint(flip.beg()), values.collaterals[ilk].beg);
        assertTrue(flip.beg() >= WAD && flip.beg() < 105 * WAD / 100);  // gt eq 0% and lt 5%
        assertEq(uint(flip.ttl()), values.collaterals[ilk].ttl);
        assertTrue(flip.ttl() >= 600 && flip.ttl() < 10 hours);         // gt eq 10 minutes and lt 10 hours
        assertEq(uint(flip.tau()), values.collaterals[ilk].tau);
        assertTrue(flip.tau() >= 600 && flip.tau() <= 1 hours);          // gt eq 10 minutes and lt eq 1 hours

        assertEq(flip.wards(address(cat)), values.collaterals[ilk].liquidations);  // liquidations == 1 => on
    }

    function testSpellIsCast() public {
        string memory description = new SpellAction().description();
        assertTrue(bytes(description).length > 0);
        // DS-Test can't handle strings directly, so cast to a bytes32.
        assertEq(stringToBytes32(spell.description()),
                stringToBytes32(description));

        if(address(spell) != address(KOVAN_SPELL)) {
            assertEq(spell.expiration(), (now + 30 days));
        } else {
            assertEq(spell.expiration(), (SPELL_CREATED + 30 days));
        }

        checkSystemValues(beforeSpell);

        bytes32[] memory ilks = reg.list();

        for(uint i = 0; i < ilks.length; i++) {
            checkCollateralValues(ilks[i],  beforeSpell);
        }

        vote();
        scheduleWaitAndCast();
        assertTrue(spell.done());

        checkSystemValues(afterSpell);

        for(uint i = 0; i < ilks.length; i++) {
            checkCollateralValues(ilks[i],  afterSpell);
        }
    }
}
