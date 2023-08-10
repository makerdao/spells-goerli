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

interface TransferOwnershipLike {
    function transferOwnership(address newOwner) external;
}

interface ChangeAdminLike {
    function changeAdmin(address newAdmin) external;
}

interface ACLManagerLike {
    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);
    function addEmergencyAdmin(address admin) external;
    function removeEmergencyAdmin(address admin) external;
    function removePoolAdmin(address admin) external;
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
}

interface PoolAddressProviderLike {
    function setACLAdmin(address newAclAdmin) external;
}

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

    // Contracts pulled from Spark official deployment repository
    // https://github.com/marsfoundation/sparklend/blob/ca2b72af7c5fb790cc91eaca5d8d4c83fa37e74b/script/output/5/primary-latest.json
    address internal constant SPARK_PROXY                          = 0x4e847915D8a9f2Ab0cDf2FC2FD0A30428F25665d;
    address internal constant SPARK_TREASURY_CONTROLLER            = 0x98e6BcBA7d5daFbfa4a92dAF08d3d7512820c30C;
    address internal constant SPARK_TREASURY                       = 0x0D56700c90a690D8795D6C148aCD94b12932f4E3;
    address internal constant SPARK_TREASURY_DAI                   = 0x44816381990B6613c7A96ca1937f3902D8eA3F5b;
    address internal constant SPARK_INCENTIVES                     = 0xF028c2F4b19898718fD0F77b9b881CbfdAa5e8Bb;
    address internal constant SPARK_WETH_GATEWAY                   = 0xe6fC577E87F7c977c4393300417dCC592D90acF8;
    address internal constant SPARK_ACL_MANAGER                    = 0xb137E7d16564c81ae2b0C8ee6B55De81dd46ECe5;
    address internal constant SPARK_POOL_ADDRESS_PROVIDER          = 0x026a5B6114431d8F3eF2fA0E1B2EDdDccA9c540E;
    address internal constant SPARK_POOL_ADDRESS_PROVIDER_REGISTRY = 0x1ad570fDEA255a3c1d8Cf56ec76ebA2b7bFDFfea;
    address internal constant SPARK_EMISSION_MANAGER               = 0xA7F8A757C4f7696c015B595F51B2901AC0121B18;

    function actions() public override {
        // ---------- EDSR Update ----------
        // Forum: https://forum.makerdao.com/t/request-for-gov12-1-2-edit-to-the-stability-scope-to-quickly-modify-enhanced-dsr-based-on-observed-data/21581

        // ---------- DSR-based Stability Fee Updates ----------
        // Forum: https://forum.makerdao.com/t/request-for-gov12-1-2-edit-to-the-stability-scope-to-quickly-modify-enhanced-dsr-based-on-observed-data/21581

        // ---------- Smart Burn Engine Parameter Updates ----------
        // Poll: https://vote.makerdao.com/polling/QmTRJNNH
        // Forum: https://forum.makerdao.com/t/smart-burn-engine-parameters-update-1/21545

        // ---------- Non-DSR Related Parameter Changes ----------
        // Forum: https://forum.makerdao.com/t/stability-scope-parameter-changes-4/21567
        // Mip: https://mips.makerdao.com/mips/details/MIP104#14-3-native-vault-engine

        // ---------- CRVV1ETHSTETH-A 2nd Stage Offboarding ----------
        // Forum: https://forum.makerdao.com/t/stability-scope-parameter-changes-4/21567#crvv1ethsteth-a-offboarding-parameters-13
        // Mip: https://mips.makerdao.com/mips/details/MIP104#14-3-native-vault-engine
        // NOTE: ignore on goerli (since there is no CRVV1ETHSTETH-A there)

        // ---------- Aligned Delegate Compensation for July 2023 ----------
        // NOTE: ignore on goerli

        // ---------- Old D3M Parameter Housekeeping ----------

        // ---------- New Silver Parameter Changes ----------

        // ---------- Transfer Spark Proxy Admin Controls ----------
        TransferOwnershipLike(SPARK_TREASURY_CONTROLLER).transferOwnership(SPARK_PROXY);
        ChangeAdminLike(SPARK_TREASURY).changeAdmin(SPARK_PROXY);
        ChangeAdminLike(SPARK_TREASURY_DAI).changeAdmin(SPARK_PROXY);
        ChangeAdminLike(SPARK_INCENTIVES).changeAdmin(SPARK_PROXY);
        TransferOwnershipLike(SPARK_WETH_GATEWAY).transferOwnership(SPARK_PROXY);
        ACLManagerLike(SPARK_ACL_MANAGER).addEmergencyAdmin(SPARK_PROXY);
        ACLManagerLike(SPARK_ACL_MANAGER).removeEmergencyAdmin(address(this));
        ACLManagerLike(SPARK_ACL_MANAGER).removePoolAdmin(address(this));
        bytes32 defaultAdminRole = ACLManagerLike(SPARK_ACL_MANAGER).DEFAULT_ADMIN_ROLE();
        ACLManagerLike(SPARK_ACL_MANAGER).grantRole(defaultAdminRole, SPARK_PROXY);
        ACLManagerLike(SPARK_ACL_MANAGER).revokeRole(defaultAdminRole, address(this));
        PoolAddressProviderLike(SPARK_POOL_ADDRESS_PROVIDER).setACLAdmin(SPARK_PROXY);
        TransferOwnershipLike(SPARK_POOL_ADDRESS_PROVIDER).transferOwnership(SPARK_PROXY);
        TransferOwnershipLike(SPARK_POOL_ADDRESS_PROVIDER_REGISTRY).transferOwnership(SPARK_PROXY);
        TransferOwnershipLike(SPARK_EMISSION_MANAGER).transferOwnership(SPARK_PROXY);

        // ---------- Trigger Spark Proxy Spell ----------
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
