// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2021 Dai Foundation
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

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

interface DssVestLike {
    function create(address, uint256, uint256, uint256, uint256, address) external returns (uint256);
    function restrict(uint256) external;
}

contract DssSpellAction is DssAction {

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/TODO -q -O - 2>/dev/null)"
    string public constant override description = "Goerli Spell";

    // Gelato Keeper Testing Contracts
    address constant TOP_UP1 = 0xB77827FabA70185D1EaD053648f665d2C41f7906;
    address constant TOP_UP2 = 0xbe77Cd403Be3F2C7EEBC3427360D3f9e5d528F43;

    // Math
    uint256 constant MILLION  = 10 ** 6;

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {

        // Adjusting Auction Parameters for ETH-A, ETH-B, ETH-C, and WBTC-A
        // https://vote.makerdao.com/polling/QmfGk3Dm?network=mainnet#poll-detail

        // Decrease the Auction Price Multiplier (buf) for ETH-A, ETH-C, and WBTC-A vaults from 1.3 to 1.2
        DssExecLib.setStartingPriceMultiplicativeFactor("ETH-A",  12000);
        DssExecLib.setStartingPriceMultiplicativeFactor("ETH-C",  12000);
        DssExecLib.setStartingPriceMultiplicativeFactor("WBTC-A", 12000);

        // Increase the Local Liquidation Limit (ilk.hole)
        DssExecLib.setIlkMaxLiquidationAmount("ETH-A",  40 * MILLION); //  from 30 Million DAI to 40 Million DAI
        DssExecLib.setIlkMaxLiquidationAmount("ETH-B",  25 * MILLION); //  from 15 Million DAI to 25 Million DAI
        DssExecLib.setIlkMaxLiquidationAmount("ETH-C",  30 * MILLION); //  from 20 Million DAI to 30 Million DAI
        DssExecLib.setIlkMaxLiquidationAmount("WBTC-A", 25 * MILLION); //  from 15 Million DAI to 25 Million DAI

        // ----------- Housekeeping -----------
        // Increase Global Debt Ceiling by 500 Million (line_offset)
        DssExecLib.increaseGlobalDebtCeiling(500 * MILLION);
        
        // Add test DAI streams for Gelato Keeper Network at 10 DAI / day
        address MCD_VEST_DAI = DssExecLib.getChangelogAddress("MCD_VEST_DAI");
        uint256 duration = 20 * 365 days;
        DssVestLike(MCD_VEST_DAI).restrict(
            DssVestLike(MCD_VEST_DAI).create(TOP_UP1, 10.00 * 10**18 * duration / 1 days, block.timestamp, duration, 0, address(0))
        );
        DssVestLike(MCD_VEST_DAI).restrict(
            DssVestLike(MCD_VEST_DAI).create(TOP_UP2, 10.00 * 10**18 * duration / 1 days, block.timestamp, duration, 0, address(0))
        );
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
