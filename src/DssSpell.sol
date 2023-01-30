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

pragma solidity 0.8.16;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

interface OptimismGovRelayLike {
    function relay(address target, bytes calldata targetData, uint32 l2gas) external;
}

interface ArbitrumGovRelayLike {
    function relay(
        address target,
        bytes calldata targetData,
        uint256 l1CallValue,
        uint256 maxGas,
        uint256 gasPriceBid,
        uint256 maxSubmissionCost
    ) external payable;
}

interface StarknetGovRelayLike {
    function relay(uint256 spell) external payable;
}

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Turn office hours off
    function officeHours() public pure override returns (bool) {
        return false;
    }

    address immutable internal OPTIMISM_GOV_RELAY = DssExecLib.getChangelogAddress("OPTIMISM_GOV_RELAY");
    address immutable internal ARBITRUM_GOV_RELAY = DssExecLib.getChangelogAddress("ARBITRUM_GOV_RELAY");
    address immutable internal STARKNET_GOV_RELAY = DssExecLib.getChangelogAddress("STARKNET_GOV_RELAY");

    address constant internal OPTIMISM_L2_SPELL = 0xC077Eb64285b40C86B40769e99Eb1E61d682a6B4;
    address constant internal ARBITRUM_L2_SPELL = 0x11Dc6Ed4C08Da38B36709a6C8DBaAC0eAeDD48cA;
    // address constant internal STARKNET_L2_SPELL =

    uint32 public constant OPT_MAX_GAS = 1_000_000; // large value that is under the 1.92m subsidy threshold

    // run ./scripts/get-arb-relay-cost to generate the following 3 constants
    uint256 public constant ARB_MAX_GAS = 38_920;
    uint256 public constant ARB_GAS_PRICE_BID = 100_000_000;
    uint256 public constant ARB_MAX_SUBMISSION_COST = 1e14;
    uint256 public constant ARB_L1_CALL_VALUE = ARB_MAX_SUBMISSION_COST + ARB_MAX_GAS * ARB_GAS_PRICE_BID;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmVp4mhhbwWGTfbh2BzwQB9eiBrQBKiqcPRZCaAxNUaar6
    //
    // uint256 internal constant X_PCT_RATE      = ;
    uint256 internal constant ZERO_PT_TWO_FIVE_PCT_RATE = 1000000000079175551708715274;

    uint256 internal constant MILLION = 10 ** 6;
    // uint256 internal constant RAY  = 10 ** 27;
    uint256 internal constant WAD     = 10 ** 18;

    // ChainLogLike internal immutable CHAINLOG    = ChainLogLike(DssExecLib.getChangelogAddress("CHANGELOG"));

    address internal immutable FLASH_KILLER     = DssExecLib.getChangelogAddress("FLASH_KILLER");
    address internal immutable MCD_FLASH        = DssExecLib.getChangelogAddress("MCD_FLASH");
    address internal immutable MCD_FLASH_LEGACY = DssExecLib.getChangelogAddress("MCD_FLASH_LEGACY");

    address internal immutable MCD_PSM_PAX_A    = DssExecLib.getChangelogAddress("MCD_PSM_PAX_A");
    address internal immutable MCD_PSM_GUSD_A   = DssExecLib.getChangelogAddress("MCD_PSM_GUSD_A");

    function actions() public override {
        // ------------------ Pause Optimism Goerli L2DaiTeleportGateway -----------------
        // Forum: https://forum.makerdao.com/t/community-notice-pecu-to-redeploy-teleport-l2-gateways/19550
        // L2 Spell to execute via OPTIMISM_GOV_RELAY:
        // https://goerli-optimism.etherscan.io/address/0xC077Eb64285b40C86B40769e99Eb1E61d682a6B4#code
        OptimismGovRelayLike(OPTIMISM_GOV_RELAY).relay(
            OPTIMISM_L2_SPELL,
            abi.encodeWithSignature("execute()"),
            OPT_MAX_GAS
        );

        // ------------------ Pause Arbitrum Goerli L2DaiTeleportGateway -----------------
        // Forum: https://forum.makerdao.com/t/community-notice-pecu-to-redeploy-teleport-l2-gateways/19550
        // L2 Spell to execute via ARBITRUM_GOV_RELAY:
        // https://goerli.arbiscan.io/address/0x11dc6ed4c08da38b36709a6c8dbaac0eaedd48ca#code
        // Note: ARBITRUM_GOV_RELAY must have been pre-funded with at least ARB_L1_CALL_VALUE worth of Ether
        ArbitrumGovRelayLike(ARBITRUM_GOV_RELAY).relay(
            ARBITRUM_L2_SPELL,
            abi.encodeWithSignature("execute()"),
            ARB_L1_CALL_VALUE,
            ARB_MAX_GAS,
            ARB_GAS_PRICE_BID,
            ARB_MAX_SUBMISSION_COST
        );
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
