// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2022 Dai Foundation
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

import {stdJson} from "forge-std/StdJson.sol";
import {ChainlogAbstract} from "dss-interfaces/Interfaces.sol";
import {Vm} from "forge-std/Vm.sol";

contract Domain {

    using stdJson for string;

    string public config;
    string public name;
    Vm public vm;
    uint256 public forkId;

    event Log(string, string);
    event Log(string, uint256);

    constructor(Vm _vm, string memory _config, string memory _name) public {
        config = _config;
        name = _name;
        vm = _vm;
        string memory rpc = vm.envString(readConfigString("rpc"));
        if (bytes(rpc).length == 0) revert(stringConcat(stringConcat("Environment variable '", rpc), "' is not defined."));
        forkId = vm.createFork(rpc);
        uint256 domainBlock = vm.envUint(readConfigString("block"));
        if (domainBlock > 0) {
            vm.rollFork(forkId, domainBlock);
        }
        vm.makePersistent(address(this));
    }

    function stringConcat(string memory a, string memory b) pure internal returns(string memory) {
        return string(abi.encodePacked(a, b));
    }

    function readConfigString(string memory key) public returns (string memory) {
        return config.readString(stringConcat(stringConcat(stringConcat(".domains.", name), "."), key));
    }

    function readConfigAddress(string memory key) public returns (address) {
        return config.readAddress(stringConcat(stringConcat(stringConcat(".domains.", name), "."), key));
    }

    function readConfigUint(string memory key) public returns (uint256) {
        return config.readUint(stringConcat(stringConcat(stringConcat(".domains.", name), "."), key));
    }

    function readConfigInt(string memory key) public returns (int256) {
        return config.readInt(stringConcat(stringConcat(stringConcat(".domains.", name), "."), key));
    }

    function readConfigBytes32(string memory key) public returns (bytes32) {
        return config.readBytes32(stringConcat(stringConcat(stringConcat(".domains.", name), "."), key));
    }

    function selectFork() public {
        vm.selectFork(forkId);
    }
}
