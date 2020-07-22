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
import "lib/dss-interfaces/src/dss/VatAbstract.sol";
import "lib/dss-interfaces/src/dss/CatAbstract.sol";
import "lib/dss-interfaces/src/dss/JugAbstract.sol";
import "lib/dss-interfaces/src/dss/FlipAbstract.sol";
import "lib/dss-interfaces/src/dss/FlapAbstract.sol";
import "lib/dss-interfaces/src/dss/FlopAbstract.sol";
import "lib/dss-interfaces/src/dss/SpotAbstract.sol";
import "lib/dss-interfaces/src/dss/PotAbstract.sol";
import "lib/dss-interfaces/src/dss/FlipperMomAbstract.sol";
import "lib/dss-interfaces/src/dss/VowAbstract.sol";
import "lib/dss-interfaces/src/dss/MkrAuthorityAbstract.sol";

contract SpellAction {

    // KOVAN ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    //  against the current release list at:
    //     https://changelog.makerdao.com/releases/kovan/1.0.8/contracts.json

    address constant public MCD_VAT             = 0xbA987bDB501d131f766fEe8180Da5d81b34b69d9;
    address constant public MCD_VOW             = 0x0F4Cbe6CBA918b7488C26E29d9ECd7368F38EA3b;
    address constant public MCD_CAT             = 0x0511674A67192FE51e86fE55Ed660eB4f995BDd6;
    address constant public MCD_JUG             = 0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD;
    address constant public MCD_POT             = 0xEA190DBDC7adF265260ec4dA6e9675Fd4f5A78bb;
    address constant public GOV_GUARD           = 0xE50303C6B67a2d869684EFb09a62F6aaDD06387B;

    address constant public MCD_SPOT            = 0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D;
    address constant public MCD_END             = 0x24728AcF2E2C403F5d2db4Df6834B8998e56aA5F;
    address constant public FLIPPER_MOM         = 0xf3828caDb05E5F22844f6f9314D99516D68a0C84;

    address constant public MCD_FLAP            = 0xc6d3C83A080e2Ef16E4d7d4450A869d0891024F5;
    address constant public MCD_FLOP            = 0x52482a3100F79FC568eb2f38C4a45ba457FBf5fA;
    address constant public MCD_FLAP_OLD        = 0x064cd5f762851b1af81Fd8fcA837227cb3eC84b4;
    address constant public MCD_FLOP_OLD        = 0x145B00b1AC4F01E84594EFa2972Fce1f5Beb5CED;

    address constant public MCD_FLIP_ETH_A      = 0xc78EdADA7e8bEa29aCc3a31bBA1D516339deD350;
    address constant public MCD_FLIP_ETH_A_OLD  = 0xB40139Ea36D35d0C9F6a2e62601B616F1FfbBD1b;

    address constant public MCD_FLIP_BAT_A      = 0xc0126c3383777bDc175E659A51020E56307dDe21;
    address constant public MCD_FLIP_BAT_A_OLD  = 0xC94014A032cA5fCc01271F4519Add7E87a16b94C;

    address constant public MCD_FLIP_USDC_A     = 0xc29Ad1913C3B415497fdA1eA15c132502B8fa372;
    address constant public MCD_FLIP_USDC_A_OLD = 0x45d5b4A304f554262539cfd167dd05e331Da686E;

    address constant public MCD_FLIP_USDC_B     = 0x3c9eF711B68882d9732F60758e7891AcEae2Aa7c;
    address constant public MCD_FLIP_USDC_B_OLD = 0x93AE217b0C6bF52E9FFea6Ab191cCD438d9EC0de;

    address constant public MCD_FLIP_WBTC_A     = 0x28dd4263e1FcE04A9016Bd7BF71a4f0F7aB93810;
    address constant public MCD_FLIP_WBTC_A_OLD = 0xc45A1b76D3316D56a0225fB02Ab6b7637403fF67;

    address constant public MCD_FLIP_ZRX_A      = 0xe07F1219f7d6ccD59431a6b151179A9181e3902c;
    address constant public MCD_FLIP_ZRX_A_OLD  = 0x1341E0947D03Fd2C24e16aaEDC347bf9D9af002F;

    address constant public MCD_FLIP_KNC_A      = 0x644699674D06cF535772D0DC19Ad5EA695000F51;
    address constant public MCD_FLIP_KNC_A_OLD  = 0xf14Ec3538C86A31bBf576979783a8F6dbF16d571;

    address constant public MCD_FLIP_TUSD_A     = 0xD4A145d161729A4B43B7Ab7DD683cB9A16E01a1b;
    address constant public MCD_FLIP_TUSD_A_OLD = 0x51a8fB578E830c932A2D49927584C643Ad08d9eC;

    // decimals & precision
    uint256 constant public THOUSAND = 10 ** 3;
    uint256 constant public MILLION  = 10 ** 6;
    uint256 constant public WAD      = 10 ** 18;
    uint256 constant public RAY      = 10 ** 27;
    uint256 constant public RAD      = 10 ** 45;

    function execute() external {

        PotAbstract(MCD_POT).drip();
        JugAbstract(MCD_JUG).drip("ETH-A");
        JugAbstract(MCD_JUG).drip("BAT-A");
        JugAbstract(MCD_JUG).drip("USDC-A");
        JugAbstract(MCD_JUG).drip("USDC-B");
        JugAbstract(MCD_JUG).drip("WBTC-A");
        JugAbstract(MCD_JUG).drip("ZRX-A");
        JugAbstract(MCD_JUG).drip("KNC-A");
        JugAbstract(MCD_JUG).drip("TUSD-A");

        /*** Add new Flip, Flap, Flop contracts ***/
        MkrAuthorityAbstract mkrAuthority = MkrAuthorityAbstract(GOV_GUARD);
        VatAbstract vat                   = VatAbstract(MCD_VAT);
        CatAbstract cat                   = CatAbstract(MCD_CAT);
        VowAbstract vow                   = VowAbstract(MCD_VOW);

        FlapAbstract newFlap = FlapAbstract(MCD_FLAP);
        FlopAbstract newFlop = FlopAbstract(MCD_FLOP);
        FlapAbstract oldFlap = FlapAbstract(MCD_FLAP_OLD);
        FlopAbstract oldFlop = FlopAbstract(MCD_FLOP_OLD);

        /*** Flap ***/
        vow.file("flapper", MCD_FLAP);
        newFlap.rely(MCD_VOW);
        newFlap.file("beg", oldFlap.beg());
        newFlap.file("ttl", oldFlap.ttl());
        newFlap.file("tau", oldFlap.tau());
        oldFlap.deny(MCD_VOW);
        require(newFlap.gem() == oldFlap.gem(), "non-matching-gem");
        require(newFlap.vat() == MCD_VAT, "non-matching-vat");

        /*** Flop ***/
        vow.file("flopper", MCD_FLOP);
        newFlop.rely(MCD_VOW);
        vat.rely(MCD_FLOP);
        mkrAuthority.rely(MCD_FLOP);
        newFlop.file("beg", oldFlop.beg());
        newFlop.file("pad", oldFlop.pad());
        newFlop.file("ttl", oldFlop.ttl());
        newFlop.file("tau", oldFlop.tau());
        oldFlop.deny(MCD_VOW);
        vat.deny(MCD_FLOP_OLD);
        mkrAuthority.deny(MCD_FLOP_OLD);
        require(newFlop.gem() == oldFlop.gem(), "non-matching-gem");
        require(newFlop.vat() == MCD_VAT, "non-matching-vat");

        FlipAbstract newFlip;
        FlipAbstract oldFlip;
        bytes32 ilk;

        // /*** ETH-A Flip ***/
        ilk = "ETH-A";
        newFlip = FlipAbstract(MCD_FLIP_ETH_A);
        oldFlip = FlipAbstract(MCD_FLIP_ETH_A_OLD);

        cat.file(ilk, "flip", address(newFlip));
        newFlip.rely(MCD_CAT);
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        oldFlip.deny(MCD_CAT);
        oldFlip.deny(MCD_END);
        oldFlip.deny(FLIPPER_MOM);
        newFlip.file("beg", oldFlip.beg());
        newFlip.file("ttl", oldFlip.ttl());
        newFlip.file("tau", oldFlip.tau());
        require(newFlip.ilk() == ilk, "non-matching-ilk");
        require(newFlip.vat() == MCD_VAT, "non-matching-vat");


        /*** BAT-A Flip ***/
        ilk = "BAT-A";
        newFlip = FlipAbstract(MCD_FLIP_BAT_A);
        oldFlip = FlipAbstract(MCD_FLIP_BAT_A_OLD);

        cat.file(ilk, "flip", address(newFlip));
        newFlip.rely(MCD_CAT);
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        oldFlip.deny(MCD_CAT);
        oldFlip.deny(MCD_END);
        oldFlip.deny(FLIPPER_MOM);
        newFlip.file("beg", oldFlip.beg());
        newFlip.file("ttl", oldFlip.ttl());
        newFlip.file("tau", oldFlip.tau());
        require(newFlip.ilk() == ilk, "non-matching-ilk");
        require(newFlip.vat() == MCD_VAT, "non-matching-vat");


        /*** USDC-A Flip ***/
        ilk = "USDC-A";
        newFlip = FlipAbstract(MCD_FLIP_USDC_A);
        oldFlip = FlipAbstract(MCD_FLIP_USDC_A_OLD);

        cat.file(ilk, "flip", address(newFlip));
        newFlip.rely(MCD_CAT); // This will be denied after via FlipperMom, just doing this for explicitness
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        oldFlip.deny(MCD_CAT);
        oldFlip.deny(MCD_END);
        oldFlip.deny(FLIPPER_MOM);
        newFlip.file("beg", oldFlip.beg());
        newFlip.file("ttl", oldFlip.ttl());
        newFlip.file("tau", oldFlip.tau());
        require(newFlip.ilk() == ilk, "non-matching-ilk");
        require(newFlip.vat() == MCD_VAT, "non-matching-vat");
        FlipperMomAbstract(FLIPPER_MOM).deny(MCD_FLIP_USDC_A);


        /*** USDC-B Flip ***/
        ilk = "USDC-B";
        newFlip = FlipAbstract(MCD_FLIP_USDC_B);
        oldFlip = FlipAbstract(MCD_FLIP_USDC_B_OLD);

        cat.file(ilk, "flip", address(newFlip));
        newFlip.rely(MCD_CAT); // This will be denied after via FlipperMom, just doing this for explicitness
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        oldFlip.deny(MCD_CAT);
        oldFlip.deny(MCD_END);
        oldFlip.deny(FLIPPER_MOM);
        newFlip.file("beg", oldFlip.beg());
        newFlip.file("ttl", oldFlip.ttl());
        newFlip.file("tau", oldFlip.tau());
        require(newFlip.ilk() == ilk, "non-matching-ilk");
        require(newFlip.vat() == MCD_VAT, "non-matching-vat");
        FlipperMomAbstract(FLIPPER_MOM).deny(MCD_FLIP_USDC_B);


        /*** WBTC-A Flip ***/
        ilk = "WBTC-A";
        newFlip = FlipAbstract(MCD_FLIP_WBTC_A);
        oldFlip = FlipAbstract(MCD_FLIP_WBTC_A_OLD);

        cat.file(ilk, "flip", address(newFlip));
        newFlip.rely(MCD_CAT);
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        oldFlip.deny(MCD_CAT);
        oldFlip.deny(MCD_END);
        oldFlip.deny(FLIPPER_MOM);
        newFlip.file("beg", oldFlip.beg());
        newFlip.file("ttl", oldFlip.ttl());
        newFlip.file("tau", oldFlip.tau());
        require(newFlip.ilk() == ilk, "non-matching-ilk");
        require(newFlip.vat() == MCD_VAT, "non-matching-vat");


        /*** ZRX-A Flip ***/
        ilk = "ZRX-A";
        newFlip = FlipAbstract(MCD_FLIP_ZRX_A);
        oldFlip = FlipAbstract(MCD_FLIP_ZRX_A_OLD);

        cat.file(ilk, "flip", address(newFlip));
        newFlip.rely(MCD_CAT);
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        oldFlip.deny(MCD_CAT);
        oldFlip.deny(MCD_END);
        oldFlip.deny(FLIPPER_MOM);
        newFlip.file("beg", oldFlip.beg());
        newFlip.file("ttl", oldFlip.ttl());
        newFlip.file("tau", oldFlip.tau());
        require(newFlip.ilk() == ilk, "non-matching-ilk");
        require(newFlip.vat() == MCD_VAT, "non-matching-vat");


        /*** KNC-A Flip ***/
        ilk = "KNC-A";
        newFlip = FlipAbstract(MCD_FLIP_KNC_A);
        oldFlip = FlipAbstract(MCD_FLIP_KNC_A_OLD);

        cat.file(ilk, "flip", address(newFlip));
        newFlip.rely(MCD_CAT);
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        oldFlip.deny(MCD_CAT);
        oldFlip.deny(MCD_END);
        oldFlip.deny(FLIPPER_MOM);
        newFlip.file("beg", oldFlip.beg());
        newFlip.file("ttl", oldFlip.ttl());
        newFlip.file("tau", oldFlip.tau());
        require(newFlip.ilk() == ilk, "non-matching-ilk");
        require(newFlip.vat() == MCD_VAT, "non-matching-vat");


        /*** TUSD-A Flip ***/
        ilk = "TUSD-A";
        newFlip = FlipAbstract(MCD_FLIP_TUSD_A);
        oldFlip = FlipAbstract(MCD_FLIP_TUSD_A_OLD);

        cat.file(ilk, "flip", address(newFlip));
        newFlip.rely(MCD_CAT);
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        oldFlip.deny(MCD_CAT);
        oldFlip.deny(MCD_END);
        oldFlip.deny(FLIPPER_MOM);
        newFlip.file("beg", oldFlip.beg());
        newFlip.file("ttl", oldFlip.ttl());
        newFlip.file("tau", oldFlip.tau());
        require(newFlip.ilk() == ilk, "non-matching-ilk");
        require(newFlip.vat() == MCD_VAT, "non-matching-vat");
    }
}

contract DssSpell {
    DSPauseAbstract  public pause =
        DSPauseAbstract(0x8754E6ecb4fe68DaA5132c2886aB39297a5c7189);
    address          public action;
    bytes32          public tag;
    uint256          public eta;
    bytes            public sig;
    uint256          public expiration;
    bool             public done;

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
