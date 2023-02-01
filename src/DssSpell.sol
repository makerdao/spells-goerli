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

interface StarknetEscrowLike {
    function approve(address token, address spender, uint256 value) external;
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

    address immutable internal DAI = DssExecLib.getChangelogAddress("MCD_DAI");
    address immutable internal STARKNET_ESCROW = DssExecLib.getChangelogAddress("STARKNET_ESCROW");
    address immutable internal STARKNET_DAI_BRIDGE_LEGACY = DssExecLib.getChangelogAddress("STARKNET_DAI_BRIDGE_LEGACY");

    address constant internal OPTIMISM_L2_SPELL = 0xC077Eb64285b40C86B40769e99Eb1E61d682a6B4;
    address constant internal ARBITRUM_L2_SPELL = 0x11Dc6Ed4C08Da38B36709a6C8DBaAC0eAeDD48cA;
    uint256 constant internal STARKNET_L2_SPELL = 0x00a052591661d7e249b46a1084c63b14dae6aa8b1a56ab3f7df8c8add1c374b1;

    // run ./scripts/get-opt-relay-cost.sh to help determine Optimism relay param
    uint32 public constant OPT_MAX_GAS = 100_000; // = 52_587 gas (estimated L2 execution cost) + margin

    // run ./scripts/get-arb-relay-cost.sh to help determine Arbitrum relay params
    uint256 public constant ARB_MAX_GAS = 100_000; // = 38_920 gas (estimated L1 calldata + L2 execution cost) + margin (to account for surge in L1 basefee)
    uint256 public constant ARB_GAS_PRICE_BID = 1_000_000_000; // = 0.1 gwei + 0.9 gwei margin
    uint256 public constant ARB_MAX_SUBMISSION_COST = 1e14; // = ~0.05-0.20 * 10^14 rounded up to 1*10^14
    uint256 public constant ARB_L1_CALL_VALUE = ARB_MAX_SUBMISSION_COST + ARB_MAX_GAS * ARB_GAS_PRICE_BID;

    // see: https://github.com/makerdao/starknet-spells-goerli/tree/teleport-spell#estimate-l1-l2-fee
    uint256 public constant STA_GAS_USAGE_ESTIMATION = 28460;

    // 500gwei, ~upper bound of monthly avg gas price in `21-`22,
    // ~100x max monthly median gas price in `21-`22
    // https://explorer.bitquery.io/ethereum/gas?from=2021-01-01&till=2023-01-31
    uint256 public constant STA_GAS_PRICE = 500000000000;
    uint256 public constant STA_L1_CALL_VALUE = STA_GAS_USAGE_ESTIMATION * STA_GAS_PRICE;

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

    // uint256 internal constant MILLION = 10 ** 6;
    // uint256 internal constant RAY     = 10 ** 27;
    // uint256 internal constant WAD     = 10 ** 18;

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

        // ------------------ Pause Starknet Goerli L2DaiTeleportGateway -----------------
        // Forum: https://forum.makerdao.com/t/community-notice-pecu-to-redeploy-teleport-l2-gateways/19550
        // L2 Spell to execute via STARKNET_GOV_RELAY:
        // src: https://github.com/makerdao/starknet-spells-goerli/blob/b7ca995cf1d266aa2382d85e35a86b4fae52aa15/src/spell.cairo
        // contract: https://testnet.starkscan.co/class/0x00a052591661d7e249b46a1084c63b14dae6aa8b1a56ab3f7df8c8add1c374b1#overview
        StarknetGovRelayLike(STARKNET_GOV_RELAY).relay{value: STA_L1_CALL_VALUE}(STARKNET_L2_SPELL);

        // disallow legacy bridge on escrow
        StarknetEscrowLike(STARKNET_ESCROW).approve(DAI, STARKNET_DAI_BRIDGE_LEGACY, 0);

        //
        // The following code is a placeholder for mainnet
        //

        // Tech-Ops DAI Transfer
        // https://vote.makerdao.com/polling/QmUMnuGb
        // TODO: add code in mainnet

        // GovComms offboarding
        // https://vote.makerdao.com/polling/QmV9iktK
        // https://forum.makerdao.com/t/mip39c3-sp7-core-unit-offboarding-com-001/19068/65
        // TODO: add code in mainnet

        // SPF Funding: Expanded SF-001 Domain Work
        // https://vote.makerdao.com/polling/QmTjgcHY
        // TODO: add code in mainnet
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
