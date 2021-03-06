// SPDX-FileCopyrightText: © 2021-2022 Dai Foundation <www.daifoundation.org>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Copyright (C) 2021-2022 Dai Foundation
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

pragma solidity 0.6.12;

// Enable ABIEncoderV2 when onboarding collateral
// pragma experimental ABIEncoderV2;
import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

import { DssSpellCollateralOnboardingAction } from "./Goerli-DssSpellCollateralOnboarding.sol";

interface VatLike {
    function Line() external view returns (uint256);
    function file(bytes32, uint256) external;
    function ilks(bytes32) external returns (uint256 Art, uint256 rate, uint256 spot, uint256 line, uint256 dust);
}

interface StarknetLike {
    function setCeiling(uint256) external;
}

contract DssSpellAction is DssAction, DssSpellCollateralOnboardingAction {

    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    address constant STARKNET_ESCROW_MOM    = 0x464379BD1aC523DdA45b7B78eCB1F703661cad2a;
    address constant STARKNET_ESCROW        = 0x38c3DDF1eF3e045abDDEb94f4e7a1a0d5440EB44;
    address constant STARKNET_DAI_BRIDGE    = 0xd8beAa22894Cd33F24075459cFba287a10a104E4;
    address constant STARKNET_GOV_RELAY     = 0x73c0049Dd6560E644984Fa3Af30A55a02a7D81fB;

    address constant  OLD_MCD_ESM           = 0x105BF37e7D81917b6fEACd6171335B4838e53D5e;
    address immutable NEW_MCD_ESM           = DssExecLib.getChangelogAddress("MCD_ESM");

    VatLike immutable vat = VatLike(DssExecLib.vat());

    // Math
    uint256 constant MILLION = 10 ** 6;
    uint256 constant WAD     = 10 ** 18;
    uint256 constant RAD     = 10 ** 45;

    function _sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "sub-underflow");
    }

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmPgPVrVxDCGyNR5rGp9JC5AUxppLzUAqvncRJDcxQnX1u
    //

    // Turn office hours off
    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {
        // ---------------------------------------------------------------------
        // Includes changes from the DssSpellCollateralOnboardingAction
        // onboardNewCollaterals();


        // Core Unit Budget DAI Transfer
        // https://mips.makerdao.com/mips/details/MIP40c3SP67#budget-request-up-front
        //
        //    SH-001 - 230,000 DAI - 0xc657aC882Fb2D6CcF521801da39e910F8519508d
        //  MAINNET ONLY


        // Core Unit DAI Budget Stream
        // https://mips.makerdao.com/mips/details/MIP40c3SP67#budget-request-up-front
        //
        //    SH-001 | 2022-06-01 to 2023-03-15 | 540,000 DAI | 0xc657aC882Fb2D6CcF521801da39e910F8519508d
        // MAINNET ONLY


        // Core Unit MKR Budget Stream
        // https://mips.makerdao.com/mips/details/MIP40c3SP67#budget-request-up-front
        //
        //    SH-001 | 2022-06-01 to 2026-06-01 | Cliff 2023-11-23 | 250 MKR | 0x955993Df48b0458A01cfB5fd7DF5F5DCa6443550
        // MAINNET ONLY


        // MOMC Proposal
        // https://vote.makerdao.com/polling/QmYx9e3k#poll-detail
        //
        // Maximum Debt Ceiling Decreases
        //
        //    Decrease WSTETH-A Maximum Debt Ceiling from 300 million to 200 million
        DssExecLib.setIlkAutoLineDebtCeiling("WSTETH-A", 200 * MILLION);

        //    Reduce Aave D3M Maximum Debt Ceiling from 300 million to 100 million
        // MAINNET ONLY

        //    Reduce LINK-A Maximum Debt Ceiling from 100 million DAI to 50 million DAI
        DssExecLib.setIlkAutoLineDebtCeiling("LINK-A", 50 * MILLION);

        // Maximum Debt Ceiling Increase
        //
        //    Increase MANA-A Maximum Debt Ceiling from 10 million DAI to 15 million DAI
        DssExecLib.setIlkAutoLineDebtCeiling("MANA-A", 15 * MILLION);

        // D3M Target Borrow Rate Decrease
        //
        //    Reduce DIRECT-AAVEV2-DAI Target Borrow Rate from 3.5% to 2.75%
        // MAINNET ONLY

        // Target Available Debt Increase
        //
        //    Increase WSTETH-B Target Available Debt from 15 million DAI to 30 million DAI
        DssExecLib.setIlkAutoLineParameters("WSTETH-B", 150 * MILLION, 30 * MILLION, 8 hours);


        // 1st Stage of Collateral Offboarding Process
        // https://forum.makerdao.com/t/signal-request-offboard-uni-univ2daieth-univ2wbtceth-univ2unieth-and-univ2wbtcdai/15160
        //
        uint256 line;
        uint256 lineReduction;

        //    Set UNI-A Maximum Debt Ceiling to 0
        (,,,line,) = vat.ilks("UNI-A");
        lineReduction += line;
        DssExecLib.removeIlkFromAutoLine("UNI-A");
        DssExecLib.setIlkDebtCeiling("UNI-A", 0);

        //    Set UNIV2DAIETH-A Maximum Debt Ceiling to 0
        (,,,line,) = vat.ilks("UNIV2DAIETH-A");
        lineReduction += line;
        DssExecLib.removeIlkFromAutoLine("UNIV2DAIETH-A");
        DssExecLib.setIlkDebtCeiling("UNIV2DAIETH-A", 0);

        //    Set UNIV2WBTCETH-A Maximum Debt Ceiling to 0
        (,,,line,) = vat.ilks("UNIV2WBTCETH-A");
        lineReduction += line;
        DssExecLib.removeIlkFromAutoLine("UNIV2WBTCETH-A");
        DssExecLib.setIlkDebtCeiling("UNIV2WBTCETH-A", 0);

        //    Set UNIV2UNIETH-A Maximum Debt Ceiling to 0
        (,,,line,) = vat.ilks("UNIV2UNIETH-A");
        lineReduction += line;
        DssExecLib.removeIlkFromAutoLine("UNIV2UNIETH-A");
        DssExecLib.setIlkDebtCeiling("UNIV2UNIETH-A", 0);

        //    Set UNIV2WBTCDAI-A Maximum Debt Ceiling to 0
        (,,,line,) = vat.ilks("UNIV2WBTCDAI-A");
        lineReduction += line;
        DssExecLib.removeIlkFromAutoLine("UNIV2WBTCDAI-A");
        DssExecLib.setIlkDebtCeiling("UNIV2WBTCDAI-A", 0);

        // Decrease Global Debt Ceiling by total amount of offboarded ilks
        vat.file("Line", _sub(vat.Line(), lineReduction));


        // Recognized Delegate Compensation
        //    https://forum.makerdao.com/t/recognized-delegate-compensation-breakdown-may-2022/15536
        //
        //    Flip Flop Flap Delegate LLC - 12000 DAI - 0x688d508f3a6B0a377e266405A1583B3316f9A2B3
        // MAINNET ONLY
        //    schuppi - 12000 DAI - 0xCCffDBc38B1463847509dCD95e0D9AAf54D1c167
        // MAINNET ONLY
        //    Feedblack Loops LLC - 12000 DAI - 0x80882f2A36d49fC46C3c654F7f9cB9a2Bf0423e1
        // MAINNET ONLY
        //    MakerMan - 11025 DAI - 0x9AC6A6B24bCd789Fa59A175c0514f33255e1e6D0
        // MAINNET ONLY
        //    ACREInvest - 9372 DAI - 0x5b9C98e8A3D9Db6cd4B4B4C1F92D0A551D06F00D
        // MAINNET ONLY
        //    monetsupply - 6275 DAI - 0x4Bd73eeE3d0568Bb7C52DFCad7AD5d47Fff5E2CF
        // MAINNET ONLY
        //    JustinCase - 7626 DAI - 0xE070c2dCfcf6C6409202A8a210f71D51dbAe9473
        // MAINNET ONLY
        //    GFX Labs - 6607 DAI - 0xa6e8772af29b29B9202a073f8E36f447689BEef6
        // MAINNET ONLY
        //    Doo - 622 DAI - 0x3B91eBDfBC4B78d778f62632a4004804AC5d2DB0
        // MAINNET ONLY
        //    Flipside Crypto - 270 DAI - 0x62a43123FE71f9764f26554b3F5017627996816a
        // MAINNET ONLY
        //    Penn Blockchain - 265 DAI - 0x070341aA5Ed571f0FB2c4a5641409B1A46b4961b
        // MAINNET ONLY


        // Starknet Bridge Changes
        // https://forum.makerdao.com/t/details-about-spells-to-be-included-in-june-8th-2022-executive-vote/15532
        //
        //    Increase Starknet Bridge Limit from 100,000 DAI to 200,000 DAI
        StarknetLike(STARKNET_DAI_BRIDGE).setCeiling(200_000 * WAD);
        //    Give DSChief control over L1EscrowMom
        DssExecLib.setAuthority(STARKNET_ESCROW_MOM, DssExecLib.getChangelogAddress("MCD_ADM"));

        // Old MCD_ESM is authed on Starknet contracts, auth new one instead
        DssExecLib.deauthorize(STARKNET_ESCROW, OLD_MCD_ESM);
        DssExecLib.authorize(STARKNET_ESCROW, NEW_MCD_ESM);
        DssExecLib.deauthorize(STARKNET_DAI_BRIDGE, OLD_MCD_ESM);
        DssExecLib.authorize(STARKNET_DAI_BRIDGE, NEW_MCD_ESM);
        DssExecLib.deauthorize(STARKNET_GOV_RELAY, OLD_MCD_ESM);
        DssExecLib.authorize(STARKNET_GOV_RELAY, NEW_MCD_ESM);

        // Changelog
        DssExecLib.setChangelogAddress("STARKNET_ESCROW_MOM", STARKNET_ESCROW_MOM);
        DssExecLib.setChangelogAddress("STARKNET_ESCROW", STARKNET_ESCROW);
        DssExecLib.setChangelogAddress("STARKNET_DAI_BRIDGE", STARKNET_DAI_BRIDGE);
        DssExecLib.setChangelogAddress("STARKNET_GOV_RELAY", STARKNET_GOV_RELAY);
        DssExecLib.setChangelogVersion("1.13.1");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
