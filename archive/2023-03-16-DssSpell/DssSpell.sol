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

interface VatLike {
    function Line() external view returns (uint256);
    function file(bytes32, uint256) external;
    function ilks(bytes32) external returns (uint256 Art, uint256 rate, uint256 spot, uint256 line, uint256 dust);
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
    uint256 internal constant BILLION = 10 ** 9;

    uint256 internal constant WAD     = 10 ** 18;

    uint256 internal constant PSM_HUNDRED_BASIS_POINTS = 100 * WAD / 10000;

    address internal immutable MCD_PSM_USDC_A = DssExecLib.getChangelogAddress("MCD_PSM_USDC_A");
    address internal immutable MCD_PSM_PAX_A  = DssExecLib.getChangelogAddress("MCD_PSM_PAX_A");

    function actions() public override {
        // Emergency Proposal: Risk and Governance Parameter Changes (11 March 2023)
        // https://forum.makerdao.com/t/emergency-proposal-risk-and-governance-parameter-changes-11-march-2023/20125

        // Reduce UNIV2USDCETH-A, UNIV2DAIUSDC-A, GUNIV3DAIUSDC1-A and GUNIV3DAIUSDC2-A Debt Ceilings to 0
        uint256 line;
        uint256 lineReduction;
        VatLike vat = VatLike(DssExecLib.vat());

        (,,,line,) = vat.ilks("UNIV2USDCETH-A");
        lineReduction += line;
        DssExecLib.removeIlkFromAutoLine("UNIV2USDCETH-A");
        DssExecLib.setIlkDebtCeiling("UNIV2USDCETH-A", 0);

        (,,,line,) = vat.ilks("UNIV2DAIUSDC-A");
        lineReduction += line;
        DssExecLib.removeIlkFromAutoLine("UNIV2DAIUSDC-A");
        DssExecLib.setIlkDebtCeiling("UNIV2DAIUSDC-A", 0);

        (,,,line,) = vat.ilks("GUNIV3DAIUSDC1-A");
        lineReduction += line;
        DssExecLib.removeIlkFromAutoLine("GUNIV3DAIUSDC1-A");
        DssExecLib.setIlkDebtCeiling("GUNIV3DAIUSDC1-A", 0);

        (,,,line,) = vat.ilks("GUNIV3DAIUSDC2-A");
        lineReduction += line;
        DssExecLib.removeIlkFromAutoLine("GUNIV3DAIUSDC2-A");
        DssExecLib.setIlkDebtCeiling("GUNIV3DAIUSDC2-A", 0);

        // Decrease Global Debt Ceiling in accordance with Offboarded Ilks
        vat.file("Line", vat.Line() - lineReduction);

        // Set DC-IAM module for PSM-USDC-A, PSM-PAX-A and PSM-GUSD-A
        DssExecLib.setIlkAutoLineParameters("PSM-USDC-A", 10 * BILLION, 250 * MILLION, 24 hours);
        DssExecLib.setIlkAutoLineParameters("PSM-PAX-A", 1 * BILLION, 250 * MILLION, 24 hours);
        DssExecLib.setIlkAutoLineParameters("PSM-GUSD-A", 500 * MILLION, 10 * MILLION, 24 hours);

        // Increase PSM-USDC-A tin from 0% to 1%
        DssExecLib.setValue(MCD_PSM_USDC_A, "tin", PSM_HUNDRED_BASIS_POINTS);

        // Reduce PSM-USDP-A tin to 0%
        DssExecLib.setValue(MCD_PSM_PAX_A, "tin", 0);

        // Increase PSM-USDP-A tout to 1%
        DssExecLib.setValue(MCD_PSM_PAX_A, "tout", PSM_HUNDRED_BASIS_POINTS);
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
