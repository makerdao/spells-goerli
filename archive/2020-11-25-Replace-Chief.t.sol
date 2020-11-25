pragma solidity 0.5.12;

import "ds-math/math.sol";
import "ds-test/test.sol";
import "lib/dss-interfaces/src/Interfaces.sol";
import "./test/rates.sol";

import {DssSpell, SpellAction} from "./Kovan-DssSpell.sol";

interface Hevm {
    function warp(uint) external;
    function store(address,bytes32,bytes32) external;
}

interface VoteProxyFactoryAbstract {
    function initiateLink(address) external;
    function approveLink(address) external returns (VoteProxyAbstract);
}

interface VoteProxyAbstract {
    function lock(uint256) external;
    function vote(address[] calldata) external;
}

contract Voter {
    function doApproveLink(VoteProxyFactoryAbstract voteProxyFactory, address cold) external returns (VoteProxyAbstract voteProxy) {
        voteProxy = voteProxyFactory.approveLink(cold);
    }

    function doVote(VoteProxyAbstract voteProxy, address[] calldata votes) external {
        voteProxy.vote(votes);
    }
}

contract DssSpellTest is DSTest, DSMath {
    // populate with kovan spell if needed
    address constant KOVAN_SPELL = address(0x05FaE2A9E80BB5088Bf77A64ecCCad8a521Bbd6e);
    // this needs to be updated
    uint256 constant SPELL_CREATED = 1606316808;

    struct CollateralValues {
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
        uint256 vat_Line;
        uint256 pause_delay;
        uint256 vow_wait;
        uint256 vow_dump;
        uint256 vow_sump;
        uint256 vow_bump;
        uint256 vow_hump;
        uint256 cat_box;
        uint256 ilk_count;
        address pause_authority;
        address osm_mom_authority;
        address flipper_mom_authority;
        mapping (bytes32 => CollateralValues) collaterals;
    }

    SystemValues afterSpell;

    Hevm hevm;
    Rates rates;

    // KOVAN ADDRESSES
    ChainlogAbstract changelog = ChainlogAbstract(   0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);
    DSPauseAbstract      pause = DSPauseAbstract(    0x8754E6ecb4fe68DaA5132c2886aB39297a5c7189);
    address         pauseProxy =                     0x0e4725db88Bb038bBa4C4723e91Ba183BE11eDf3;
    DSChiefAbstract   oldChief = DSChiefAbstract(    0xbBFFC76e94B34F72D96D054b31f6424249c1337d);
    DSChiefAbstract   newChief = DSChiefAbstract(    0x27E0c9567729Ea6e3241DE74B3dE499b7ddd3fe6);
    VatAbstract            vat = VatAbstract(        0xbA987bDB501d131f766fEe8180Da5d81b34b69d9);
    CatAbstract            cat = CatAbstract(        0xdDb5F7A3A5558b9a6a1f3382BD75E2268d1c6958);
    VowAbstract            vow = VowAbstract(        0x0F4Cbe6CBA918b7488C26E29d9ECd7368F38EA3b);
    PotAbstract            pot = PotAbstract(        0xEA190DBDC7adF265260ec4dA6e9675Fd4f5A78bb);
    JugAbstract            jug = JugAbstract(        0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD);
    SpotAbstract          spot = SpotAbstract(       0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D);

    DSTokenAbstract        gov = DSTokenAbstract(    0xAaF64BFCC32d0F15873a02163e7E500671a4ffcD);
    EndAbstract            end = EndAbstract(        0x24728AcF2E2C403F5d2db4Df6834B8998e56aA5F);
    IlkRegistryAbstract    reg = IlkRegistryAbstract(0xedE45A0522CA19e979e217064629778d6Cc2d9Ea);

    OsmMomAbstract      osmMom = OsmMomAbstract(     0x5dA9D1C3d4f1197E5c52Ff963916Fe84D2F5d8f3);
    FlipperMomAbstract flipMom = FlipperMomAbstract( 0x50dC6120c67E456AdA2059cfADFF0601499cf681);

    // Faucet
    FaucetAbstract      faucet = FaucetAbstract(     0x57aAeAE905376a4B1899bA81364b4cE2519CBfB3);

    // Specific for this spell
    DSAuthAbstract saiMom      = DSAuthAbstract(     0x72Ee9496b0867Dfe5E8B280254Da55e51E34D27b);
    DSAuthAbstract saiTop      = DSAuthAbstract(     0x5f00393547561DA3030ebF30e52F5DC0D5D3362c);

    VoteProxyFactoryAbstract
              voteProxyFactory
                               = VoteProxyFactoryAbstract(
                                                     0x1400798AA746457E467A1eb9b3F3f72C25314429);

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
        rates = new Rates();

        spell = KOVAN_SPELL != address(0) ? DssSpell(KOVAN_SPELL) : new DssSpell();

        //
        // Test for all system configuration changes
        //
        afterSpell = SystemValues({
            pot_dsr:               0,                   // In basis points
            vat_Line:              1232 * MILLION,      // In whole Dai units
            pause_delay:           60,                  // In seconds
            vow_wait:              3600,                // In seconds
            vow_dump:              2,                   // In whole Dai units
            vow_sump:              50,                  // In whole Dai units
            vow_bump:              10,                  // In whole Dai units
            vow_hump:              500,                 // In whole Dai units
            cat_box:               10 * THOUSAND,       // In whole Dai units
            ilk_count:             18,                  // Num expected in system
            pause_authority:       address(newChief),   // Pause authority
            osm_mom_authority:     address(newChief),   // OsmMom authority
            flipper_mom_authority: address(newChief)    // FlipperMom authority
        });

        //
        // Test for all collateral based changes here
        //
        afterSpell.collaterals["ETH-A"] = CollateralValues({
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
            line:         20 * MILLION,
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
    }

    function vote() private {
        if (oldChief.hat() != address(spell)) {
            hevm.store(
                address(gov),
                keccak256(abi.encode(address(this), uint256(1))),
                bytes32(uint256(999999999999 ether))
            );
            gov.approve(address(oldChief), uint256(-1));
            oldChief.lock(999999999999 ether);

            assertTrue(!spell.done());

            address[] memory yays = new address[](1);
            yays[0] = address(spell);

            oldChief.vote(yays);
            oldChief.lift(address(spell));
        }
        assertEq(oldChief.hat(), address(spell));
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
        uint normalizedLine = values.vat_Line * RAD;
        assertEq(vat.Line(), normalizedLine);
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

        // check number of ilks
        assertEq(reg.count(), values.ilk_count);

        // check Pause authority
        assertEq(pause.authority(), values.pause_authority);

        // check OsmMom authority
        assertEq(osmMom.authority(), values.osm_mom_authority);

        // check FlipperMom authority
        assertEq(flipMom.authority(), values.flipper_mom_authority);
    }

    function checkCollateralValues(bytes32 ilk, SystemValues storage values) internal {
        (uint duty,)  = jug.ilks(ilk);
        assertEq(duty, rates.rates(values.collaterals[ilk].pct));
        // make sure duty is less than 1000% APR
        // bc -l <<< 'scale=27; e( l(10.00)/(60 * 60 * 24 * 365) )'
        // 1000000073014496989316680335
        assertTrue(duty >= RAY && duty < 1000000073014496989316680335);  // gt 0 and lt 1000%
        assertTrue(diffCalc(expectedRate(values.collaterals[ilk].pct), yearlyYield(rates.rates(values.collaterals[ilk].pct))) <= TOLERANCE);
        assertTrue(values.collaterals[ilk].pct < THOUSAND * THOUSAND);   // check value lt 1000%
        {
        (,,, uint line, uint dust) = vat.ilks(ilk);
        // Convert whole Dai units to expected RAD
        uint normalizedTestLine = values.collaterals[ilk].line * RAD;
        assertEq(line, normalizedTestLine);
        assertTrue((line >= RAD && line < BILLION * RAD) || line == 0);  // eq 0 or gt eq 1 RAD and lt 1B
        uint normalizedTestDust = values.collaterals[ilk].dust * RAD;
        assertEq(dust, normalizedTestDust);
        assertTrue((dust >= RAD && dust < 10 * THOUSAND * RAD) || dust == 0); // eq 0 or gt eq 1 and lt 10k
        }
        {
        (, uint chop, uint dunk) = cat.ilks(ilk);
        uint normalizedTestChop = (values.collaterals[ilk].chop * 10**14) + WAD;
        assertEq(chop, normalizedTestChop);
        // make sure chop is less than 100%
        assertTrue(chop >= WAD && chop < 2 * WAD);   // penalty gt eq 0% and lt 100%
        // Convert whole Dai units to expected RAD
        uint normalizedTestDunk = values.collaterals[ilk].dunk * RAD;
        assertEq(dunk, normalizedTestDunk);
        // put back in after LIQ-1.2
        assertTrue(dunk >= RAD && dunk < MILLION * RAD);
        }
        {
        (,uint mat) = spot.ilks(ilk);
        // Convert BP to system expected value
        uint normalizedTestMat = (values.collaterals[ilk].mat * 10**23);
        assertEq(mat, normalizedTestMat);
        assertTrue(mat >= RAY && mat < 10 * RAY);    // cr eq 100% and lt 1000%
        }
        {
        (address flipper,,) = cat.ilks(ilk);
        FlipAbstract flip = FlipAbstract(flipper);
        // Convert BP to system expected value
        uint normalizedTestBeg = (values.collaterals[ilk].beg + 10000)  * 10**14;
        assertEq(uint(flip.beg()), normalizedTestBeg);
        assertTrue(flip.beg() >= WAD && flip.beg() < 105 * WAD / 100);  // gt eq 0% and lt 5%
        assertEq(uint(flip.ttl()), values.collaterals[ilk].ttl);
        assertTrue(flip.ttl() >= 600 && flip.ttl() < 10 hours);         // gt eq 10 minutes and lt 10 hours
        assertEq(uint(flip.tau()), values.collaterals[ilk].tau);
        assertTrue(flip.tau() >= 600 && flip.tau() <= 1 hours);          // gt eq 10 minutes and lt eq 1 hours

        assertEq(flip.wards(address(cat)), values.collaterals[ilk].liquidations);  // liquidations == 1 => on
        }
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

    function testRootExecuteSpell() public {
        vote();
        scheduleWaitAndCast();
        assertTrue(spell.done());

        DSTokenAbstract(oldChief.IOU()).approve(address(oldChief), uint256(-1));
        oldChief.free(999999999999 ether);
        gov.approve(address(newChief), uint256(-1));

        newChief.lock(80_000 ether);
        address[] memory slate = new address[](1);

        // Create spell for testing
        TestSpell testSpell = new TestSpell();

        // System not launched, lifted address doesn't get root access
        slate[0] = address(testSpell);
        newChief.vote(slate);
        newChief.lift(address(testSpell));
        assertTrue(!newChief.isUserRoot(address(testSpell)));

        // Launch system
        slate[0] = address(0);
        newChief.vote(slate);
        newChief.lift(address(0));
        assertEq(newChief.live(), 0);
        assertTrue(!newChief.isUserRoot(address(0)));
        newChief.launch();
        assertEq(newChief.live(), 1);
        assertTrue(newChief.isUserRoot(address(0)));

        // System launched, lifted address gets root access
        slate[0] = address(testSpell);
        newChief.vote(slate);
        newChief.lift(address(testSpell));
        assertTrue(newChief.isUserRoot(address(testSpell)));
        testSpell.schedule();
    }

    function testRootExecuteSpellViaVoteProxy() public {
        vote();
        scheduleWaitAndCast();
        assertTrue(spell.done());

        DSTokenAbstract(oldChief.IOU()).approve(address(oldChief), uint256(-1));
        oldChief.free(999999999999 ether);

        Voter voter = new Voter();
        voteProxyFactory.initiateLink(address(voter));
        VoteProxyAbstract voteProxy = voter.doApproveLink(voteProxyFactory, address(this));

        gov.approve(address(voteProxy), uint256(-1));

        voteProxy.lock(80_000 ether);
        address[] memory slate = new address[](1);

        // Create spell for testing
        TestSpell testSpell = new TestSpell();

        // System not launched, lifted address doesn't get root access
        slate[0] = address(testSpell);
        voteProxy.vote(slate);
        newChief.lift(address(testSpell));
        assertTrue(!newChief.isUserRoot(address(testSpell)));

        // Launch system
        slate[0] = address(0);
        voteProxy.vote(slate);
        newChief.lift(address(0));
        assertEq(newChief.live(), 0);
        assertTrue(!newChief.isUserRoot(address(0)));
        newChief.launch();
        assertEq(newChief.live(), 1);
        assertTrue(newChief.isUserRoot(address(0)));

        // System launched, lifted address gets root access
        slate[0] = address(testSpell);
        voteProxy.vote(slate);
        newChief.lift(address(testSpell));
        assertTrue(newChief.isUserRoot(address(testSpell)));
        testSpell.schedule();
    }

    function testFailExecuteSpellNotLaunched() public {
        vote();
        scheduleWaitAndCast();
        assertTrue(spell.done());

        DSTokenAbstract(oldChief.IOU()).approve(address(oldChief), uint256(-1));
        oldChief.free(999999999999 ether);
        gov.approve(address(newChief), uint256(-1));

        newChief.lock(80_000 ether);
        address[] memory slate = new address[](1);

        // Create spell for testing
        TestSpell testSpell = new TestSpell();

        // System not launched, lifted address doesn't get root access
        slate[0] = address(testSpell);
        newChief.vote(slate);
        newChief.lift(address(testSpell));
        testSpell.schedule();
    }

    function _runOldChief() internal {
        TestSpell testSpell = new TestSpell();

        address[] memory slate = new address[](1);
        slate[0] = address(testSpell);
        oldChief.vote(slate);
        oldChief.lift(address(testSpell));
        testSpell.schedule();
    }

    function testExecuteSpellOldChief() public {
        vote();
        _runOldChief();
    }

    function testFailExecuteSpellOldChief() public {
        vote();
        scheduleWaitAndCast();
        assertTrue(spell.done());

        _runOldChief();
    }

    function testMoms() public {
        vote();
        scheduleWaitAndCast();
        assertTrue(spell.done());

        DSTokenAbstract(oldChief.IOU()).approve(address(oldChief), uint256(-1));
        oldChief.free(999999999999 ether);
        gov.approve(address(newChief), uint256(-1));

        newChief.lock(80_000 ether);
        address[] memory slate = new address[](1);

        // Create spell for testing
        TestMomsSpell testMomsSpell = new TestMomsSpell();

        // System not launched, lifted address doesn't get root access
        slate[0] = address(testMomsSpell);
        newChief.vote(slate);
        newChief.lift(address(testMomsSpell));
        assertTrue(!newChief.isUserRoot(address(testMomsSpell)));

        // Launch system
        slate[0] = address(0);
        newChief.vote(slate);
        newChief.lift(address(0));
        newChief.launch();

        // System launched, lifted address gets root access
        slate[0] = address(testMomsSpell);
        newChief.vote(slate);
        newChief.lift(address(testMomsSpell));
        assertTrue(newChief.isUserRoot(address(testMomsSpell)));

        FlipAbstract flip = FlipAbstract(changelog.getAddress("MCD_FLIP_ETH_A"));
        OsmAbstract osm   = OsmAbstract(changelog.getAddress("PIP_ETH"));

        assertEq(flip.wards(address(cat)), 1);
        assertEq(osm.stopped(), 0);
        testMomsSpell.cast();
        assertEq(flip.wards(address(cat)), 0);
        assertEq(osm.stopped(), 1);
    }

    function testSAIcontractsAuthorityChange() public {
        assertEq(saiMom.authority(), address(oldChief));
        assertEq(saiTop.authority(), address(oldChief));
        vote();
        spell.schedule();
        assertEq(saiMom.authority(), address(0));
        assertEq(saiTop.authority(), address(0));
    }
}

contract SpellActionTest {
    function execute() external {
        // Random action to test authority
        VatAbstract(ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F).getAddress("MCD_VAT")).rely(address(123));
    }
}

contract TestSpell {
    DSPauseAbstract public pause =
        DSPauseAbstract(ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F).getAddress("MCD_PAUSE"));
    address         public action;
    bytes32         public tag;
    uint256         public eta;
    bytes           public sig;

    constructor() public {
        sig = abi.encodeWithSignature("execute()");
        action = address(new SpellActionTest());
        bytes32 _tag;
        address _action = action;
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
    }

    function schedule() public {
        eta = now + DSPauseAbstract(pause).delay();
        pause.plot(action, tag, sig, eta);
    }
}

contract TestMomsSpell {
    ChainlogAbstract changelog = ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);

    FlipperMomAbstract public fMom =
        FlipperMomAbstract(changelog.getAddress("FLIPPER_MOM"));

    OsmMomAbstract public oMom =
        OsmMomAbstract(changelog.getAddress("OSM_MOM"));

    function cast() public {
        fMom.deny(changelog.getAddress("MCD_FLIP_ETH_A"));
        oMom.stop("ETH-A");
    }
}
