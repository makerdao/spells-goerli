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

interface GemLike {
    function allowance(address, address) external view returns (uint256);
    function approve(address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
}

interface RwaLiquidationLike {
    function ilks(bytes32) external view returns (string memory, address, uint48, uint48);
    function init(bytes32, uint256, string calldata, uint48) external;
    function bump(bytes32 ilk, uint256 val) external;
}

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Turn office hours off
    function officeHours() public pure override returns (bool) {
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
    // uint256 internal constant X_PCT_RATE      = ;

    uint256 internal constant MILLION = 10 ** 6;

    uint256 internal constant WAD     = 10 ** 18;

    // MAINNET SPELL ONLY
    
    GemLike  internal immutable MKR                     = GemLike(DssExecLib.mkr());

    address internal immutable MIP21_LIQUIDATION_ORACLE = DssExecLib.getChangelogAddress("MIP21_LIQUIDATION_ORACLE");

    address constant internal LBSBLOCKCHAIN_WALLET      = 0xB83b3e9C8E3393889Afb272D354A7a3Bd1Fbcf5C;
    address constant internal CONSENSYS_WALLET          = 0xE78658A8acfE982Fde841abb008e57e6545e38b3;
    address constant internal SES_WALLET                = 0x87AcDD9208f73bFc9207e1f6F0fDE906bcA95cc6;
    address constant internal CES_WALLET                = 0x25307aB59Cd5d8b4E2C01218262Ddf6a89Ff86da;
    address constant internal PHOENIX_LABS_WALLET       = 0xD9847E6b1314f0327F320E43B51ca0AaAD6FF509; // NOTE: This address is pending confirmation from GovAlpha
    
    // TODO Rename this as appropriate (This has to go outside of the actions function)
    // Monetalis Update - Excess Funds Declaration
    // Poll:  https://vote.makerdao.com/polling/QmfZ2nxw#poll-details
    // Forum: https://forum.makerdao.com/t/request-to-poll-return-excess-mip65-funds-to-surplus-buffer/20115
    string constant public MIP65 = "HASH_GOES_HERE";

    function actions() public override {

        /* // Uncleared Delegate Compensation (MAINNET SPELL ONLY)
        // Poll:  https://vote.makerdao.com/polling/Qmd2W3Q4#poll-details
        // Forum: https://forum.makerdao.com/t/mip4c2-sp29-amend-mip61-to-tighten-up-recognized-delegate-participation-metrics/18696

        // London Business School Blockchain - 3126 DAI - 0xB83b3e9C8E3393889Afb272D354A7a3Bd1Fbcf5C
        DssExecLib.sendPaymentFromSurplusBuffer(LBSBLOCKCHAIN_WALLET,   3_126);
        // ConsenSys                         -  181 DAI - 0xE78658A8acfE982Fde841abb008e57e6545e38b3
        DssExecLib.sendPaymentFromSurplusBuffer(CONSENSYS_WALLET,         181); */


        /* // SES-001 MKR Transfer (MAINNET SPELL ONLY)
        // Poll:  https://vote.makerdao.com/polling/QmSmhV7z#poll-details
        // Forum: https://forum.makerdao.com/t/mip40c3-sp17-sustainable-ecosystem-scaling-core-unit-mkr-budget-ses-001/8043
        
        MKR.transfer(SES_WALLET, 229.78 ether);  // NOTE: 'ether' is a keyword helper, only MKR is transferred here */

        /* // CES-001 MKR Transfer (MAINNET SPELL ONLY)
        // Poll:  https://vote.makerdao.com/polling/QmbNVQ1E#poll-details
        // Forum: https://forum.makerdao.com/t/request-to-poll-one-time-mkr-distribution-to-correct-ces-001-incentive-program-shortfall/19326

        // NOTE: The 77.34 MKR figure needs to be confirmed by GovAlpha and the calculation confirmed
        MKR.transfer(CES_WALLET, 77.34 ether);  // NOTE: 'ether' is a keyword helper, only MKR is transferred here */


        /* // Phoenix Labs SPF DAI Funding (MAINNET SPELL ONLY)
        // Poll:  https://vote.makerdao.com/polling/QmYBegVf#poll-details
        // Forum: https://forum.makerdao.com/t/mip55c3-sp15-phoenix-labs-initial-funding-spf/19733

        DssExecLib.sendPaymentFromSurplusBuffer(PHOENIX_LABS_WALLET, 50_000); */


        // RETH-A Dust Adjustment from 15,000 DAI to 7,500 DAI
        // Poll:  https://vote.makerdao.com/polling/QmcLGa49#poll-details
        // Forum: https://forum.makerdao.com/t/adjusting-reth-a-dust-parameter-march-2023/20021

        DssExecLib.setIlkMinVaultAmount("RETH-A", 7_500);


        // Monetalis Update - Remove DC-IAM from RWA-007
        // Poll:  https://vote.makerdao.com/polling/QmRJSSGW#poll-details
        // Forum: https://forum.makerdao.com/t/request-to-poll-increase-debt-ceiling-for-mip65-by-750m-to-1-250m/20119
        
        DssExecLib.removeIlkFromAutoLine("RWA007-A");

        // Monetalis Update - Increase the MIP65 (RWA007-A) Debt Ceiling by 750M DAI from 500M DAI to 1,250M DAI
        // Poll:  https://vote.makerdao.com/polling/QmNTSr9j#poll-details
        // Forum: https://forum.makerdao.com/t/request-to-poll-increase-debt-ceiling-for-mip65-by-750m-to-1-250m/20119

        // Increase RWA007-A line by 750M DAI from 500M DAI to 1,250M DAI
        DssExecLib.increaseIlkDebtCeiling(
            "RWA007-A", 
            750 * MILLION,  // DC to 1,250M less existing 500M
            true            // Increase global Line
        );

        // Bump MIP21 Oracle's `val` to 1,250M as WAD (No need to calculate anything since the rate is 0%)
        RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).bump(
            "RWA007-A",
             1_250 * MILLION * WAD
        );

        // Update the RWA007-A `spot` value in Vat
        DssExecLib.updateCollateralPrice("RWA007-A");


    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
