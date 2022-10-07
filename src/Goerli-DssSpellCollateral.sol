// SPDX-FileCopyrightText: © 2022 Dai Foundation <www.daifoundation.org>
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

import "dss-exec-lib/DssExecLib.sol";
import "dss-interfaces/dss/GemJoinAbstract.sol";
import "dss-interfaces/dss/IlkRegistryAbstract.sol";
import "dss-interfaces/ERC/GemAbstract.sol";

interface RwaLiquidationLike {
    function ilks(bytes32) external returns (string memory, address, uint48, uint48);
    function init(bytes32, uint256, string calldata, uint48) external;
}

interface RwaUrnLike {
    function vat() external view returns(address);
    function jug() external view returns(address);
    function gemJoin() external view returns(address);
    function daiJoin() external view returns(address);
    function outputConduit() external view returns(address);
    function hope(address) external;
}

interface RwaJarLike {
    function chainlog() external view returns(address);
    function dai() external view returns(address);
    function daiJoin() external view returns(address);
}

interface RwaOutputConduitLike {
    function dai() external view returns(address);
    function gem() external view returns(address);
    function psm() external view returns(address);
    function file(bytes32 what, address data) external;
    function hope(address) external;
    function mate(address) external;
    function kiss(address) external;
}

interface RwaInputConduitLike {
    function dai() external view returns(address);
    function gem() external view returns(address);
    function psm() external view returns(address);
    function to() external view returns(address);
    function mate(address usr) external;
    function file(bytes32 what, address data) external;
}

contract DssSpellCollateralAction {
    // --- Rates ---
    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmVp4mhhbwWGTfbh2BzwQB9eiBrQBKiqcPRZCaAxNUaar6
    //

    // --- Math ---
    uint256 internal constant WAD = 10**18;


    // Change clip parameters
    function collateralAuctionParameterChanges(
        IlkRegistryAbstract REGISTRY,
        address MIP21_LIQUIDATION_ORACLE,
        address MCD_VAT,
        address MCD_JUG,
        address MCD_SPOT,
        address MCD_JOIN_DAI,
        address MCD_PSM_USDC_A
    ) internal {
        
        // Auction Price Multiplier (buf) changes
       
        // Max Auction Drawdown (cusp) changes
     
        // Max Auction Duration (tail) changes
        // NOTE needs conf from GovAlpha

        // ilk.hole changes

        // tip Changes
        
    }

    // NOTE: Awaiting confirmation: MOMC Parameter Changes - vote ends Thursday

    // Skip on Goerli - Delegate Compensation - September 2022

    function systemParameterChanges(
        IlkRegistryAbstract REGISTRY,
        address MIP21_LIQUIDATION_ORACLE,
        address MCD_VAT,
        address MCD_JUG,
        address MCD_SPOT,
        address MCD_JOIN_DAI,
        address MCD_PSM_USDC_A
    ) internal {

        // System hole Change

    }

    function onboardNewCollaterals() internal {
        IlkRegistryAbstract REGISTRY     = IlkRegistryAbstract(DssExecLib.reg());
        address MIP21_LIQUIDATION_ORACLE = DssExecLib.getChangelogAddress("MIP21_LIQUIDATION_ORACLE");
        address MCD_PSM_USDC_A           = DssExecLib.getChangelogAddress("MCD_PSM_USDC_A");
        address MCD_VAT                  = DssExecLib.vat();
        address MCD_JUG                  = DssExecLib.jug();
        address MCD_SPOT                 = DssExecLib.spotter();
        address MCD_JOIN_DAI             = DssExecLib.daiJoin();

        // --------------------------- System parameter changes ---------------------------
        // Parameter changes : https://vote.makerdao.com/polling/QmREbu1j
        // Change clip parameters
        collateralAuctionParameterChanges(REGISTRY, MIP21_LIQUIDATION_ORACLE, MCD_VAT, MCD_JUG, MCD_SPOT, MCD_JOIN_DAI, MCD_PSM_USDC_A);(REGISTRY, MIP21_LIQUIDATION_ORACLE, MCD_VAT, MCD_JUG, MCD_SPOT, MCD_JOIN_DAI, MCD_PSM_USDC_A);
        // Change system parameters
        systemParameterChanges(REGISTRY, MIP21_LIQUIDATION_ORACLE, MCD_VAT, MCD_JUG, MCD_SPOT, MCD_JOIN_DAI, MCD_PSM_USDC_A);(REGISTRY, MIP21_LIQUIDATION_ORACLE, MCD_VAT, MCD_JUG, MCD_SPOT, MCD_JOIN_DAI, MCD_PSM_USDC_A);
    }
}
