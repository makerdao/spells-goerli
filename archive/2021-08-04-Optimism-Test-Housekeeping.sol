// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2021 Maker Ecosystem Growth Holdings, INC.
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

import "lib/dss-interfaces/src/dss/GemJoinAbstract.sol";
import "lib/dss-interfaces/src/dss/IlkRegistryAbstract.sol";
import "lib/dss-interfaces/src/dapp/DSTokenAbstract.sol";

interface L1GovernanceRelayLike {
    function relay(address, bytes calldata, uint32) external;
}

contract DssSpellAction is DssAction {

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/TODO -q -O - 2>/dev/null)"
    string public constant in_memory_of = "Jeffrey Blechschmidt";
    string public constant override description = "Optimism test spell casting + housekeeping";

    // Vote delegate proxy factory
    address constant VOTE_DELEGATE_PROXY_FACTORY = 0x1740F3bD55b1900C816A0071F8972C201566e3a3;
    address constant L1_GOVERNANCE_RELAY         = 0xAeFc25750d8C2bd331293076E2DC5d5ad414b4a2;
    address constant L2_SPELL                    = 0xC88e0cDAA48FA8cA12212b157fdee617be4cBD70;

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {

        // Update RWA tokens and KNC symbols in ilk registry
        IlkRegistryAbstract ILK_REGISTRY = IlkRegistryAbstract(DssExecLib.reg());

        ILK_REGISTRY.file("RWA001-A", "symbol", "RWA001");
        ILK_REGISTRY.file("RWA002-A", "symbol", "RWA002");
        ILK_REGISTRY.file("RWA003-A", "symbol", "RWA003");
        ILK_REGISTRY.file("RWA004-A", "symbol", "RWA004");
        ILK_REGISTRY.file("RWA005-A", "symbol", "RWA005");
        ILK_REGISTRY.file("RWA006-A", "symbol", "RWA006");
        ILK_REGISTRY.file("KNC-A",    "symbol", "KNC");

        // Update early RWA and KNC tokens names in ilk registry
        ILK_REGISTRY.file("RWA001-A", "name", "RWA001-A: 6s Capital");
        ILK_REGISTRY.file("RWA002-A", "name", "RWA002-A: Centrifuge: New Silver");
        ILK_REGISTRY.file("KNC-A",    "name", "KNC-A");

        // Add vote delegate factory to changelog
        DssExecLib.setChangelogAddress("VOTE_DELEGATE_PROXY_FACTORY", VOTE_DELEGATE_PROXY_FACTORY);

        // Bump version, assuming 1.9.2 version passes
        DssExecLib.setChangelogVersion("1.9.3");

        // Perform a test spell on optimism
        L1GovernanceRelayLike(L1_GOVERNANCE_RELAY).relay(L2_SPELL, abi.encodeWithSignature("act()"), 3000000);
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
