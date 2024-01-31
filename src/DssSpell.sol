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

interface RwaLiquidationLike {
    function ilks(bytes32) external view returns (string memory, address, uint48, uint48);
    function init(bytes32, uint256, string calldata, uint48) external;
}

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Always keep office hours off on goerli
    function officeHours() public pure override returns (bool) {
        return false;
    }

    // Approve DAO resolution hash QmVtqkYtx61wEeM5Hb92dGA3TMZ9F1Z5WDSNwcszqxiF1w
    // Note: by the previous convention it should be a comma-separated list of DAO resolutions IPFS hashes
    string public constant dao_resolutions = "QmVtqkYtx61wEeM5Hb92dGA3TMZ9F1Z5WDSNwcszqxiF1w"; // TODO: update  

    // ---------- Rates ----------
    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmVp4mhhbwWGTfbh2BzwQB9eiBrQBKiqcPRZCaAxNUaar6
    //
    // uint256 internal constant X_PCT_RATE = ;

    // ---------- Math ----------
    uint256 internal constant MILLION = 10 ** 6;

    address internal immutable MIP21_LIQUIDATION_ORACLE = DssExecLib.getChangelogAddress("MIP21_LIQUIDATION_ORACLE");

    // Note: Function from https://github.com/makerdao/spells-goerli/blob/cd91b3e0ce234038d2e0ae047261177afac6f03c/archive/2024-01-12-DssSpell/DssSpell.sol#L54
    function _updateDoc(bytes32 ilk, string memory doc) internal {
        ( , address pip, uint48 tau, ) = RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).ilks(ilk);
        require(pip != address(0), "DssSpell/unexisting-rwa-ilk");

        // Init the RwaLiquidationOracle to reset the doc
        RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).init(
            ilk, // ilk to update
            0,   // price ignored if init() has already been called
            doc, // new legal document
            tau  // old tau value
        );
    }

    function actions() public override {
        // ---------- Auction Parameter Updates ----------
        // Forum: https://forum.makerdao.com/t/stability-scope-auction-parameters-changes-1-liquidation-throughput-limit/23508

        // // Increase the WSTETH-A Local Liquidation Limit (ilk.hole) by 15 million DAI from 15 million DAI to 30 million DAI.
        DssExecLib.setIlkMaxLiquidationAmount("WSTETH-A", 30 * MILLION);

        // // Increase the WSTETH-B Local Liquidation Limit (ilk.hole) by 10 million DAI from 10 million DAI to 20 million DAI.
        DssExecLib.setIlkMaxLiquidationAmount("WSTETH-B", 20 * MILLION);

        // // Decrease the WBTC-A Local Liquidation Limit (ilk.hole) by 20 million DAI from 30 million DAI to 10 million DAI.
        DssExecLib.setIlkMaxLiquidationAmount("WBTC-A",   10 * MILLION);

        // // Decrease the WBTC-B Local Liquidation Limit (ilk.hole) by 5 million DAI from 10 million DAI to 5 million DAI.
        DssExecLib.setIlkMaxLiquidationAmount("WBTC-B",   5  * MILLION);

        // // Decrease the WBTC-C Local Liquidation Limit (ilk.hole) by 10 million DAI from 20 million DAI to 10 million DAI.
        DssExecLib.setIlkMaxLiquidationAmount("WBTC-C",   10 * MILLION);

        // Increase the Global Liquidation Limit (Hole) by 50 million DAI from 100 million DAI to 150 million DAI.
        DssExecLib.setMaxTotalDAILiquidationAmount(150 * MILLION);

        // ---------- Push GUSD out of input conduit ----------
        // Forum: TODO
        // Note: Skipping since there is no Jar for GUSD on Goerli

        // ---------- January Delegate Compensation ----------
        // Forum: TODO
        // Note: Skipping since payments are not to be performed on Goerli

        // ---------- Spark - AAVE Revenue Share Payment ----------
        // Forum: TODO
        // Note: Skipping since payments are not to be performed on Goerli

        // ---------- Update Doc Parameter ----------
        // Forum: TODO

        // Update HVBank (RWA009-A) doc to QmPzuLuJ5Xq6k6Hbop1W5s4V9ksvafYoqcW9sU5QRwz5h1
        _updateDoc("RWA009-A", "QmPzuLuJ5Xq6k6Hbop1W5s4V9ksvafYoqcW9sU5QRwz5h1");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
