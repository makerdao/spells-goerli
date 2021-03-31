pragma solidity 0.5.12;

// hax: needed for the deploy scripts
import "dss-gem-joins/join-auth.sol";
import "ds-value/value.sol";

import "ds-math/math.sol";
import "ds-test/test.sol";
import "dss-interfaces/Interfaces.sol";
import "./rates.sol";
import "./addresses_kovan.sol";

import {RwaSpell, SpellAction} from "../spell.sol";

interface Hevm {
    function warp(uint256) external;
    function store(address,bytes32,bytes32) external;
}

interface RwaInputConduitLike {
    function push() external;
}

interface RwaOutputConduitLike {
    function wards(address) external returns (uint);
    function can(address) external returns (uint);
    function rely(address) external;
    function deny(address) external;
    function hope(address) external;
    function nope(address) external;
    function bud(address) external returns (uint);
    function kiss(address) external;
    function diss(address) external;
    function pick(address) external;
    function push() external;
}

interface RwaUrnLike {
    function can(address) external returns (uint);
    function rely(address) external;
    function deny(address) external;
    function hope(address) external;
    function nope(address) external;
    function file(bytes32, address) external;
    function lock(uint256) external;
    function free(uint256) external;
    function draw(uint256) external;
    function wipe(uint256) external;
}

interface RwaLiquidationLike {
    function wards(address) external returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function ilks(bytes32) external returns (bytes32, address, uint48, uint48);
    function init(bytes32, uint256, string calldata, uint48) external;
    function bump(bytes32, uint256) external;
    function tell(bytes32) external;
    function cure(bytes32) external;
    function cull(bytes32, address) external;
    function good(bytes32) external view returns (bool);
}

interface TinlakeManagerLike {
    function wards(address) external returns(uint);
    function file(bytes32 what, address data) external;
}

contract EndSpellAction {
    ChainlogAbstract constant CHANGELOG =
        ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);

    function execute() public {
        EndAbstract(CHANGELOG.getAddress("MCD_END")).cage();
    }
}

contract TestSpell {
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

    constructor() public {
        sig = abi.encodeWithSignature("execute()");
    }

    function setTag() internal {
        bytes32 _tag;
        address _action = action;
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
    }

    function schedule() public {
        require(eta == 0, "This spell has already been scheduled");
        eta = block.timestamp + DSPauseAbstract(pause).delay();
        pause.plot(action, tag, sig, eta);
    }

    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}

contract EndSpell is TestSpell {
    constructor() public {
        action = address(new EndSpellAction());
        setTag();
    }
}

contract CullSpellAction {
    ChainlogAbstract constant CHANGELOG =
        ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);
    bytes32 constant ilk = "NS2DRP-A";

    function execute() public {
        RwaLiquidationLike(
            CHANGELOG.getAddress("MIP21_LIQUIDATION_ORACLE")
        ).cull(ilk, CHANGELOG.getAddress("NS2DRP_A_URN"));
    }
}

contract CullSpell is TestSpell {
    constructor() public {
        action = address(new CullSpellAction());
        setTag();
    }
}

contract CureSpellAction {
    ChainlogAbstract constant CHANGELOG =
        ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);
    bytes32 constant ilk = "NS2DRP-A";

    function execute() public {
        RwaLiquidationLike(
            CHANGELOG.getAddress("MIP21_LIQUIDATION_ORACLE")
        ).cure(ilk);
    }
}

contract CureSpell is TestSpell {
    constructor() public {
        action = address(new CureSpellAction());
        setTag();
    }
}

contract TellSpellAction {
    ChainlogAbstract constant CHANGELOG =
        ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);
    bytes32 constant ilk = "NS2DRP-A";

    function execute() public {
        VatAbstract(CHANGELOG.getAddress("MCD_VAT")).file(ilk, "line", 0);
        RwaLiquidationLike(
            CHANGELOG.getAddress("MIP21_LIQUIDATION_ORACLE")
        ).tell(ilk);
    }
}

contract TellSpell is TestSpell {
    constructor() public {
        action = address(new TellSpellAction());
        setTag();
    }
}

contract BumpSpellAction {
    ChainlogAbstract constant CHANGELOG =
        ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);
    bytes32 constant ilk = "NS2DRP-A";
    uint256 constant WAD = 10 ** 18;

    function execute() public {
        RwaLiquidationLike(
            CHANGELOG.getAddress("MIP21_LIQUIDATION_ORACLE")
        ).bump(ilk, 5466480 * WAD);
    }
}

contract BumpSpell is TestSpell {
    constructor() public {
        action = address(new BumpSpellAction());
        setTag();
    }
}

contract DssSpellTestBase is DSTest, DSMath {
    // populate with mainnet spell if needed
    address constant KOVAN_SPELL = address(0x94caeCD665391a7718cDD4c9a3933DBFD7EAa0d3);
    // this needs to be updated
    uint256 constant SPELL_CREATED = 1617224004;

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
        address osm_mom_authority;
        address flipper_mom_authority;
        uint256 ilk_count;
        mapping (bytes32 => CollateralValues) collaterals;
    }

    SystemValues afterSpell;

    Hevm hevm;
    Rates rates;
    Addresses addr  = new Addresses();

    // KOVAN ADDRESSES
    DSPauseAbstract              pause = DSPauseAbstract(     addr.addr("MCD_PAUSE"));
    address                 pauseProxy =                      addr.addr("MCD_PAUSE_PROXY");

    DSChiefAbstract              chief = DSChiefAbstract(     addr.addr("MCD_ADM"));
    VatAbstract                    vat = VatAbstract(         addr.addr("MCD_VAT"));

    CatAbstract                    cat = CatAbstract(         addr.addr("MCD_CAT"));
    JugAbstract                    jug = JugAbstract(         addr.addr("MCD_JUG"));

    VowAbstract                    vow = VowAbstract(         addr.addr("MCD_VOW"));
    PotAbstract                    pot = PotAbstract(         addr.addr("MCD_POT"));

    SpotAbstract                  spot = SpotAbstract(        addr.addr("MCD_SPOT"));
    DSTokenAbstract                gov = DSTokenAbstract(     addr.addr("MCD_GOV"));

    EndAbstract                    end = EndAbstract(         addr.addr("MCD_END"));
    IlkRegistryAbstract            reg = IlkRegistryAbstract( addr.addr("ILK_REGISTRY"));

    OsmMomAbstract              osmMom = OsmMomAbstract(      addr.addr("OSM_MOM"));
    FlipperMomAbstract         flipMom = FlipperMomAbstract(  addr.addr("FLIPPER_MOM"));

    DSTokenAbstract                dai = DSTokenAbstract(     addr.addr("MCD_DAI"));

    ChainlogAbstract          chainlog = ChainlogAbstract(    addr.addr("CHANGELOG"));

    bytes32 constant ilk               = "NS2DRP-A";
    DSTokenAbstract             rwagem = DSTokenAbstract(     addr.addr("NS2DRP"));
    GemJoinAbstract            rwajoin = GemJoinAbstract(     addr.addr("MCD_JOIN_NS2DRP_A"));
    RwaLiquidationLike          oracle = RwaLiquidationLike(  addr.addr("MIP21_LIQUIDATION_ORACLE"));
    RwaUrnLike                  rwaurn = RwaUrnLike(          addr.addr("NS2DRP_A_URN"));
    RwaInputConduitLike   rwaconduitin = RwaInputConduitLike( addr.addr("NS2DRP_A_INPUT_CONDUIT"));
    RwaOutputConduitLike rwaconduitout = RwaOutputConduitLike(addr.addr("NS2DRP_A_OUTPUT_CONDUIT"));

    address    makerDeployer06 = 0xda0fab060e6cc7b1C0AA105d29Bd50D71f036711;

    // Tinlake
    TinlakeManagerLike mgr = TinlakeManagerLike(0x8905C7066807793bf9c7cd1d236DEF0eE2692B9a);
    address mgr_ = address(mgr);

    RwaSpell spell;
    BumpSpell bumpSpell;
    TellSpell tellSpell;
    CureSpell cureSpell;
    CullSpell cullSpell;
    EndSpell endSpell;

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

    event Debug(uint256 index, uint256 val);
    event Debug(uint256 index, address addr);
    event Debug(uint256 index, bytes32 what);

    address self;

    // not provided in DSMath
    function rpow(
        uint256 x, uint256 n, uint256 b
    ) internal pure returns (uint256 z) {
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

    function diffCalc(
        uint256 expectedRate_, uint256 yearlyYield_
    ) public pure returns (uint256) {
        return (expectedRate_ > yearlyYield_) ?
            expectedRate_ - yearlyYield_ : yearlyYield_ - expectedRate_;
    }

    function setUp() public {
        self = address(this);
        hevm = Hevm(address(CHEAT_CODE));
        rates = new Rates();

        spell = KOVAN_SPELL != address(0) ?
            RwaSpell(KOVAN_SPELL) : new RwaSpell();

        // set this contract as ward on mgr
        hevm.store(mgr_, keccak256(abi.encode(address(this), uint(0))), bytes32(uint(1)));
        assertEq(mgr.wards(self), 1);
        // setup manager dependencies
        mgr.file("urn", address(rwaurn));
        mgr.file("liq", address(oracle));
        mgr.file("owner", self);

        //
        // Test for all system configuration changes
        //
        afterSpell = SystemValues({
            pot_dsr:               0,                     // In basis points
            vat_Line:              1872022462695350358129361112284276089361426420400424096,// In whole Dai units
            pause_delay:           60,                    // In seconds
            vow_wait:              3600,                  // In seconds
            vow_dump:              2,                     // In whole Dai units
            vow_sump:              50,                    // In whole Dai units
            vow_bump:              10,                    // In whole Dai units
            vow_hump:              500,                   // In whole Dai units
            cat_box:               10 * THOUSAND,         // In whole Dai units
            osm_mom_authority:     addr.addr("MCD_ADM"),  // OsmMom authority -> added addr.addr("MCD_ADM")
            flipper_mom_authority: addr.addr("MCD_ADM"),  // FlipperMom authority -> added addr.addr("MCD_ADM")
            ilk_count:             25                     // Num expected in system
        });

        //
        // Test for all collateral based changes here
        //
        afterSpell.collaterals["NS2DRP-A"] = CollateralValues({
            line:         5 * MILLION,     // In whole Dai units // 50 million
            dust:         0,               // In whole Dai units
            pct:          360,             // In basis points
            chop:         0,               // In basis points
            dunk:         0,               // In whole Dai units
            mat:          10000,           // In basis points // 105%
            beg:          300,             // In basis points
            ttl:          6 hours,         // In seconds
            tau:          6 hours,         // In seconds
            liquidations: 1                // 1 if enabled
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
        uint256 castTime = block.timestamp + pause.delay() - 1 minutes;
        hevm.warp(castTime);
        spell.cast();
    }

    function scheduleWaitAndCastFailLate() public {
        uint256 castTime = spell.expiration() + 1 days;
        hevm.warp(castTime);
        scheduleWaitAndCast();
    }

    function vote(address _spell) public {
        if (chief.hat() !=_spell) {
            hevm.store(
                address(gov),
                keccak256(abi.encode(address(this), uint256(1))),
                bytes32(uint256(999999999999 ether))
            );
            gov.approve(address(chief), uint256(-1));
            chief.lock(sub(gov.balanceOf(address(this)), 1 ether));

            assertTrue(!DSSpellAbstract(_spell).done());

            address[] memory yays = new address[](1);
            yays[0] = _spell;

            chief.vote(yays);
            chief.lift(_spell);
        }
        assertEq(chief.hat(), _spell);
    }

    function scheduleWaitAndCast() public {
        spell.schedule();

        uint256 castTime = block.timestamp + pause.delay();

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

    function stringToBytes32(
        string memory source
    ) public pure returns (bytes32 result) {
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
        assertTrue(
            pot.dsr() >= RAY && pot.dsr() < 1000000021979553151239153027
        );
        assertTrue(diffCalc(expectedRate(values.pot_dsr), yearlyYield(expectedDSRRate)) <= TOLERANCE);

        {
        // Line values in RAD
        assertEq(vat.Line(), values.vat_Line);
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
        uint256 normalizedDump = values.vow_dump * WAD;
        assertEq(vow.dump(), normalizedDump);
        assertTrue(
            (vow.dump() >= WAD && vow.dump() < 2 * THOUSAND * WAD) ||
            vow.dump() == 0
        );
        }

        {
        // sump values in RAD
        uint256 normalizedSump = values.vow_sump * RAD;
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
        uint256 normalizedHump = values.vow_hump * RAD;
        assertEq(vow.hump(), normalizedHump);
        assertTrue(
            (vow.hump() >= RAD && vow.hump() < HUNDRED * MILLION * RAD) ||
            vow.hump() == 0
        );
        }

        // box values in RAD
        {
            uint256 normalizedBox = values.cat_box * RAD;
            assertEq(cat.box(), normalizedBox);
        }

        // check OsmMom authority
        assertEq(osmMom.authority(), values.osm_mom_authority);

        // check FlipperMom authority
        assertEq(flipMom.authority(), values.flipper_mom_authority);

        // check number of ilks
        assertEq(reg.count(), values.ilk_count);
    }

    function checkCollateralValues(SystemValues storage values) internal {
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
        assertEq(line, normalizedTestLine);
        assertTrue((line >= RAD && line < BILLION * RAD) || line == 0);  // eq 0 or gt eq 1 RAD and lt 1B
        uint256 normalizedTestDust = values.collaterals[ilk].dust * RAD;
        assertEq(dust, normalizedTestDust);
        assertTrue((dust >= RAD && dust < 10 * THOUSAND * RAD) || dust == 0); // eq 0 or gt eq 1 and lt 10k
        }

        {
        (,uint256 mat) = spot.ilks(ilk);
        // Convert BP to system expected value
        uint256 normalizedTestMat = (values.collaterals[ilk].mat * 10**23);
        assertEq(mat, normalizedTestMat);
        assertTrue(mat >= RAY && mat < 10 * RAY);    // cr eq 100% and lt 1000%
        }

        {
        assertEq(rwajoin.wards(address(makerDeployer06)), 0); // Check deployer denied
        assertEq(rwajoin.wards(address(pauseProxy)), 1); // Check pause_proxy ward
        }

        {
        (, uint256 chop, uint256 dunk) = cat.ilks(ilk);
         assertEq(chop, values.collaterals[ilk].chop);
         assertEq(dunk, values.collaterals[ilk].dunk);
        }

        {
        (address flipper,,) = cat.ilks(ilk);
        assertEq(flipper, address(0));
        }
    }

    function executeSpell() public {
        string memory description = new RwaSpell().description();
        assertTrue(bytes(description).length > 0);
        // DS-Test can't handle strings directly, so cast to a bytes32.
        assertEq(stringToBytes32(spell.description()),
            stringToBytes32(description));

        assertEq(spell.expiration(), (SPELL_CREATED + 30 days));


        vote(address(spell));
        scheduleWaitAndCast();
        assertTrue(spell.done());
    }
}

contract DssSpellTest is DssSpellTestBase {
    function testSpellIsCast() public {
        string memory description = new RwaSpell().description();
        assertTrue(bytes(description).length > 0);
        // DS-Test can't handle strings directly, so cast to a bytes32.
        assertEq(stringToBytes32(spell.description()),
                stringToBytes32(description));

        assertEq(spell.expiration(), (SPELL_CREATED + 30 days));


        vote(address(spell));
        scheduleWaitAndCast();
        assertTrue(spell.done());

        checkSystemValues(afterSpell);
        checkCollateralValues(afterSpell);
    }

    function testFailTooLate() public {
        vote(address(spell));
        scheduleWaitAndCastFailLate();
    }

    function testFailTooEarly() public {
        vote(address(spell));
        scheduleWaitAndCastFailEarly();
    }

    function testChainlogValues() public {
        vote(address(spell));
        scheduleWaitAndCast();
        assertTrue(spell.done());

        assertEq(chainlog.getAddress("NS2DRP"), addr.addr("NS2DRP"));
        assertEq(chainlog.getAddress("MCD_JOIN_NS2DRP_A"), addr.addr("MCD_JOIN_NS2DRP_A"));
        assertEq(chainlog.getAddress("NS2DRP_A_URN"), addr.addr("NS2DRP_A_URN"));
        assertEq(chainlog.getAddress("NS2DRP_A_INPUT_CONDUIT"), addr.addr("NS2DRP_A_INPUT_CONDUIT"));
        assertEq(chainlog.getAddress("NS2DRP_A_OUTPUT_CONDUIT"), addr.addr("NS2DRP_A_OUTPUT_CONDUIT"));
        assertEq(chainlog.getAddress("MIP21_LIQUIDATION_ORACLE"), addr.addr("MIP21_LIQUIDATION_ORACLE"));
    }

    function testSpellIsCast_NS2DRP_INTEGRATION_BUMP() public {
        vote(address(spell));
        scheduleWaitAndCast();
        assertTrue(spell.done());

        bumpSpell = new BumpSpell();
        vote(address(bumpSpell));

        bumpSpell.schedule();

        uint256 castTime = block.timestamp + pause.delay();
        hevm.warp(castTime);
        (, address pip, ,) = oracle.ilks("NS2DRP-A");

        assertEq(DSValueAbstract(pip).read(), bytes32(5_366_480 * WAD));
        bumpSpell.cast();
        assertEq(DSValueAbstract(pip).read(), bytes32(5_466_480 * WAD));
    }

    function testSpellIsCast_NS2DRP_INTEGRATION_TELL() public {
        vote(address(spell));
        scheduleWaitAndCast();
        assertTrue(spell.done());

        tellSpell = new TellSpell();
        vote(address(tellSpell));

        tellSpell.schedule();

        uint256 castTime = block.timestamp + pause.delay();
        hevm.warp(castTime);
        (, , , uint48 tocPre) = oracle.ilks("NS2DRP-A");
        assertTrue(tocPre == 0);
        assertTrue(oracle.good("NS2DRP-A"));
        tellSpell.cast();
        (, , , uint48 tocPost) = oracle.ilks("NS2DRP-A");
        assertTrue(tocPost > 0);
        assertTrue(oracle.good("NS2DRP-A"));
        hevm.warp(block.timestamp + 600);
        assertTrue(!oracle.good("NS2DRP-A"));
    }

    function testSpellIsCast_NS2DRP_INTEGRATION_TELL_CURE_GOOD() public {
        vote(address(spell));
        scheduleWaitAndCast();
        assertTrue(spell.done());

        tellSpell = new TellSpell();
        vote(address(tellSpell));

        tellSpell.schedule();

        uint256 castTime = block.timestamp + pause.delay();
        hevm.warp(castTime);
        tellSpell.cast();
        assertTrue(oracle.good(ilk));
        hevm.warp(block.timestamp + 600);
        assertTrue(!oracle.good(ilk));

        cureSpell = new CureSpell();
        vote(address(cureSpell));

        cureSpell.schedule();
        castTime = block.timestamp + pause.delay();
        hevm.warp(castTime);
        cureSpell.cast();
        assertTrue(oracle.good(ilk));
        (,,, uint48 toc) = oracle.ilks(ilk);
        assertEq(uint256(toc), 0);
    }

    function testFailSpellIsCast_NS2DRP_INTEGRATION_CURE() public {
        vote(address(spell));
        scheduleWaitAndCast();
        assertTrue(spell.done());

        cureSpell = new CureSpell();
        vote(address(cureSpell));

        cureSpell.schedule();
        uint256 castTime = block.timestamp + pause.delay();
        hevm.warp(castTime);
        cureSpell.cast();
    }

    function testSpellIsCast_NS2DRP_INTEGRATION_TELL_CULL() public {
        vote(address(spell));
        scheduleWaitAndCast();
        assertTrue(spell.done());
        assertTrue(oracle.good("NS2DRP-A"));

        tellSpell = new TellSpell();
        vote(address(tellSpell));

        tellSpell.schedule();

        uint256 castTime = block.timestamp + pause.delay();
        hevm.warp(castTime);
        tellSpell.cast();
        assertTrue(oracle.good("NS2DRP-A"));
        hevm.warp(block.timestamp + 600);
        assertTrue(!oracle.good("NS2DRP-A"));

        cullSpell = new CullSpell();
        vote(address(cullSpell));

        cullSpell.schedule();
        castTime = block.timestamp + pause.delay();
        hevm.warp(castTime);
        cullSpell.cast();
        assertTrue(!oracle.good("NS2DRP-A"));
        (, address pip,,) = oracle.ilks("NS2DRP-A");
        assertEq(DSValueAbstract(pip).read(), bytes32(0));
    }

    function testSpellIsCast_NS2DRP_END() public {
        vote(address(spell));
        scheduleWaitAndCast();
        assertTrue(spell.done());

        endSpell = new EndSpell();
        vote(address(endSpell));

        endSpell.schedule();

        uint256 castTime = block.timestamp + pause.delay();
        hevm.warp(castTime);
        endSpell.cast();
    }
 }
