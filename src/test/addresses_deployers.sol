
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.6.12;

contract Deployers {

    address[] public addr;

    constructor() public {
        addr = [
            0xda0fab060e6cc7b1C0AA105d29Bd50D71f036711,
            0xDA0FaB0700A4389F6E6679aBAb1692B4601ce9bf,
            0xdA0C0de01d90A5933692Edf03c7cE946C7c50445,
            0xdB33dFD3D61308C33C63209845DaD3e6bfb2c674,
            0xDA01018eA05D98aBb66cb21a85d6019a311570eE,
            0xDA0111100cb6080b43926253AB88bE719C60Be13
        ];
    }

    function count() external view returns (uint) {
        addr.length;
    }
}
