// SPDX-FileCopyrightText: © 2020 Dai Foundation <www.daifoundation.org>
// SPDX-License-Identifier: AGPL-3.0-or-later
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
// Enable ABIEncoderV2 when onboarding collateral through `DssExecLib.addNewCollateral()`
// pragma experimental ABIEncoderV2;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

import { DssSpellCollateralAction } from "./Goerli-DssSpellCollateral.sol";

interface GemLike {
    function approve(address, uint256) external returns (bool);
}

interface StarknetLike {
    function setMaxDeposit(uint256) external;
}

interface TeleportOracleAuthLike {
    function addSigners(address[] calldata) external;
    function removeSigners(address[] calldata) external;
}

interface RwaUrnLike {
    function lock(uint256) external;
    function draw(uint256) external;
}

contract DssSpellAction is DssAction, DssSpellCollateralAction {
    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: cast keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/969f04cfec25e56791fbe4503bcbe2df7a58df1e/governance/votes/Executive%20vote%20-%20July%2029%2C%202022.md -q -O - 2>/dev/null)"
    string public constant override description ="Goerli Spell";

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmVp4mhhbwWGTfbh2BzwQB9eiBrQBKiqcPRZCaAxNUaar6
    //

    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {

        // ---------------------------------------------------------------------
        // Includes changes from the DssSpellCollateralAction
        onboardNewCollaterals();

        // lock RWA007 Token in the URN
        GemLike(RWA007).approve(RWA007_A_URN, 1 * WAD);
        RwaUrnLike(RWA007_A_URN).lock(1 * WAD);

        // Increase Starknet Bridge Deposit Limit from 50 DAI to 1000 DAI
        // https://vote.makerdao.com/polling/QmbWkTvW
        StarknetLike(DssExecLib.getChangelogAddress("STARKNET_DAI_BRIDGE")).setMaxDeposit(1000 * WAD);

        // ------------------ Update Teleport Feeds ----------------- 
        TeleportOracleAuthLike teleportOracleAuth = TeleportOracleAuthLike(DssExecLib.getChangelogAddress("MCD_ORACLE_AUTH_TELEPORT_FW_A"));
        address[] memory feedsToRemove = new address[](9);
        feedsToRemove[0] = 0x0E0cDcbbE170f6d81f87b45c2227526B6779A083;
        feedsToRemove[1] = 0x73093A55d5703C7A81D7381F7F24FCf432c64652;
        feedsToRemove[2] = 0x2a2b83700c990FDFEFD22968fc7C4A4B80783E60;
        feedsToRemove[3] = 0x1BC7410DD4D18bf8f613F4B6a646FA3953D3A0f2;
        feedsToRemove[4] = 0xE5D5b00cc04596461a5527616b4F88B754879aE8;
        feedsToRemove[5] = 0xA5E6053Fe351883036d13C2219b68102AbdFcBB6;
        feedsToRemove[6] = 0x59524b843866b9686c520fB3d3613A73fe303d30;
        feedsToRemove[7] = 0x794D810a3d524B9E25227bFA22E69CaaC8544EF2;
        feedsToRemove[8] = 0xE85963ACc9A361E13306c6395186aa950f750883;
        teleportOracleAuth.removeSigners(feedsToRemove);
        address[] memory feedsToAdd = new address[](4);
        feedsToAdd[0] = 0x0c4FC7D66b7b6c684488c1F218caA18D4082da18;
        feedsToAdd[1] = 0x5C01f0F08E54B85f4CaB8C6a03c9425196fe66DD;
        feedsToAdd[2] = 0xC50DF8b5dcb701aBc0D6d1C7C99E6602171Abbc4;
        feedsToAdd[3] = 0x75FBD0aaCe74Fb05ef0F6C0AC63d26071Eb750c9;
        teleportOracleAuth.addSigners(feedsToAdd);
        
        DssExecLib.setChangelogVersion("1.14.1");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
