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
    function deny(address usr) external;
}

interface CatLike {
    function deny(address usr) external;
}

interface ChainlogLike {
    function removeAddress(bytes32) external;
}

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // NOTE: Skip on goerli
    // GemAbstract internal immutable MKR      = GemAbstract(DssExecLib.mkr());
    address internal immutable MCD_VAT         = DssExecLib.getChangelogAddress("MCD_VAT");
    address internal immutable MCD_CAT         = DssExecLib.getChangelogAddress("MCD_CAT");
    address internal immutable MCD_PAUSE_PROXY = DssExecLib.getChangelogAddress("MCD_PAUSE_PROXY");

    // Always keep office hours off on goerli
    function officeHours() public pure override returns (bool) {
        return false;
    }

    // ----- Approve HV Bank (RWA009-A) DAO Resolution -----
    // Forum: http://forum.makerdao.com/t/request-to-poll-offboarding-legacy-legal-recourse-assets/21582
    // Poll: https://vote.makerdao.com/polling/QmNgKzcG
    // Approve DAO resolution hash QmXU2TwsRpVevGY74NVFbD9bKwtsw1mSuSce7My1zinD9m

    // Comma-separated list of DAO resolutions IPFS hashes.
    string public constant dao_resolutions = "QmXU2TwsRpVevGY74NVFbD9bKwtsw1mSuSce7My1zinD9m";

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

    uint256 internal constant MILLION = 10 ** 6;

    // NOTE: Skip on goerli
    // address internal constant DECO_001 = 0xF482D1031E5b172D42B2DAA1b6e5Cbf6519596f7;
    // address internal constant SES_001  = 0x87acdd9208f73bfc9207e1f6f0fde906bca95cc6;

    function actions() public override {
        // ---------- Aligned Delegate Compensation for August ----------
        // TODO

        // ---------- Core Unit MKR Vesting Transfer ----------
        // DECO-001 - 125 MKR - 0xF482D1031E5b172D42B2DAA1b6e5Cbf6519596f7
        // MIP: https://mips.makerdao.com/mips/details/MIP40c3SP36#sentence-summary
        // NOTE: Skip on goerli
        // MKR.transfer(DECO_001, 125 ether);

        // SES-001 - 34.93 MKR - 0x87acdd9208f73bfc9207e1f6f0fde906bca95cc6
        // MIP: https://mips.makerdao.com/mips/details/MIP40c3SP17#sentence-summary
        // NOTE: Skip on goerli
        // MKR.transfer(SES_001, 34.94 ether);

        // ---------- Decrease Debt Ceiling for Fortunafi (RWA-005 FF1-DROP) to 0 ----------
        // Set DC from 15 million DAI to 0 (zero)
        // Forum: http://forum.makerdao.com/t/request-to-poll-offboarding-legacy-legal-recourse-assets/21582
        // Poll: https://vote.makerdao.com/polling/Qmcb1c9x
        DssExecLib.decreaseIlkDebtCeiling("RWA005-A", 15 * MILLION, /* global = */ true);

        // ---------- Spark Protocol DC-IAM changes ----------
        // Forum: http://forum.makerdao.com/t/upcoming-spell-proposed-changes/21801
        // Poll: https://vote.makerdao.com/polling/QmQnUhZt#vote-breakdown
        // Increase the Maximum Debt Ceiling from 200 million DAI to 400 million DAI.
        // and
        // Increase Cooldown from 8 hours to 12 hours.
        DssExecLib.setIlkAutoLineParameters("DIRECT-SPARK-DAI", /* line */ 400 * MILLION, /* gap */ 20 * MILLION, /* ttl */ 12 hours);

        // ---------- Spark Protocol Market Parameter Changes ----------
        // TODO

        // ---------- Scuttle MCD_CAT ----------
        // Forum: http://forum.makerdao.com/t/proposal-to-scuttle-mcd-cat-upcoming-executive-spell-2023-09-13/21958

        // Remove MCD_CAT from the Chainlog
        ChainlogLike(DssExecLib.LOG).removeAddress("MCD_CAT");

        // Revoke MCD_CAT access to MCD_VAT: vat.deny(cat)
        VatLike(MCD_VAT).deny(MCD_CAT);

        // Yield ownership of MCD_CAT: cat.deny(pauseProxy)
        CatLike(MCD_CAT).deny(MCD_PAUSE_PROXY);

        // Bump chainlog version
        // Justification: The MINOR version is updated as core MCD_CAT contract is being removed in this spell
        DssExecLib.setChangelogVersion("1.17.0");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
