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

pragma solidity 0.8.16;

contract Deployers {

    address[] public addr;

    // Skip Ward Deployers see DssSpell.t.base.sol#skipWards(address,address)
    address public constant PE_CURRENT  = 0xa22A61c233d7242728b4255420063c92fc1AEBb9; // PE_09
    address public constant ORACLES_1   = 0x1f42e41A34B71606FcC60b4e624243b365D99745;
    address public constant ORACLES_2   = 0x39aBD7819E5632Fa06D2ECBba45Dca5c90687EE3;

    // Known Team Deployers
    address public constant PE_01         = 0xda0fab060e6cc7b1C0AA105d29Bd50D71f036711;
    address public constant PE_02         = 0xDA0FaB0700A4389F6E6679aBAb1692B4601ce9bf;
    address public constant PE_03         = 0xdA0C0de01d90A5933692Edf03c7cE946C7c50445;
    address public constant PE_04         = 0xdB33dFD3D61308C33C63209845DaD3e6bfb2c674;
    address public constant PE_05         = 0xDA01018eA05D98aBb66cb21a85d6019a311570eE;
    address public constant PE_06         = 0xDA0111100cb6080b43926253AB88bE719C60Be13;
    address public constant PE_07         = 0xDa0c0De020F80d43dde58c2653aa73d28Df1fBe1;
    address public constant PE_08         = 0xC1E6d8136441FC66612Df3584007f7CB68765e5D;
    address public constant PE_09         = 0xa22A61c233d7242728b4255420063c92fc1AEBb9;
    address public constant PE_10         = 0x92723e0bF280942B98bf2d1e832Bde9A3Bd2F2c2;
    address public constant CES_01        = 0x9956fca5a8994737f124c481cEDC6BB3dc5BF010;
    address public constant CES_02        = 0xc0b362cbb0117Ec6A4b589f744d4dECb2768A2eB;
    address public constant CES_03        = 0xb27B6fa77D7FBf3C1BD34B0f7DA59b39D3DB0f7e;
    address public constant CES_04        = 0x3ec4699bEc79F8FF862C220Ef0a718689A1d09f4;
    address public constant STARKNET_01   = 0x8aa7c51A6D380F4d9E273adD4298D913416031Ec;
    address public constant STARKNET_02   = 0x38F8e3b67FA8329FE4BaA1775e5480807f78887B;
    address public constant CENTRIFUGE_01 = 0x9956fca5a8994737f124c481cEDC6BB3dc5BF010;
    address public constant CENTRIFUGE_02 = 0x0A735602a357802f553113F5831FE2fbf2F0E2e0;
    address public constant SIDESTREAM_01 = 0x47f1aaC8c1BDD49B0c2438c1754518695E9f08d3;

    constructor() {
        addr = [
            PE_CURRENT,
            ORACLES_1,
            ORACLES_2,
            PE_01,
            PE_02,
            PE_03,
            PE_04,
            PE_05,
            PE_06,
            PE_07,
            PE_08,
            PE_09,
            CES_01,
            CES_02,
            CES_03,
            CES_04,
            STARKNET_01,
            STARKNET_02,
            CENTRIFUGE_01,
            CENTRIFUGE_02,
            SIDESTREAM_01
        ];
    }

    function count() external view returns (uint256) {
        return addr.length;
    }
}
