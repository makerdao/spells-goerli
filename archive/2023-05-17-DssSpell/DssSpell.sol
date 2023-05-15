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

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Always keep office hours off on goerli
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
    uint256 internal constant RAY       = 10 ** 27;

    address internal immutable MCD_SPOT = DssExecLib.spotter();

    function actions() public override {
        // --------- Collateral Offboardings ---------
        // Poll: https://vote.makerdao.com/polling/QmPwHhLT#poll-detail
        // Forum: https://forum.makerdao.com/t/decentralized-collateral-scope-parameter-changes-1-april-2023/20302

        // Set Liquidation Penalty (chop) to 0%.
        DssExecLib.setIlkLiquidationPenalty("YFI-A", 0);
        // Set Flat Kick Incentive (tip) to 0.
        DssExecLib.setKeeperIncentiveFlatRate("YFI-A", 0);
        // Set Proportional Kick Incentive (chip) to 0.
        DssExecLib.setKeeperIncentivePercent("YFI-A", 0);
        // Set Liquidation Ratio (mat) to 10,000%.
        // We are using low level methods because DssExecLib only allows setting `mat < 1000%`: https://github.com/makerdao/dss-exec-lib/blob/69b658f35d8618272cd139dfc18c5713caf6b96b/src/DssExecLib.sol#L717
        DssExecLib.setValue(MCD_SPOT, "YFI-A", "mat", 100 * RAY);
        // Update spotter price
        DssExecLib.updateCollateralPrice("YFI-A");

        // Set Liquidation Penalty (chop) to 0%.
        DssExecLib.setIlkLiquidationPenalty("LINK-A", 0);
        // Set Flat Kick Incentive (tip) to 0.
        DssExecLib.setKeeperIncentiveFlatRate("LINK-A", 0);
        // Set Proportional Kick Incentive (chip) to 0.
        DssExecLib.setKeeperIncentivePercent("LINK-A", 0);
        // Set Liquidation Ratio (mat) to 10,000%.
        // We are using low level methods because DssExecLib only allows setting `mat < 1000%`: https://github.com/makerdao/dss-exec-lib/blob/69b658f35d8618272cd139dfc18c5713caf6b96b/src/DssExecLib.sol#L717
        DssExecLib.setValue(MCD_SPOT, "LINK-A", "mat", 100 * RAY);
        // Update spotter price
        DssExecLib.updateCollateralPrice("LINK-A");

        // Set Liquidation Penalty (chop) to 0%.
        DssExecLib.setIlkLiquidationPenalty("MATIC-A", 0);
        // Set Flat Kick Incentive (tip) to 0.
        DssExecLib.setKeeperIncentiveFlatRate("MATIC-A", 0);
        // Set Proportional Kick Incentive (chip) to 0.
        DssExecLib.setKeeperIncentivePercent("MATIC-A", 0);
        // Set Liquidation Ratio (mat) to 10,000%.
        // We are using low level methods because DssExecLib only allows setting `mat < 1000%`: https://github.com/makerdao/dss-exec-lib/blob/69b658f35d8618272cd139dfc18c5713caf6b96b/src/DssExecLib.sol#L717
        DssExecLib.setValue(MCD_SPOT, "MATIC-A", "mat", 100 * RAY);
        // Update spotter price
        DssExecLib.updateCollateralPrice("MATIC-A");

        // Set Liquidation Penalty (chop) to 0%.
        DssExecLib.setIlkLiquidationPenalty("UNIV2USDCETH-A", 0);
        // Set Flat Kick Incentive (tip) to 0.
        DssExecLib.setKeeperIncentiveFlatRate("UNIV2USDCETH-A", 0);
        // Set Proportional Kick Incentive (chip) to 0.
        DssExecLib.setKeeperIncentivePercent("UNIV2USDCETH-A", 0);
        // Set Liquidation Ratio (mat) to 10,000%.
        // We are using low level methods because DssExecLib only allows setting `mat < 1000%`: https://github.com/makerdao/dss-exec-lib/blob/69b658f35d8618272cd139dfc18c5713caf6b96b/src/DssExecLib.sol#L717
        DssExecLib.setValue(MCD_SPOT, "UNIV2USDCETH-A", "mat", 100 * RAY);
        // Update spotter price
        DssExecLib.updateCollateralPrice("UNIV2USDCETH-A");

        // --------- Delegate Compensation MKR Transfers ---------
        // Poll: N/A
        // Forum: https://forum.makerdao.com/t/constitutional-delegate-compensation-april-2023/20804
        // NOTE: ignore in goerli
        // 0xDefensor                  - 23.8 MKR - 0x9542b441d65B6BF4dDdd3d4D2a66D8dCB9EE07a9
        // BONAPUBLICA                 - 23.8 MKR - 0x167c1a762B08D7e78dbF8f24e5C3f1Ab415021D3
        // Frontier Research           - 23.8 MKR - 0xa2d55b89654079987cf3985aeff5a7bd44da15a8
        // GFX Labs                    - 23.8 MKR - 0x9b68c14e936104e9a7a24c712beecdc220002984
        // QGov                        - 23.8 MKR - 0xB0524D8707F76c681901b782372EbeD2d4bA28a6
        // TRUE NAME                   - 23.8 MKR - 0x612f7924c367575a0edf21333d96b15f1b345a5d
        // vigilant                    - 23.8 MKR - 0x2474937cB55500601BCCE9f4cb0A0A72Dc226F61
        // CodeKnight                  - 5.95 MKR - 0xf6006d4cF95d6CB2CD1E24AC215D5BF3bca81e7D
        // Flip Flop Flap Delegate LLC - 5.95 MKR - 0x3d9751EFd857662f2B007A881e05CfD1D7833484
        // PBG                         - 5.95 MKR - 0x8D4df847dB7FfE0B46AF084fE031F7691C6478c2
        // UPMaker                     - 5.95 MKR - 0xbb819df169670dc71a16f58f55956fe642cc6bcd

        // --------- DAI Budget Streams ---------
        // Poll: https://vote.makerdao.com/polling/Qmbndmkr#poll-detail
        // Forum: https://forum.makerdao.com/t/mip101-the-maker-constitution/19621
        // NOTE: ignore in goerli

        // Mip: https://mips.makerdao.com/mips/details/MIP107#6-1-governance-security-engineering-budget
        // Governance Security Engineering Budget | 2023-05-01 00:00:00 to 2024-04-30 23:59:59 | 2,200,000 DAI | 0x569fAD613887ddd8c1815b56A00005BCA7FDa9C0

        // Mip: https://mips.makerdao.com/mips/details/MIP107#7-1-multichain-engineering-budget
        // Multichain Engineering Budget          | 2023-05-01 00:00:00 to 2024-04-30 23:59:59 | 2,300,000 DAI | 0x868B44e8191A2574334deB8E7efA38910df941FA

        // --------- Data Insights MKR Transfer ---------
        // Mip: https://mips.makerdao.com/mips/details/MIP40c3SP64#mkr-vesting
        // NOTE: ignore in goerli
        // DIN-001 - 103.16 MKR - 0x7327Aed0Ddf75391098e8753512D8aEc8D740a1F
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
