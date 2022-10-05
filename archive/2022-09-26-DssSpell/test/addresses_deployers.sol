// SPDX-FileCopyrightText: © 2021 Dai Foundation <www.daifoundation.org>
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

pragma solidity ^0.6.12;

contract Deployers {

    address[] public addr;

    // Skip Ward Deployers see Goerli-DssSpell.t.base.sol#skipWards(address,address)
    address public constant PE_CURRENT  = 0xDa0c0De020F80d43dde58c2653aa73d28Df1fBe1;
    address public constant ORACLES     = 0x1f42e41A34B71606FcC60b4e624243b365D99745;

    // Known Team Deployers
    address public constant PE_01       = 0xda0fab060e6cc7b1C0AA105d29Bd50D71f036711;
    address public constant PE_02       = 0xDA0FaB0700A4389F6E6679aBAb1692B4601ce9bf;
    address public constant PE_03       = 0xdA0C0de01d90A5933692Edf03c7cE946C7c50445;
    address public constant PE_04       = 0xdB33dFD3D61308C33C63209845DaD3e6bfb2c674;
    address public constant PE_05       = 0xDA01018eA05D98aBb66cb21a85d6019a311570eE;
    address public constant PE_06       = 0xDA0111100cb6080b43926253AB88bE719C60Be13;
    address public constant CES         = 0x9956fca5a8994737f124c481cEDC6BB3dc5BF010;
    address public constant STARKNET_01 = 0x8aa7c51A6D380F4d9E273adD4298D913416031Ec;
    address public constant STARKNET_02 = 0x38F8e3b67FA8329FE4BaA1775e5480807f78887B;

    constructor() public {
        addr = [
            PE_01,
            PE_02,
            PE_03,
            PE_04,
            PE_05,
            PE_06,
            PE_CURRENT,
            ORACLES,
            STARKNET_01,
            STARKNET_02,
            CES
        ];
    }

    function count() external view returns (uint256) {
        return addr.length;
    }
}
