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

interface RwaLiquidationLike {
    function bump(bytes32 ilk, uint256 val) external;
}

interface ProxyLike {
    function exec(address target, bytes calldata args) external payable returns (bytes memory out);
}

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Always keep office hours off on goerli
    function officeHours() public pure override returns (bool) {
        return false;
    }

    // ---------- DAO Resolution for BlockTower Andromeda ----------
    // Forum: https://forum.makerdao.com/t/dao-resolution-to-facilitate-onboarding-of-taco-with-additional-third-parties/21572
    // Forum: https://forum.makerdao.com/t/dao-resolution-to-facilitate-onboarding-of-taco-with-additional-third-parties/21572/2

    // Include IPFS hash QmUNrCwKK2iK2ki5Spn97jrTCDKqFjDZWKk3wxQ2psgMP5 (not a `doc` update)
    // NOTE: by the previous convention it should be a comma-separated list of DAO resolutions IPFS hashes
    string public constant dao_resolutions = "QmUNrCwKK2iK2ki5Spn97jrTCDKqFjDZWKk3wxQ2psgMP5";

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
    // uint256 internal constant X_PCT_RATE      = ;
    uint256 internal constant THREE_PT_THREE_THREE_PCT_RATE = 1000000001038735548426731741;
    uint256 internal constant THREE_PT_FIVE_EIGHT_PCT_RATE  = 1000000001115362602336059074;
    uint256 internal constant FOUR_PT_ZERO_EIGHT_PCT_RATE   = 1000000001268063427242299977;
    uint256 internal constant FIVE_PCT_RATE                 = 1000000001547125957863212448;
    uint256 internal constant FIVE_PT_TWO_FIVE_PCT_RATE     = 1000000001622535724756171269;
    uint256 internal constant FIVE_PT_FIVE_FIVE_PCT_RATE    = 1000000001712791360746325100;
    uint256 internal constant FIVE_PT_EIGHT_PCT_RATE        = 1000000001787808646832390371;
    uint256 internal constant SIX_PT_THREE_PCT_RATE         = 1000000001937312893803622469;
    uint256 internal constant SEVEN_PCT_RATE                = 1000000002145441671308778766;

    // ---------- Math ----------
    uint256 internal constant THOUSAND = 10 ** 3;
    uint256 internal constant MILLION  = 10 ** 6;
    uint256 internal constant BILLION  = 10 ** 9;
    uint256 internal constant RAD      = 10 ** 45;

    // ---------- Smart Burn Engine Parameter Updates ----------
    address internal immutable MCD_VOW            = DssExecLib.vow();
    address internal immutable MCD_FLAP           = DssExecLib.flap();

    // ---------- New Silver Parameter Changes ----------
    address internal immutable MIP21_LIQUIDATION_ORACLE = DssExecLib.getChangelogAddress("MIP21_LIQUIDATION_ORACLE");

    // ---------- Transfer Spark Proxy Admin Controls ----------
    // Contracts pulled from Spark official deployment repository
    // https://github.com/marsfoundation/sparklend/blob/ca2b72af7c5fb790cc91eaca5d8d4c83fa37e74b/script/output/5/primary-latest.json
    // Spark Proxy: https://github.com/marsfoundation/sparklend/blob/ca2b72af7c5fb790cc91eaca5d8d4c83fa37e74b/script/output/5/primary-sce-latest.json#L2
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

    // ---------- Trigger Spark Proxy Spell ----------
    address internal constant SPARK_SPELL    = 0x13176Ad78eC3d2b6E32908B019D0F772EC0b4dFd;

    function actions() public override {
        // ---------- EDSR Update ----------
        // Forum: https://forum.makerdao.com/t/request-for-gov12-1-2-edit-to-the-stability-scope-to-quickly-modify-enhanced-dsr-based-on-observed-data/21581

        // Reduce DSR by 3% from 8% to 5%
        DssExecLib.setDSR(FIVE_PCT_RATE, /* doDrip = */ true);

        // ---------- DSR-based Stability Fee Updates ----------
        // Forum: https://forum.makerdao.com/t/request-for-gov12-1-2-edit-to-the-stability-scope-to-quickly-modify-enhanced-dsr-based-on-observed-data/21581

        // Increase ETH-A SF by 0.14% from 3.44% to 3.58%
        DssExecLib.setIlkStabilityFee("ETH-A", THREE_PT_FIVE_EIGHT_PCT_RATE, /* doDrip = */ true);

        // Increase ETH-B SF by 0.14% from 3.94%% to 4.08%
        DssExecLib.setIlkStabilityFee("ETH-B", FOUR_PT_ZERO_EIGHT_PCT_RATE, /* doDrip = */ true);

        // Increase ETH-C SF by 0.14% from 3.19% to 3.33%
        DssExecLib.setIlkStabilityFee("ETH-C", THREE_PT_THREE_THREE_PCT_RATE, /* doDrip = */ true);

        // Increase WSTETH-A SF by 1.81% from 3.44% to 5.25%
        DssExecLib.setIlkStabilityFee("WSTETH-A", FIVE_PT_TWO_FIVE_PCT_RATE, /* doDrip = */ true);

        // Increase WSTETH-B SF by 1.81% from 3.19% to 5.00%
        DssExecLib.setIlkStabilityFee("WSTETH-B", FIVE_PCT_RATE, /* doDrip = */ true);

        // Increase RETH-A SF by 1.81% from 3.44% to 5.25%
        DssExecLib.setIlkStabilityFee("RETH-A", FIVE_PT_TWO_FIVE_PCT_RATE, /* doDrip = */ true);

        // Increase WBTC-A SF by 0.11% from 5.69% to 5.80%
        DssExecLib.setIlkStabilityFee("WBTC-A", FIVE_PT_EIGHT_PCT_RATE, /* doDrip = */ true);

        // Increase WBTC-B SF by 0.11% from 6.19% to 6.30%
        DssExecLib.setIlkStabilityFee("WBTC-B", SIX_PT_THREE_PCT_RATE, /* doDrip = */ true);

        // Increase WBTC-C SF by 0.11% from 5.44% to 5.55%
        DssExecLib.setIlkStabilityFee("WBTC-C", FIVE_PT_FIVE_FIVE_PCT_RATE, /* doDrip = */ true);

        // ---------- Smart Burn Engine Parameter Updates ----------
        // Poll: https://vote.makerdao.com/polling/QmTRJNNH
        // Forum: https://forum.makerdao.com/t/smart-burn-engine-parameters-update-1/21545

        // Increase vow.bump by 15,000 DAI from 5,000 DAI to 20,000 DAI
        DssExecLib.setValue(MCD_VOW, "bump", 20 * THOUSAND * RAD);

        // Increase hop by 4,731 seconds from 1,577 seconds to 6,308 seconds
        DssExecLib.setValue(MCD_FLAP, "hop", 6_308);

        // ---------- Non-DSR Related Parameter Changes ----------
        // Forum: https://forum.makerdao.com/t/stability-scope-parameter-changes-4/21567
        // Mip: https://mips.makerdao.com/mips/details/MIP104#14-3-native-vault-engine

        // Increase WSTETH-A line by 250 million DAI from 500 million DAI to 750 million DAI (no change to gap or ttl)
        DssExecLib.setIlkAutoLineDebtCeiling("WSTETH-A", 750 * MILLION);

        // Increase WSTETH-B line by 500 million DAi from 500 million DAI to 1 billion DAI
        // Increase WSTETH-B gap by 15 million DAI from 30 million DAI to 45 million DAI
        // Reduce WSTETH-B ttl by 14,400 seconds from 57,600 seconds to 43,200 seconds
        // Forum: https://forum.makerdao.com/t/non-scope-defined-parameter-changes-wsteth-b-dc-iam/21568
        // Poll: https://vote.makerdao.com/polling/QmPxbrBZ#poll-detail
        DssExecLib.setIlkAutoLineParameters("WSTETH-B", 1 * BILLION, 45 * MILLION, 12 hours);

        // Increase RETH-A line by 25 million DAI from 50 million DAI to 75 million DAI
        DssExecLib.setIlkAutoLineDebtCeiling("RETH-A", 75 * MILLION);

        // ---------- CRVV1ETHSTETH-A 2nd Stage Offboarding ----------
        // Forum: https://forum.makerdao.com/t/stability-scope-parameter-changes-4/21567#crvv1ethsteth-a-offboarding-parameters-13
        // Mip: https://mips.makerdao.com/mips/details/MIP104#14-3-native-vault-engine
        // NOTE: ignore on goerli (since there is no CRVV1ETHSTETH-A)

        // Set chop to 0%
        // Set tip to 0%
        // Set chip to 0%
        // Set Liquidation Ratio to 10,000%
        // Reduce Global Debt Ceiling by 100 million DAI to account for offboarded collateral

        // ---------- Aligned Delegate Compensation for July 2023 ----------
        // Forum: https://forum.makerdao.com/t/july-2023-aligned-delegate-compensation/21632
        // NOTE: ignore on goerli

        // 0xDefensor - 29.76 MKR - 0x9542b441d65B6BF4dDdd3d4D2a66D8dCB9EE07a9
        // BONAPUBLICA - 29.76 MKR - 0x167c1a762B08D7e78dbF8f24e5C3f1Ab415021D3
        // QGov - 29.76 MKR - 0xB0524D8707F76c681901b782372EbeD2d4bA28a6
        // TRUE NAME - 29.76 MKR - 0x612f7924c367575a0edf21333d96b15f1b345a5d
        // UPMaker - 29.76 MKR - 0xbb819df169670dc71a16f58f55956fe642cc6bcd
        // vigilant - 29.76 MKR - 0x2474937cB55500601BCCE9f4cb0A0A72Dc226F61
        // WBC - 14.82 MKR - 0xeBcE83e491947aDB1396Ee7E55d3c81414fB0D47
        // PALC - 13.89 MKR - 0x78Deac4F87BD8007b9cb56B8d53889ed5374e83A
        // Navigator - 11.24 MKR - 0x11406a9CC2e37425F15f920F494A51133ac93072
        // PBG - 9.92 MKR - 0x8D4df847dB7FfE0B46AF084fE031F7691C6478c2
        // VoteWizard - 9.92 MKR - 0x9E72629dF4fcaA2c2F5813FbbDc55064345431b1
        // Libertas - 9.92 MKR - 0xE1eBfFa01883EF2b4A9f59b587fFf1a5B44dbb2f
        // Harmony - 8.93 MKR - 0xF4704Aa4Ad22cAA2A3Dd7A7C529B4C32f7A421F2
        // JAG - 7.61 MKR - 0x58D1ec57E4294E4fe650D1CB12b96AE34349556f
        // Cloaky - 4.30 MKR - 0x869b6d5d8FA7f4FFdaCA4D23FFE0735c5eD1F818
        // Skynet - 3.64 MKR - 0xd4d1A446cD5976a11bd32D3e815A9F85FED2F9F3

        // ---------- Old D3M Parameter Housekeeping ----------
        // Forum: https://forum.makerdao.com/t/notice-of-executive-vote-date-change-and-housekeeping-changes/21613
        // NOTE: ignore on goerli

        // Remove DIRECT-AAVEV2-DAI from autoline
        // Set DIRECT-AAVEV2-DAI Debt Ceiling to 0
        // Remove DIRECT-COMPV2-DAI from autoline
        // Set DIRECT-COMPV2-DAI Debt Ceiling to 0
        // Reduce Global Debt Ceiling? Yes

        // ---------- New Silver Parameter Changes ----------
        // Forum: https://forum.makerdao.com/t/rwa-002-new-silver-restructuring-risk-and-legal-assessment/21417
        // Poll: https://vote.makerdao.com/polling/QmaU1eaD#poll-detail

        // Increase RWA002-A Debt Ceiling by 30 million DAI from 20 million DAI to 50 million DAI
        DssExecLib.increaseIlkDebtCeiling(
            "RWA002-A",
            30 * MILLION,
            true // Increase global Line
        );

        // Increase RWA002-A Stability Fee by 3.5% from 3.5% to 7%
        DssExecLib.setIlkStabilityFee("RWA002-A", SEVEN_PCT_RATE, /* doDrip = */ true);

        // Reduce Liquidation Ratio by 5% from 105% to 100%
        // Forum: https://forum.makerdao.com/t/notice-of-executive-vote-date-change-and-housekeeping-changes/21613
        DssExecLib.setIlkLiquidationRatio("RWA002-A", 100_00);

        // Bump Oracle price to account for new DC and SF
        // NOTE: the formula is `Debt ceiling * [ (1 + RWA stability fee ) ^ (minimum deal duration in years) ] * liquidation ratio`
        // Since RWA002-A Termination Date is `October 11, 2032`, and spell execution time is `2023-08-18`, the distance is `3342` days
        // bc -l <<< 'scale=18; 50000000 * e(l(1.07) * (3342/365)) * 1.00' | cast --to-wei
        RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).bump(
            "RWA002-A",
            92_899_355_926924134500000000
        );

        // NOTE: Update collateral price to propagate the changes
        DssExecLib.updateCollateralPrice("RWA002-A");

        // ---------- Transfer Spark Proxy Admin Controls ----------
        // Forum: https://forum.makerdao.com/t/phoenix-labs-proposed-changes-for-spark-for-august-18th-spell/21612
        // Poll: https://vote.makerdao.com/polling/Qmc9fd3j

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
        // Forum: https://forum.makerdao.com/t/phoenix-labs-proposed-changes-for-spark-for-august-18th-spell/21612

        // Goerli - 0x13176ad78ec3d2b6e32908b019d0f772ec0b4dfd
        ProxyLike(SPARK_PROXY).exec(SPARK_SPELL, abi.encodeWithSignature("execute()"));
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
