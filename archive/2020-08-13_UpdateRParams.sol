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
import "lib/dss-interfaces/src/dss/VowAbstract.sol";
import "lib/dss-interfaces/src/dss/FlipperMomAbstract.sol";

contract SpellAction {
    // KOVAN ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    //  against the current release list at:
    //     https://changelog.makerdao.com/releases/kovan/1.0.8/contracts.json

    address constant public MCD_VAT             = 0xbA987bDB501d131f766fEe8180Da5d81b34b69d9;
    address constant public MCD_CAT             = 0x0511674A67192FE51e86fE55Ed660eB4f995BDd6;
    address constant public MCD_JUG             = 0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD;
    address constant public MCD_POT             = 0xEA190DBDC7adF265260ec4dA6e9675Fd4f5A78bb;
    address constant public MCD_SPOT            = 0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D;
    address constant public MCD_VOW             = 0x0F4Cbe6CBA918b7488C26E29d9ECd7368F38EA3b;
    address constant public MCD_FLAP            = 0xc6d3C83A080e2Ef16E4d7d4450A869d0891024F5;
    address constant public MCD_FLOP            = 0x52482a3100F79FC568eb2f38C4a45ba457FBf5fA;

    address constant public FLIPPER_MOM         = 0xf3828caDb05E5F22844f6f9314D99516D68a0C84;

    address constant public MCD_FLIP_ETH_A      = 0xc78EdADA7e8bEa29aCc3a31bBA1D516339deD350;
    address constant public MCD_FLIP_BAT_A      = 0xc0126c3383777bDc175E659A51020E56307dDe21;
    address constant public MCD_FLIP_USDC_A     = 0xc29Ad1913C3B415497fdA1eA15c132502B8fa372;
    address constant public MCD_FLIP_USDC_B     = 0x3c9eF711B68882d9732F60758e7891AcEae2Aa7c;
    address constant public MCD_FLIP_WBTC_A     = 0x28dd4263e1FcE04A9016Bd7BF71a4f0F7aB93810;
    address constant public MCD_FLIP_TUSD_A     = 0xD4A145d161729A4B43B7Ab7DD683cB9A16E01a1b;
    address constant public MCD_FLIP_MANA_A     = 0x5CB9D33A9fE5244019e6F5f45e68F18600805264;
    address constant public MCD_FLIP_ZRX_A      = 0xe07F1219f7d6ccD59431a6b151179A9181e3902c;
    address constant public MCD_FLIP_KNC_A      = 0x644699674D06cF535772D0DC19Ad5EA695000F51;

    // decimals & precision
    uint256 constant public THOUSAND            = 10 ** 3;
    uint256 constant public MILLION             = 10 ** 6;
    uint256 constant public WAD                 = 10 ** 18;
    uint256 constant public RAY                 = 10 ** 27;
    uint256 constant public RAD                 = 10 ** 45;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    uint256 constant public ZERO_PCT_RATE     = 1000000000000000000000000000;
    uint256 constant public FORTYSIX_PCT_RATE = 1000000012000140727767957524;
    uint256 constant public EIGHT_PCT_RATE    = 1000000002440418608258400030;

    function execute() external {
        VatAbstract(MCD_VAT).file("Line", 608 * MILLION * RAD);

        PotAbstract(MCD_POT).drip();
        PotAbstract(MCD_POT).file("dsr", ZERO_PCT_RATE);

        VowAbstract(MCD_VOW).file("bump", 10 * RAD); // Lower than mainnet (due keepers testing need)
        VowAbstract(MCD_VOW).file("sump", 50 * RAD); // Lower than mainnet (due keepers testing need)
        VowAbstract(MCD_VOW).file("dump", 2 * WAD); // Lower than mainnet (due keepers testing need)
        VowAbstract(MCD_VOW).file("hump", 500 * RAD); // Lower than mainnet (due keepers testing need)
        VowAbstract(MCD_VOW).file("wait", 1 hours); // Lower than mainnet (due keepers testing need)

        FlapAbstract(MCD_FLAP).file("beg", 102 * WAD / 100);
        FlapAbstract(MCD_FLAP).file("ttl", 1 hours); // Lower than mainnet (due keepers testing need)
        FlapAbstract(MCD_FLAP).file("tau", 1 hours); // Lower than mainnet (due keepers testing need)

        FlopAbstract(MCD_FLOP).file("beg", 103 * WAD / 100);
        FlopAbstract(MCD_FLOP).file("pad", 120 * WAD / 100);
        FlopAbstract(MCD_FLOP).file("ttl", 1 hours); // Lower than mainnet (due keepers testing need)
        FlopAbstract(MCD_FLOP).file("tau", 1 hours); // Lower than mainnet (due keepers testing need)

        bytes32 ilk = "ETH-A";
        VatAbstract(MCD_VAT).file(ilk, "line", 340 * MILLION * RAD);
        VatAbstract(MCD_VAT).file(ilk, "dust", 20 * RAD);
        CatAbstract(MCD_CAT).file(ilk, "lump", 1 * WAD); // Lower than mainnet (due keepers testing need)
        CatAbstract(MCD_CAT).file(ilk, "chop", 113 * RAY / 100);
        JugAbstract(MCD_JUG).drip(ilk);
        JugAbstract(MCD_JUG).file(ilk, "duty", ZERO_PCT_RATE);
        SpotAbstract(MCD_SPOT).file(ilk, "mat", 150 * RAY / 100);
        FlipAbstract(MCD_FLIP_ETH_A).file("beg", 103 * WAD / 100);
        FlipAbstract(MCD_FLIP_ETH_A).file("ttl", 1 hours); // Lower than mainnet (due keepers testing need)
        FlipAbstract(MCD_FLIP_ETH_A).file("tau", 1 hours); // Lower than mainnet (due keepers testing need)

        ilk = "BAT-A";
        VatAbstract(MCD_VAT).file(ilk, "line", 5 * MILLION * RAD);
        VatAbstract(MCD_VAT).file(ilk, "dust", 20 * RAD);
        CatAbstract(MCD_CAT).file(ilk, "lump", 1500 * WAD); // Lower than mainnet (due keepers testing need)
        CatAbstract(MCD_CAT).file(ilk, "chop", 113 * RAY / 100);
        JugAbstract(MCD_JUG).drip(ilk);
        JugAbstract(MCD_JUG).file(ilk, "duty", ZERO_PCT_RATE);
        SpotAbstract(MCD_SPOT).file(ilk, "mat", 150 * RAY / 100);
        FlipAbstract(MCD_FLIP_BAT_A).file("beg", 103 * WAD / 100);
        FlipAbstract(MCD_FLIP_BAT_A).file("ttl", 1 hours); // Lower than mainnet (due keepers testing need)
        FlipAbstract(MCD_FLIP_BAT_A).file("tau", 1 hours); // Lower than mainnet (due keepers testing need)

        ilk = "USDC-A";
        VatAbstract(MCD_VAT).file(ilk, "line", 140 * MILLION * RAD);
        VatAbstract(MCD_VAT).file(ilk, "dust", 20 * RAD);
        CatAbstract(MCD_CAT).file(ilk, "lump", 500 * WAD); // Lower than mainnet (due keepers testing need)
        CatAbstract(MCD_CAT).file(ilk, "chop", 113 * RAY / 100);
        JugAbstract(MCD_JUG).drip(ilk);
        JugAbstract(MCD_JUG).file(ilk, "duty", ZERO_PCT_RATE);
        SpotAbstract(MCD_SPOT).file(ilk, "mat", 110 * RAY / 100);
        FlipAbstract(MCD_FLIP_USDC_A).file("beg", 103 * WAD / 100);
        FlipAbstract(MCD_FLIP_USDC_A).file("ttl", 1 hours); // Lower than mainnet (due keepers testing need)
        FlipAbstract(MCD_FLIP_USDC_A).file("tau", 1 hours); // Lower than mainnet (due keepers testing need)
        FlipperMomAbstract(FLIPPER_MOM).deny(MCD_FLIP_USDC_A);

        ilk = "USDC-B";
        VatAbstract(MCD_VAT).file(ilk, "line", 30 * MILLION * RAD);
        VatAbstract(MCD_VAT).file(ilk, "dust", 20 * RAD);
        CatAbstract(MCD_CAT).file(ilk, "lump", 500 * WAD); // Lower than mainnet (due keepers testing need)
        CatAbstract(MCD_CAT).file(ilk, "chop", 113 * RAY / 100);
        JugAbstract(MCD_JUG).drip(ilk);
        JugAbstract(MCD_JUG).file(ilk, "duty", FORTYSIX_PCT_RATE);
        SpotAbstract(MCD_SPOT).file(ilk, "mat", 120 * RAY / 100);
        FlipAbstract(MCD_FLIP_USDC_B).file("beg", 103 * WAD / 100);
        FlipAbstract(MCD_FLIP_USDC_B).file("ttl", 1 hours); // Lower than mainnet (due keepers testing need)
        FlipAbstract(MCD_FLIP_USDC_B).file("tau", 1 hours); // Lower than mainnet (due keepers testing need)
        FlipperMomAbstract(FLIPPER_MOM).deny(MCD_FLIP_USDC_B);

        ilk = "WBTC-A";
        VatAbstract(MCD_VAT).file(ilk, "line", 80 * MILLION * RAD);
        VatAbstract(MCD_VAT).file(ilk, "dust", 20 * RAD);
        CatAbstract(MCD_CAT).file(ilk, "lump", 1 * WAD / 100); // Lower than mainnet (due keepers testing need)
        CatAbstract(MCD_CAT).file(ilk, "chop", 113 * RAY / 100);
        JugAbstract(MCD_JUG).drip(ilk);
        JugAbstract(MCD_JUG).file(ilk, "duty", ZERO_PCT_RATE);
        SpotAbstract(MCD_SPOT).file(ilk, "mat", 150 * RAY / 100);
        FlipAbstract(MCD_FLIP_WBTC_A).file("beg", 103 * WAD / 100);
        FlipAbstract(MCD_FLIP_WBTC_A).file("ttl", 1 hours); // Lower than mainnet (due keepers testing need)
        FlipAbstract(MCD_FLIP_WBTC_A).file("tau", 1 hours); // Lower than mainnet (due keepers testing need)
        
        ilk = "TUSD-A";
        VatAbstract(MCD_VAT).file(ilk, "line", 2 * MILLION * RAD);
        VatAbstract(MCD_VAT).file(ilk, "dust", 20 * RAD);
        CatAbstract(MCD_CAT).file(ilk, "lump", 500 * WAD); // Lower than mainnet (due keepers testing need)
        CatAbstract(MCD_CAT).file(ilk, "chop", 113 * RAY / 100);
        JugAbstract(MCD_JUG).drip(ilk);
        JugAbstract(MCD_JUG).file(ilk, "duty", ZERO_PCT_RATE);
        SpotAbstract(MCD_SPOT).file(ilk, "mat", 120 * RAY / 100);
        FlipAbstract(MCD_FLIP_TUSD_A).file("beg", 103 * WAD / 100);
        FlipAbstract(MCD_FLIP_TUSD_A).file("ttl", 1 hours); // Lower than mainnet (due keepers testing need)
        FlipAbstract(MCD_FLIP_TUSD_A).file("tau", 1 hours); // Lower than mainnet (due keepers testing need)
        // FlipperMomAbstract(FLIPPER_MOM).deny(MCD_FLIP_TUSD_A); Not yet as not done in mainnet

        ilk = "MANA-A";
        VatAbstract(MCD_VAT).file(ilk, "line", 1 * MILLION * RAD);
        VatAbstract(MCD_VAT).file(ilk, "dust", 20 * RAD);
        CatAbstract(MCD_CAT).file(ilk, "lump", 500 * WAD); // Lower than mainnet (due keepers testing need)
        CatAbstract(MCD_CAT).file(ilk, "chop", 113 * RAY / 100);
        JugAbstract(MCD_JUG).drip(ilk);
        JugAbstract(MCD_JUG).file(ilk, "duty", EIGHT_PCT_RATE);
        SpotAbstract(MCD_SPOT).file(ilk, "mat", 175 * RAY / 100);
        FlipAbstract(MCD_FLIP_MANA_A).file("beg", 103 * WAD / 100);
        FlipAbstract(MCD_FLIP_MANA_A).file("ttl", 1 hours); // Lower than mainnet (due keepers testing need)
        FlipAbstract(MCD_FLIP_MANA_A).file("tau", 1 hours); // Lower than mainnet (due keepers testing need)

        ilk = "ZRX-A";
        VatAbstract(MCD_VAT).file(ilk, "line", 5 * MILLION * RAD);
        VatAbstract(MCD_VAT).file(ilk, "dust", 20 * RAD);
        CatAbstract(MCD_CAT).file(ilk, "lump", 100 * WAD);
        CatAbstract(MCD_CAT).file(ilk, "chop", 113 * RAY / 100);
        JugAbstract(MCD_JUG).drip(ilk);
        JugAbstract(MCD_JUG).file(ilk, "duty", ZERO_PCT_RATE);
        SpotAbstract(MCD_SPOT).file(ilk, "mat", 175 * RAY / 100);
        FlipAbstract(MCD_FLIP_ZRX_A).file("beg", 103 * WAD / 100);
        FlipAbstract(MCD_FLIP_ZRX_A).file("ttl", 1 hours); // Lower than mainnet (due keepers testing need)
        FlipAbstract(MCD_FLIP_ZRX_A).file("tau", 1 hours); // Lower than mainnet (due keepers testing need)

        ilk = "KNC-A";
        VatAbstract(MCD_VAT).file(ilk, "line", 5 * MILLION * RAD);
        VatAbstract(MCD_VAT).file(ilk, "dust", 20 * RAD);
        CatAbstract(MCD_CAT).file(ilk, "lump", 50 * WAD); // Lower than mainnet (due keepers testing need)
        CatAbstract(MCD_CAT).file(ilk, "chop", 113 * RAY / 100);
        JugAbstract(MCD_JUG).drip(ilk);
        JugAbstract(MCD_JUG).file(ilk, "duty", ZERO_PCT_RATE);
        SpotAbstract(MCD_SPOT).file(ilk, "mat", 175 * RAY / 100);
        FlipAbstract(MCD_FLIP_KNC_A).file("beg", 103 * WAD / 100);
        FlipAbstract(MCD_FLIP_KNC_A).file("ttl", 1 hours); // Lower than mainnet (due keepers testing need)
        FlipAbstract(MCD_FLIP_KNC_A).file("tau", 1 hours); // Lower than mainnet (due keepers testing need)
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
