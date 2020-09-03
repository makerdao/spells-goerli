pragma solidity 0.5.12;

import "ds-math/math.sol";
import "ds-test/test.sol";
import "lib/dss-interfaces/src/Interfaces.sol";

import {DssSpell, SpellAction} from "./Kovan-DssSpell.sol";

interface Hevm {
    function warp(uint) external;
    function store(address,bytes32,bytes32) external;
}

interface USDTAbstract {
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);
    function approve(address, uint256) external;               // nonstandard
    function transfer(address, uint256) external;              // nonstandard
    function transferFrom(address, address, uint256) external; // nonstandard
}

contract DssSpellTest is DSTest, DSMath {
    // populate with kovan spell if needed
    address constant KOVAN_SPELL = address(0xE64bcAeAe0dfa8CdD8D2aDf48e8AdFd7a343512A);
    // this needs to be updated
    uint256 constant SPELL_CREATED = 1599139568;

    struct CollateralValues {
        uint256 line;
        uint256 dust;
        uint256 duty;
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
        uint256 pot_dsrPct;
        uint256 vat_Line;
        uint256 pause_delay;
        uint256 vow_wait;
        uint256 vow_dump;
        uint256 vow_sump;
        uint256 vow_bump;
        uint256 vow_hump;
        uint256 cat_box;
        mapping (bytes32 => CollateralValues) collaterals;
    }

    SystemValues afterSpell;

    Hevm hevm;

    // KOVAN ADDRESSES
    DSPauseAbstract      pause = DSPauseAbstract(    0x8754E6ecb4fe68DaA5132c2886aB39297a5c7189);
    address         pauseProxy =                     0x0e4725db88Bb038bBa4C4723e91Ba183BE11eDf3;
    DSChiefAbstract      chief = DSChiefAbstract(    0xbBFFC76e94B34F72D96D054b31f6424249c1337d);
    VatAbstract            vat = VatAbstract(        0xbA987bDB501d131f766fEe8180Da5d81b34b69d9);
    CatAbstract            cat = CatAbstract(        0xdDb5F7A3A5558b9a6a1f3382BD75E2268d1c6958);
    VowAbstract            vow = VowAbstract(        0x0F4Cbe6CBA918b7488C26E29d9ECd7368F38EA3b);
    PotAbstract            pot = PotAbstract(        0xEA190DBDC7adF265260ec4dA6e9675Fd4f5A78bb);
    JugAbstract            jug = JugAbstract(        0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD);
    SpotAbstract          spot = SpotAbstract(       0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D);
    FlipperMomAbstract  newMom = FlipperMomAbstract( 0x50dC6120c67E456AdA2059cfADFF0601499cf681);

    DSTokenAbstract        gov = DSTokenAbstract(    0xAaF64BFCC32d0F15873a02163e7E500671a4ffcD);
    EndAbstract            end = EndAbstract(        0x24728AcF2E2C403F5d2db4Df6834B8998e56aA5F);
    DSTokenAbstract       weth = DSTokenAbstract(    0xd0A1E359811322d97991E03f863a0C30C2cF029C);
    GemJoinAbstract   wethJoin = GemJoinAbstract(    0x775787933e92b709f2a3C70aa87999696e74A9F8);
    IlkRegistryAbstract    reg = IlkRegistryAbstract(0x6618BD7bBaBFacC518Fdec43542E4a73629B0819);

    OsmMomAbstract      osmMom = OsmMomAbstract(     0x5dA9D1C3d4f1197E5c52Ff963916Fe84D2F5d8f3);
    FlipperMomAbstract flipMom = FlipperMomAbstract( 0x50dC6120c67E456AdA2059cfADFF0601499cf681);


    // USDT-A specific
    USDTAbstract usdt            = USDTAbstract(     0x9245BD36FA20fcD292F4765c4b5dF83Dc3fD5e86);
    GemJoinAbstract joinUSDTA    = GemJoinAbstract(  0x9B011a74a690dFd9a1e4996168d3EcBDE73c2226);
    OsmAbstract pipUSDT          = OsmAbstract(      0x3588A7973D41AaeA7B203549553C991C4311951e);
    FlipAbstract flipUSDTA       = FlipAbstract(     0x113733e00804e61D5fd8b107Ca11b4569B6DA95D);
    MedianAbstract medUSDTA      = MedianAbstract(   0x074EcAe0CD5c37f59D9b91E2994407418aCe05B7);

    // PAXUSD-A specific
    GemAbstract      paxusd      = GemAbstract(      0xa6383AF46c36219a472b9549d70E4768dfA8894c);
    GemJoinAbstract  joinPAXUSDA = GemJoinAbstract(  0x3d6a14C9542B429a4e3d255F6687754d4898D897);
    OsmAbstract      pipPAXUSD   = OsmAbstract(      0xD01fefed46eb21cd057bAa14Ff466842C31a0Cd9);
    FlipAbstract     flipPAXUSDA = FlipAbstract(     0x88001b9C8192cbf43e14323B809Ae6C4e815E12E);

    DssSpell spell;

    // CHEAT_CODE = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
    bytes20 constant CHEAT_CODE =
        bytes20(uint160(uint256(keccak256('hevm cheat code'))));

    uint256 constant HUNDRED    = 10 ** 2;
    uint256 constant THOUSAND   = 10 ** 3;
    uint256 constant MILLION    = 10 ** 6;
    uint256 constant BILLION    = 10 ** 9;
    uint256 constant WAD        = 10 ** 18;
    uint256 constant RAY        = 10 ** 27;
    uint256 constant RAD        = 10 ** 45;

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
        return (100000 + percentValue) * (10 ** 22);
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
            pot_dsr: 1000000000000000000000000000,
            pot_dsrPct: 0 * 1000,
            vat_Line: 703 * MILLION * RAD,
            pause_delay: 60,
            vow_wait: 3600,
            vow_dump: 2 * WAD,
            vow_sump: 50 * RAD,
            vow_bump: 10 * RAD,
            vow_hump: 500 * RAD,
            cat_box: 10 * THOUSAND * RAD
        });

        //
        // Test for all collateral based changes here
        //
        afterSpell.collaterals["ETH-A"] = CollateralValues({
            line:         420 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000002440418608258400030,
            pct:          8 * 1000,
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
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
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
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
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
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
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
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
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
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
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
            mat:          120 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 0
        });
        afterSpell.collaterals["KNC-A"] = CollateralValues({
            line:         5 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000000000000000000000000,
            pct:          0,
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
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
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
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
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
            mat:          175 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["USDT-A"] = CollateralValues({
            line:         10 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000002440418608258400030, // 8% SF
            pct:          8 * 1000,
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
            mat:          150 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          6 hours,
            tau:          6 hours,
            liquidations: 1
        });
        afterSpell.collaterals["PAXUSD-A"] = CollateralValues({
            line:         5 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000001243680656318820312, // 4% SF
            pct:          4 * 1000,
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
            mat:          120 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          6 hours,
            tau:          6 hours,
            liquidations: 0
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
        assertEq(pot.dsr(), values.pot_dsr);
        // make sure dsr is less than 100% APR
        // bc -l <<< 'scale=27; e( l(2.00)/(60 * 60 * 24 * 365) )'
        // 1000000021979553151239153027
        assertTrue(
            pot.dsr() >= RAY && pot.dsr() < 1000000021979553151239153027
        );
        assertTrue(diffCalc(expectedRate(values.pot_dsrPct), yearlyYield(values.pot_dsr)) <= TOLERANCE);

        // Line
        assertEq(vat.Line(), values.vat_Line);
        assertTrue(
            (vat.Line() >= RAD && vat.Line() < BILLION * RAD) ||
            vat.Line() == 0
        );

        // Pause delay
        assertEq(pause.delay(), values.pause_delay);

        // wait
        assertEq(vow.wait(), values.vow_wait);

        // dump
        assertEq(vow.dump(), values.vow_dump);
        assertTrue(
            (vow.dump() >= WAD && vow.dump() < 2 * THOUSAND * WAD) ||
            vow.dump() == 0
        );

        // sump
        assertEq(vow.sump(), values.vow_sump);
        assertTrue(
            (vow.sump() >= RAD && vow.sump() < 500 * THOUSAND * RAD) ||
            vow.sump() == 0
        );

        // bump
        assertEq(vow.bump(), values.vow_bump);
        assertTrue(
            (vow.bump() >= RAD && vow.bump() < HUNDRED * THOUSAND * RAD) ||
            vow.bump() == 0
        );

        // hump
        assertEq(vow.hump(), values.vow_hump);
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

        (, uint chop, uint dunk) = cat.ilks(ilk);
        assertEq(chop, values.collaterals[ilk].chop);
        // make sure chop is less than 100%
        assertTrue(chop >= WAD && chop < 2 * WAD);   // penalty gt eq 0% and lt 100%
        assertEq(dunk, values.collaterals[ilk].dunk);
        // put back in after LIQ-1.2
        assertTrue(dunk >= RAD && dunk < MILLION * RAD);

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

        bytes32[] memory ilks = reg.list();
        for(uint i = 0; i < ilks.length; i++) {
            checkCollateralValues(ilks[i],  afterSpell);
        }
    }

    function testSpellIsCast_USDTA_INTEGRATION() public {
        vote();
        scheduleWaitAndCast();
        // spell done
        assertTrue(spell.done());

        pipUSDT.poke();
        hevm.warp(now + 3601);
        pipUSDT.poke();
        spot.poke("USDT-A");

        hevm.store(
            address(usdt),
            keccak256(abi.encode(address(this), uint256(2))),
            bytes32(uint256(600 * 10 ** 6))
        );

        // check median matches pip.src()
        assertEq(pipUSDT.src(), address(medUSDTA));

        // Authorization
        assertEq(joinUSDTA.wards(pauseProxy), 1);
        assertEq(vat.wards(address(joinUSDTA)), 1);
        assertEq(flipUSDTA.wards(address(end)), 1);
        assertEq(flipUSDTA.wards(address(flipMom)), 1);
        assertEq(pipUSDT.wards(address(osmMom)), 1);
        assertEq(pipUSDT.bud(address(spot)), 1);
        assertEq(pipUSDT.bud(address(end)), 1);
        assertEq(MedianAbstract(pipUSDT.src()).bud(address(pipUSDT)), 1);

        // Join to adapter
        assertEq(usdt.balanceOf(address(this)), 600 * 10 ** 6);
        assertEq(vat.gem("USDT-A", address(this)), 0);
        usdt.approve(address(joinUSDTA), 600 * 10 ** 6);
        joinUSDTA.join(address(this), 600 * 10 ** 6);
        assertEq(usdt.balanceOf(address(this)), 0);
        assertEq(vat.gem("USDT-A", address(this)), 600 * WAD);

        // Deposit collateral, generate DAI
        assertEq(vat.dai(address(this)), 0);
        vat.frob("USDT-A", address(this), address(this), address(this), int(600 * WAD), int(100 * WAD));
        assertEq(vat.gem("USDT-A", address(this)), 0);
        assertEq(vat.dai(address(this)), 100 * RAD);

        // Payback DAI, withdraw collateral
        vat.frob("USDT-A", address(this), address(this), address(this), -int(600 * WAD), -int(100 * WAD));
        assertEq(vat.gem("USDT-A", address(this)), 600 * WAD);
        assertEq(vat.dai(address(this)), 0);

        // Withdraw from adapter
        joinUSDTA.exit(address(this), 600 * 10 ** 6);
        assertEq(usdt.balanceOf(address(this)), 600 * 10 ** 6);
        assertEq(vat.gem("USDT-A", address(this)), 0);

        // Generate new DAI to force a liquidation
        usdt.approve(address(joinUSDTA), 600 * 10 ** 6);
        joinUSDTA.join(address(this), 600 * 10 ** 6);
        (,,uint256 spotV,,) = vat.ilks("USDT-A");
        // dart max amount of DAI
        vat.frob("USDT-A", address(this), address(this), address(this), int(600 * WAD), int(mul(600 * WAD, spotV) / RAY));
        hevm.warp(now + 1);
        jug.drip("USDT-A");
        assertEq(flipUSDTA.kicks(), 0);
        cat.bite("USDT-A", address(this));
        assertEq(flipUSDTA.kicks(), 1);
    }

    function testSpellIsCast_PAXUSDA_INTEGRATION() public {
        vote();
        scheduleWaitAndCast();
        // spell done
        assertTrue(spell.done());

        // Authorization

        assertEq(joinPAXUSDA.wards(pauseProxy), 1);
        assertEq(vat.wards(address(joinPAXUSDA)), 1);
        assertEq(flipPAXUSDA.wards(address(end)), 1);
        assertEq(flipPAXUSDA.wards(address(flipMom)), 1);

        // Join to adapter
        hevm.store(
            address(paxusd),
            keccak256(abi.encode(address(this), uint256(1))),
            bytes32(uint256(600 * WAD))
        );
        assertEq(paxusd.balanceOf(address(this)), 600 * WAD);
        assertEq(vat.gem("PAXUSD-A", address(this)), 0);
        paxusd.approve(address(joinPAXUSDA), 600 * WAD);
        joinPAXUSDA.join(address(this), 600 * WAD);
        assertEq(paxusd.balanceOf(address(this)), 0);
        assertEq(vat.gem("PAXUSD-A", address(this)), 600 * WAD);

        // Deposit collateral, generate DAI
        assertEq(vat.dai(address(this)), 0);
        vat.frob("PAXUSD-A", address(this), address(this), address(this), int(600 * WAD), int(100 * WAD));
        assertEq(vat.gem("PAXUSD-A", address(this)), 0);
        assertEq(vat.dai(address(this)), 100 * RAD);

        // Payback DAI, withdraw collateral
        vat.frob("PAXUSD-A", address(this), address(this), address(this), -int(600 * WAD), -int(100 * WAD));
        assertEq(vat.gem("PAXUSD-A", address(this)), 600 * WAD);
        assertEq(vat.dai(address(this)), 0);

        // Withdraw from adapter
        joinPAXUSDA.exit(address(this), 600 * 10 ** 18);
        assertEq(paxusd.balanceOf(address(this)), 600 * 10 ** 18);
        assertEq(vat.gem("PAXUSD-A", address(this)), 0);
    }
}
