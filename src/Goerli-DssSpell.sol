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
pragma experimental ABIEncoderV2;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

import { DssSpellCollateralAction } from "./Goerli-DssSpellCollateral.sol";

interface StarknetBridgeLike {
    function close() external;
}

interface StarknetGovRelayLike {
    function relay(uint256 spell) external;
}

interface StarknetEscrowLike {
    function approve(address token, address spender, uint256 value) external;
}


contract DssSpellAction is DssAction, DssSpellCollateralAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Turn office hours off
    function officeHours() public override returns (bool) {
        return false;
    }

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmVp4mhhbwWGTfbh2BzwQB9eiBrQBKiqcPRZCaAxNUaar6
    //

    // --- Rates ---

    // --- Math ---
    // uint256 internal constant WAD = 10 ** 18;

    function actions() public override {
        // ---------------------------------------------------------------------
        // rETH Onboarding
        // https://vote.makerdao.com/polling/QmfMswF2#poll-detail
        // https://vote.makerdao.com/polling/QmS7dBuQ#poll-detail
        // https://forum.makerdao.com/t/reth-collateral-onboarding-risk-evaluation/15286

        // Forum
        // https://forum.makerdao.com/t/reth-collateral-onboarding-risk-evaluation/15286

        // Liquidation Parameters
        // Limits
        // Incentives

        // ---------------------------------------------------------------------
        // Starknet Bridge Fee Upgrade
        // TBD

        // ---------------------------------------------------------------------
        // Includes changes from the DssSpellCollateralAction
        onboardCollaterals();
        // updateCollaterals();
        // offboardCollaterals();

        // Starknet Bridge Upgrade
        // https://github.com/makerdao/starknet-dai-bridge#upgrades

        // close current bridge
        address currentStarknetDAIBridge = DssExecLib.getChangelogAddress("STARKNET_DAI_BRIDGE");
        StarknetBridgeLike(currentStarknetDAIBridge).close();

        // approve new bridge
        address NEW_STARKNET_DAI_BRIDGE = 0xaB00D7EE6cFE37cCCAd006cEC4Db6253D7ED3a22;
        address starknetEscrow = DssExecLib.getChangelogAddress("STARKNET_ESCROW");
        address dai = DssExecLib.getChangelogAddress("MCD_DAI");
        StarknetEscrowLike(starknetEscrow).approve(dai, NEW_STARKNET_DAI_BRIDGE, type(uint).max);

        // relay l2 spell
        // See: https://goerli.voyager.online/contract/0x04363a4e51a9d2eaccef7a7ef5f0c8872f8183db2179802c0907f547c87864fc#code
        address starknetGovRelay = DssExecLib.getChangelogAddress("STARKNET_GOV_RELAY");
        uint256 L2_FEE_SPELL = 0x04363a4e51a9d2eaccef7a7ef5f0c8872f8183db2179802c0907f547c87864fc;
        StarknetGovRelayLike(starknetGovRelay).relay(L2_FEE_SPELL);

        // ChangeLog
        DssExecLib.setChangelogAddress("STARKNET_DAI_BRIDGE", NEW_STARKNET_DAI_BRIDGE);
        DssExecLib.setChangelogAddress("STARKNET_DAI_BRIDGE_LEGACY", currentStarknetDAIBridge);

        // Bump changelog version
        DssExecLib.setChangelogVersion("1.14.3");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
