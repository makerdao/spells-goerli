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

interface VatLike {
    function Line() external view returns (uint256);
    function file(bytes32 what, uint256 data) external;
    function ilks(bytes32 ilk) external view returns (uint256 Art, uint256 rate, uint256 spot, uint256 line, uint256 dust);
}

interface DssVestLike {
    function create(address, uint256, uint256, uint256, uint256, address) external returns (uint256);
    function file(bytes32, uint256) external;
    function restrict(uint256) external;
}
interface RwaLiquidationLike {
    function ilks(bytes32) external view returns (string memory, address, uint48, uint48);
    function init(bytes32, uint256, string calldata, uint48) external;
}

interface ACLManagerLike {
    function addPoolAdmin(address admin) external;
}

interface ProxyLike {
    function exec(address target, bytes calldata args) external payable returns (bytes memory out);
}

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";
    VatLike internal immutable vat = VatLike(DssExecLib.getChangelogAddress("MCD_VAT"));
    DssVestLike internal immutable vest = DssVestLike(DssExecLib.getChangelogAddress("MCD_VEST_MKR_TREASURY"));
    RwaLiquidationLike immutable rwaLiquidation = RwaLiquidationLike(DssExecLib.getChangelogAddress("MIP21_LIQUIDATION_ORACLE"));

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

    uint256 internal constant RAD               = 10 ** 45;
    uint256 internal constant MILLION           = 10 ** 6;

    uint256 internal constant THREE_PT_FOUR_NINE    = 1000000001087798189708544327;
    uint256 internal constant THREE_PT_SEVEN_FOUR   = 1000000001164306917698440949;
    uint256 internal constant FOUR_PT_TWO_FOUR      = 1000000001316772794769098706;
    uint256 internal constant FIVE_PT_EIGHT         = 1000000001787808646832390371;
    uint256 internal constant SIX_PT_THREE          = 1000000001937312893803622469;
    uint256 internal constant FIVE_PT_FIVE_FIVE     = 1000000001712791360746325100;

    address internal constant SPARK_ACL_MANAGER = 0xb137E7d16564c81ae2b0C8ee6B55De81dd46ECe5;
    address internal constant SPARK_PROXY = 0x4e847915D8a9f2Ab0cDf2FC2FD0A30428F25665d;
    address internal constant SPARK_SPELL = 0x3068FA0B6Fc6A5c998988a271501fF7A6892c6Ff;

    function _updateDoc(bytes32 ilk, string memory doc) internal {
        ( , address pip, uint48 tau, ) = rwaLiquidation.ilks(ilk);
        require(pip != address(0), "DssSpell/unexisting-rwa-ilk");

        // Init the RwaLiquidationOracle to reset the doc
        rwaLiquidation.init(
            ilk, // ilk to update
            0,   // price ignored if init() has already been called
            doc, // new legal document
            tau  // old tau value
        );
    }

    function actions() public override {
        uint256 line;

        // --- BlockTower Vault Debt Ceiling Adjustments ---
        // Poll: https://vote.makerdao.com/polling/QmPMrvfV#poll-detail
        // Forum: https://forum.makerdao.com/t/blocktower-credit-rwa-vaults-parameters-shift/20707

        // Decrease the Debt Ceiling (line) of BlockTower S1 (RWA010-A) from 20 million Dai to zero Dai.
        DssExecLib.setIlkDebtCeiling("RWA010-A", 0);
        // Decrease the Debt Ceiling (line) of BlockTower S2 (RWA011-A) from 30 million Dai to zero Dai.
        DssExecLib.setIlkDebtCeiling("RWA011-A", 0);
        // Increase the Debt Ceiling (line) of BlockTower S3 (RWA012-A) from 30 million Dai to 80 million Dai.
        DssExecLib.increaseIlkDebtCeiling("RWA012-A", 50 * MILLION, /* do not increase global line */ false);
        // TODO: Fill out doc values
        _updateDoc("RWA010-A", "FILLOUT");
        _updateDoc("RWA011-A", "FILLOUT");
        _updateDoc("RWA012-A", "FILLOUT");
        _updateDoc("RWA013-A", "FILLOUT");

        // --- MKR Vesting Transfers ---
        // Sidestream - 348.28 MKR - 0xb1f950a51516a697E103aaa69E152d839182f6Fe
        // Poll: N/A
        // MIP: https://mips.makerdao.com/mips/details/MIP40c3SP44#estimated-mkr-expenditure

        // Skip for goerli

        // DUX - 225.12 MKR - 0x5A994D8428CCEbCC153863CCdA9D2Be6352f89ad
        // Poll: N/A
        // MIP: https://mips.makerdao.com/mips/details/MIP40c3SP27

        // Skip for goerli

        // --- Stability Scope Defined Parameter Adjustments ---
        // Poll: https://vote.makerdao.com/polling/QmaoGpAQ#poll-detail
        // Forum: https://forum.makerdao.com/t/stability-scope-parameter-changes-2-non-scope-defined-parameter-changes-may-2023/20981#stability-scope-parameter-changes-proposal-6

        // Increase DSR to 3.49%
        DssExecLib.setDSR(THREE_PT_FOUR_NINE, true);

        // Set ETH-A Stability Fee to 3.74%
        DssExecLib.setIlkStabilityFee("ETH-A", THREE_PT_SEVEN_FOUR, /* doDrip = */ true);

        // Set ETH-B Stability Fee to 4.24%
        DssExecLib.setIlkStabilityFee("ETH-B", FOUR_PT_TWO_FOUR, /* doDrip = */ true);

        // Set ETH-C Stability Fee to 3.49%
        DssExecLib.setIlkStabilityFee("ETH-C", THREE_PT_FOUR_NINE, /* doDrip = */ true);

        // Set WSTETH-A Stability Fee to 3.74%
        DssExecLib.setIlkStabilityFee("WSTETH-A", THREE_PT_SEVEN_FOUR, /* doDrip = */ true);

        // Set WSTETH-B Stability Fee to 3.49%
        DssExecLib.setIlkStabilityFee("WSTETH-B", THREE_PT_FOUR_NINE, /* doDrip = */ true);

        // --- Spark Protocol Parameter Changes ---
        // D3M Parameter Adjustments Poll: https://vote.makerdao.com/polling/QmWatYqy#poll-detail
        // Executive Proxy Poll: https://vote.makerdao.com/polling/Qmc9fd3j#poll-detail
        // Onboard rETH Poll: https://vote.makerdao.com/polling/QmeEV7ph#vote-breakdown (Inside Proxy Spell)
        // DAI Interest Rate Strategy Poll: https://vote.makerdao.com/polling/QmWodV1J#poll-detail (Inside Proxy Spell)
        // Forum: https://forum.makerdao.com/t/2023-05-24-spark-protocol-updates/20958
        DssExecLib.setIlkAutoLineParameters("DIRECT-SPARK-DAI", /* line */ 20 * MILLION, /* gap */ 20 * MILLION, /* ttl */ 8 hours);
        DssExecLib.authorize(SPARK_PROXY, DssExecLib.esm());
        ACLManagerLike(SPARK_ACL_MANAGER).addPoolAdmin(SPARK_PROXY);
        ProxyLike(SPARK_PROXY).exec(SPARK_SPELL, abi.encodeWithSignature("execute()"));
        DssExecLib.setChangelogAddress("EXEC_PROXY_SPARK", SPARK_PROXY);

        // --- Non-Scope Defined Parameter Adjustments ---
        // Poll: https://vote.makerdao.com/polling/QmQXhS3Z#poll-detail
        // Forum: https://forum.makerdao.com/t/stability-scope-parameter-changes-2-non-scope-defined-parameter-changes-may-2023/20981

        // Increase rETH-A line to 50 million DAI
        // Increase rETH-A gap to 5 million DAI
        DssExecLib.setIlkAutoLineParameters("RETH-A", /* line */ 50 * MILLION, /* gap */ 5 * MILLION, /* ttl */ 8 hours);

        // Increase rETH-A Stability Fee to 3.74%
        DssExecLib.setIlkStabilityFee("RETH-A", THREE_PT_SEVEN_FOUR, true);

        // Increase CRVV1ETHSTETH-A Stability Fee to 4.24%
        // NOTE: disabled for goerli because the collateral is not on the chain
        // DssExecLib.setIlkStabilityFee("CRVV1ETHSTETH-A", FOUR_PT_TWO_FOUR, true);

        // Increase WBTC-A Stability Fee to 5.80%
        DssExecLib.setIlkStabilityFee("WBTC-A", FIVE_PT_EIGHT, true);

        // Increase WBTC-B Stability Fee to 6.30%
        DssExecLib.setIlkStabilityFee("WBTC-B", SIX_PT_THREE, true);

        // Increase WBTC-C Stability Fee to 5.55%
        DssExecLib.setIlkStabilityFee("WBTC-C", FIVE_PT_FIVE_FIVE, true);

        // --- RWA015 (BlockTower Andromeda) ---
        // Poll: https://vote.makerdao.com/polling/QmbudkVR#poll-detail
        // Forum links:
        //   - https://forum.makerdao.com/t/mip90-liquid-aaa-structured-credit-money-market-fund/18428
        //   - https://forum.makerdao.com/t/project-andromeda-risk-legal-assessment/20969
        //   - https://forum.makerdao.com/t/rwa015-project-andromeda-technical-assessment/20974

        // --- USDP PSM Debt Ceiling ---
        // Poll: https://vote.makerdao.com/polling/QmQYSLHH#poll-detail
        // Forum: https://forum.makerdao.com/t/reducing-psm-usdp-a-debt-ceiling/20980
        // Set PSM-USDP-A Debt Ceiling to 0 and remove from autoline
        (,,,line,) = vat.ilks("PSM-PAX-A");
        DssExecLib.decreaseIlkDebtCeiling("PSM-PAX-A", line / RAD, /* decrease global ceiling */ true);
        DssExecLib.removeIlkFromAutoLine("PSM-PAX-A");

        DssExecLib.setChangelogVersion("1.14.13");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
