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

import "dss-interfaces/dss/VatAbstract.sol";

interface AuthLike {
    function rely(address) external;
}

interface LineMomLike {
    function owner() external view returns (address);
    function setAuthority(address authority_) external;
    function file(bytes32 what, address data) external;
    function addIlk(bytes32 ilk) external;
}

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    string public constant override description = "Goerli Spell";

    // Turn office hours off
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

    uint256 internal constant MILLION = 10 ** 6;

    address internal  constant LINE_MOM    = 0x5D54E2d56BA83C42f63a10642DcFa073EBD9D92E;
    address immutable internal PAUSE_PROXY = DssExecLib.getChangelogAddress("MCD_PAUSE_PROXY");
    address immutable internal CHIEF       = DssExecLib.getChangelogAddress("MCD_ADM");
    address immutable internal AUTOLINE    = DssExecLib.getChangelogAddress("MCD_IAM_AUTO_LINE");

    function actions() public override {
        //  Out-Of-Schedule executive proposal to implement PSM Breaker (14 March 2023)
        // https://forum.makerdao.com/t/out-of-schedule-executive-proposal-to-implement-psm-breaker/20162

        VatAbstract vat = VatAbstract(DssExecLib.vat());


        // Begin LineMom ----------------------------------------------

        // 1. Authorize LineMom on the Vat and AutoLine modules
        vat.rely(LINE_MOM);
        AuthLike(AUTOLINE).rely(LINE_MOM);

        // 2. Owner is Pause Proxy - just a sanity check
        require(LineMomLike(LINE_MOM).owner() == PAUSE_PROXY);

        // 3. File the AutoLine
        LineMomLike(LINE_MOM).file("autoLine", AUTOLINE);

        // 4. Authority is Chief
        LineMomLike(LINE_MOM).setAuthority(CHIEF);

        // 5. Add PSM ilks
        LineMomLike(LINE_MOM).addIlk("PSM-USDC-A");
        LineMomLike(LINE_MOM).addIlk("PSM-PAX-A");
        LineMomLike(LINE_MOM).addIlk("PSM-GUSD-A");

        // 6. Add to ChainLog and bump patch version
        DssExecLib.setChangelogAddress("LINE_MOM", LINE_MOM);
        DssExecLib.setChangelogVersion("1.14.10");

        // End LineMom ------------------------------------------------


        // Increase Global Debt Ceiling to compensate for reduction that should not have
        // been done in previous spell. Computed based on current debt of affected ilks.
        uint256 correction;
        uint256 Art;
        uint256 rate;
        (Art, rate,,,) = vat.ilks("UNIV2USDCETH-A");
        correction += Art * rate;
        (Art, rate,,,) = vat.ilks("UNIV2DAIUSDC-A");
        correction += Art * rate;
        (Art, rate,,,) = vat.ilks("GUNIV3DAIUSDC1-A");
        correction += Art * rate;
        (Art, rate,,,) = vat.ilks("GUNIV3DAIUSDC2-A");
        correction += Art * rate;

        // Add a buffer of 10% for fee accrual
        correction = correction * 110 / 100;
        vat.file("Line", vat.Line() + correction);
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}
