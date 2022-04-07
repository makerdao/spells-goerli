// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Copyright (C) 2021-2022 Dai Foundation
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

import "./Goerli-DssSpell.t.base.sol";

interface DenyProxyLike {
    function denyProxy(address) external;
}

contract DssSpellTest is GoerliDssSpellTestBase {

    function test_OSM_auth() public {
        address ORACLE_WALLET01 = 0x4D6fbF888c374D7964D56144dE0C0cFBd49750D3;
        address ORACLE_WALLET02 = 0x1f42e41A34B71606FcC60b4e624243b365D99745;

        // validate the spell does what we told it to
        bytes32[] memory ilks = reg.list();

        for(uint256 i = 0; i < ilks.length; i++) {
            uint256 class = reg.class(ilks[i]);
            if (class != 1) { continue; }

            address pip = reg.pip(ilks[i]);
            // skip USDC, TUSD, PAXUSD, GUSD
            if (pip == 0x838212865E2c2f4F7226fCc0A3EFc3EB139eC661 ||
                pip == 0x0ce19eA2C568890e63083652f205554C927a0caa ||
                pip == 0xdF8474337c9D3f66C0b71d31C7D3596E4F517457 ||
                pip == 0x57A00620Ba1f5f81F20565ce72df4Ad695B389d7) {
                continue;
            }

            assertEq(OsmAbstract(pip).wards(ORACLE_WALLET01), 0);
            assertEq(OsmAbstract(pip).wards(ORACLE_WALLET02), 0);
        }

        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        for(uint256 i = 0; i < ilks.length; i++) {
            uint256 class = reg.class(ilks[i]);
            if (class != 1) { continue; }

            address pip = reg.pip(ilks[i]);
            // skip USDC, TUSD, PAXUSD, GUSD
            if (pip == 0x838212865E2c2f4F7226fCc0A3EFc3EB139eC661 ||
                pip == 0x0ce19eA2C568890e63083652f205554C927a0caa ||
                pip == 0xdF8474337c9D3f66C0b71d31C7D3596E4F517457 ||
                pip == 0x57A00620Ba1f5f81F20565ce72df4Ad695B389d7) {
                continue;
            }

            assertEq(OsmAbstract(pip).wards(ORACLE_WALLET01), 1);
            assertEq(OsmAbstract(pip).wards(ORACLE_WALLET02), 1);
        }
    }

    function test_oracle_list() public {
        address ORACLE_WALLET01 = 0x4D6fbF888c374D7964D56144dE0C0cFBd49750D3;
        address ORACLE_WALLET02 = 0x1f42e41A34B71606FcC60b4e624243b365D99745;

        // validate the spell does what Oracle's wanted
        // https://discord.com/channels/893112320329396265/897479589171986434/960944481157390336
        assertEq(OsmAbstract(0xF15993A5C5BE496b8e1c9657Fd2233b579Cd3Bc6).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0x2BA78cb27044edCb715b03685D4bf74261170a70).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0xc3d677a5451cAFED13f748d822418098593D3599).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0x94588e35fF4d2E99ffb8D5095F35d1E37d6dDf12).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0xF953cdebbbf63607EeBc556438d86F2e1d47C8aA).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0x6Fb18806ff87B45220C2DB0941709142f2395069).wards(ORACLE_WALLET01), 0);
        // assertEq(OsmAbstract(0x57A00620Ba1f5f81F20565ce72df4Ad695B389d7).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0xCB772363E2DEc06942edbc5E697F4A9114B5989c).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0x75B4e743772D25a7998F4230cb016ddCF2c52629).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0x5AD3A560BB125d00db8E94915232BA8f6166967C).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0x001eDD66a5Cc9268159Cf24F3dC0AdcE456AAAAb).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0xDe112F61b823e776B3439f2F39AfF41f57993045).wards(ORACLE_WALLET01), 0);
        // assertEq(OsmAbstract(0xdF8474337c9D3f66C0b71d31C7D3596E4F517457).wards(ORACLE_WALLET01), 0);
        // assertEq(OsmAbstract(0xdF8474337c9D3f66C0b71d31C7D3596E4F517457).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0xE7de200a3a29E9049E378b52BD36701A0Ce68C3b).wards(ORACLE_WALLET01), 0);
        // assertEq(OsmAbstract(0x95282c2cDE88b93F784E2485f885580275551387).wards(ORACLE_WALLET01), 0);
        // assertEq(OsmAbstract(0xF1E8E72AE116193A9fA551beC1cda965147b31DA).wards(ORACLE_WALLET01), 0);
        // assertEq(OsmAbstract(0x27E599C9D69e02477f5ffF4c8E4E42B97777eE52).wards(ORACLE_WALLET01), 0);
        // assertEq(OsmAbstract(0x3C191d5a74800A99D8747fdffAea42F60f7d3Bff).wards(ORACLE_WALLET01), 0);
        // assertEq(OsmAbstract(0xa6A7f2408949cAbD13f254F8e77ad5C9896725aB).wards(ORACLE_WALLET01), 0);
        // assertEq(OsmAbstract(0xA410A66313F943d022b79f2943C9A37CefdE2371).wards(ORACLE_WALLET01), 0);
        // assertEq(OsmAbstract(0x0ce19eA2C568890e63083652f205554C927a0caa).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0xf1a5b808fbA8fF80982dACe88020d4a80c91aFe6).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0xFADF05B56E4b211877248cF11C0847e7F8924e10).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0x044c9aeD56369aA3f696c898AEd0C38dC53c6C3D).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0xEf22289E240cFcCCdCD2B98fdefF167da10f452d).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0x2fc2706C61Fba5b941381e8838bC646908845db6).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0x974f7f4dC6D91f144c87cc03749c98f85F997bc7).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0x11C884B3FEE1494A666Bb20b6F6144387beAf4A6).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0xB18BC24e52C23A77225E7cf088756581EE257Ad8).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0x54ADcaB9B99b1B548764dAB637db751eC66835F0).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0x916fc346910fd25867c81874f7F982a1FB69aac7).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0xD375daC26f7eF991878136b387ca959b9ac1DDaF).wards(ORACLE_WALLET01), 0);
        // assertEq(OsmAbstract(0x838212865E2c2f4F7226fCc0A3EFc3EB139eC661).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0x1fA3B8DAeE1BCEe33990f66F1a99993daD14D855).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0xE7de200a3a29E9049E378b52BD36701A0Ce68C3b).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0x323eac5246d5BcB33d66e260E882fC9bF4B6bf41).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0xAafF0066D05cEe0D6a38b4dac77e73d9E0a5Cf46).wards(ORACLE_WALLET01), 0);
        assertEq(OsmAbstract(0xe9245D25F3265E9A36DcCDC72B0B5dE1eeACD4cD).wards(ORACLE_WALLET01), 0);

        assertEq(OsmAbstract(0xF15993A5C5BE496b8e1c9657Fd2233b579Cd3Bc6).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0x2BA78cb27044edCb715b03685D4bf74261170a70).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0xc3d677a5451cAFED13f748d822418098593D3599).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0x94588e35fF4d2E99ffb8D5095F35d1E37d6dDf12).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0xF953cdebbbf63607EeBc556438d86F2e1d47C8aA).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0x6Fb18806ff87B45220C2DB0941709142f2395069).wards(ORACLE_WALLET02), 0);
        // assertEq(OsmAbstract(0x57A00620Ba1f5f81F20565ce72df4Ad695B389d7).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0xCB772363E2DEc06942edbc5E697F4A9114B5989c).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0x75B4e743772D25a7998F4230cb016ddCF2c52629).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0x5AD3A560BB125d00db8E94915232BA8f6166967C).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0x001eDD66a5Cc9268159Cf24F3dC0AdcE456AAAAb).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0xDe112F61b823e776B3439f2F39AfF41f57993045).wards(ORACLE_WALLET02), 0);
        // assertEq(OsmAbstract(0xdF8474337c9D3f66C0b71d31C7D3596E4F517457).wards(ORACLE_WALLET02), 0);
        // assertEq(OsmAbstract(0xdF8474337c9D3f66C0b71d31C7D3596E4F517457).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0xE7de200a3a29E9049E378b52BD36701A0Ce68C3b).wards(ORACLE_WALLET02), 0);
        // assertEq(OsmAbstract(0x95282c2cDE88b93F784E2485f885580275551387).wards(ORACLE_WALLET02), 0);
        // assertEq(OsmAbstract(0xF1E8E72AE116193A9fA551beC1cda965147b31DA).wards(ORACLE_WALLET02), 0);
        // assertEq(OsmAbstract(0x27E599C9D69e02477f5ffF4c8E4E42B97777eE52).wards(ORACLE_WALLET02), 0);
        // assertEq(OsmAbstract(0x3C191d5a74800A99D8747fdffAea42F60f7d3Bff).wards(ORACLE_WALLET02), 0);
        // assertEq(OsmAbstract(0xa6A7f2408949cAbD13f254F8e77ad5C9896725aB).wards(ORACLE_WALLET02), 0);
        // assertEq(OsmAbstract(0xA410A66313F943d022b79f2943C9A37CefdE2371).wards(ORACLE_WALLET02), 0);
        // assertEq(OsmAbstract(0x0ce19eA2C568890e63083652f205554C927a0caa).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0xf1a5b808fbA8fF80982dACe88020d4a80c91aFe6).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0xFADF05B56E4b211877248cF11C0847e7F8924e10).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0x044c9aeD56369aA3f696c898AEd0C38dC53c6C3D).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0xEf22289E240cFcCCdCD2B98fdefF167da10f452d).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0x2fc2706C61Fba5b941381e8838bC646908845db6).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0x974f7f4dC6D91f144c87cc03749c98f85F997bc7).wards(ORACLE_WALLET02), 0);
        // assertEq(OsmAbstract(0x11C884B3FEE1494A666Bb20b6F6144387beAf4A6).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0xB18BC24e52C23A77225E7cf088756581EE257Ad8).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0x54ADcaB9B99b1B548764dAB637db751eC66835F0).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0x916fc346910fd25867c81874f7F982a1FB69aac7).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0xD375daC26f7eF991878136b387ca959b9ac1DDaF).wards(ORACLE_WALLET02), 0);
        // assertEq(OsmAbstract(0x838212865E2c2f4F7226fCc0A3EFc3EB139eC661).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0x1fA3B8DAeE1BCEe33990f66F1a99993daD14D855).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0xE7de200a3a29E9049E378b52BD36701A0Ce68C3b).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0x323eac5246d5BcB33d66e260E882fC9bF4B6bf41).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0xAafF0066D05cEe0D6a38b4dac77e73d9E0a5Cf46).wards(ORACLE_WALLET02), 0);
        assertEq(OsmAbstract(0xe9245D25F3265E9A36DcCDC72B0B5dE1eeACD4cD).wards(ORACLE_WALLET02), 0);

        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        assertEq(OsmAbstract(0xF15993A5C5BE496b8e1c9657Fd2233b579Cd3Bc6).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0x2BA78cb27044edCb715b03685D4bf74261170a70).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0xc3d677a5451cAFED13f748d822418098593D3599).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0x94588e35fF4d2E99ffb8D5095F35d1E37d6dDf12).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0xF953cdebbbf63607EeBc556438d86F2e1d47C8aA).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0x6Fb18806ff87B45220C2DB0941709142f2395069).wards(ORACLE_WALLET01), 1);
        // assertEq(OsmAbstract(0x57A00620Ba1f5f81F20565ce72df4Ad695B389d7).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0xCB772363E2DEc06942edbc5E697F4A9114B5989c).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0x75B4e743772D25a7998F4230cb016ddCF2c52629).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0x5AD3A560BB125d00db8E94915232BA8f6166967C).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0x001eDD66a5Cc9268159Cf24F3dC0AdcE456AAAAb).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0xDe112F61b823e776B3439f2F39AfF41f57993045).wards(ORACLE_WALLET01), 1);
        // assertEq(OsmAbstract(0xdF8474337c9D3f66C0b71d31C7D3596E4F517457).wards(ORACLE_WALLET01), 1);
        // assertEq(OsmAbstract(0xdF8474337c9D3f66C0b71d31C7D3596E4F517457).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0xE7de200a3a29E9049E378b52BD36701A0Ce68C3b).wards(ORACLE_WALLET01), 1);
        // assertEq(OsmAbstract(0x95282c2cDE88b93F784E2485f885580275551387).wards(ORACLE_WALLET01), 1);
        // assertEq(OsmAbstract(0xF1E8E72AE116193A9fA551beC1cda965147b31DA).wards(ORACLE_WALLET01), 1);
        // assertEq(OsmAbstract(0x27E599C9D69e02477f5ffF4c8E4E42B97777eE52).wards(ORACLE_WALLET01), 1);
        // assertEq(OsmAbstract(0x3C191d5a74800A99D8747fdffAea42F60f7d3Bff).wards(ORACLE_WALLET01), 1);
        // assertEq(OsmAbstract(0xa6A7f2408949cAbD13f254F8e77ad5C9896725aB).wards(ORACLE_WALLET01), 1);
        // assertEq(OsmAbstract(0xA410A66313F943d022b79f2943C9A37CefdE2371).wards(ORACLE_WALLET01), 1);
        // assertEq(OsmAbstract(0x0ce19eA2C568890e63083652f205554C927a0caa).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0xf1a5b808fbA8fF80982dACe88020d4a80c91aFe6).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0xFADF05B56E4b211877248cF11C0847e7F8924e10).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0x044c9aeD56369aA3f696c898AEd0C38dC53c6C3D).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0xEf22289E240cFcCCdCD2B98fdefF167da10f452d).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0x2fc2706C61Fba5b941381e8838bC646908845db6).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0x974f7f4dC6D91f144c87cc03749c98f85F997bc7).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0x11C884B3FEE1494A666Bb20b6F6144387beAf4A6).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0xB18BC24e52C23A77225E7cf088756581EE257Ad8).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0x54ADcaB9B99b1B548764dAB637db751eC66835F0).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0x916fc346910fd25867c81874f7F982a1FB69aac7).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0xD375daC26f7eF991878136b387ca959b9ac1DDaF).wards(ORACLE_WALLET01), 1);
        // assertEq(OsmAbstract(0x838212865E2c2f4F7226fCc0A3EFc3EB139eC661).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0x1fA3B8DAeE1BCEe33990f66F1a99993daD14D855).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0xE7de200a3a29E9049E378b52BD36701A0Ce68C3b).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0x323eac5246d5BcB33d66e260E882fC9bF4B6bf41).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0xAafF0066D05cEe0D6a38b4dac77e73d9E0a5Cf46).wards(ORACLE_WALLET01), 1);
        assertEq(OsmAbstract(0xe9245D25F3265E9A36DcCDC72B0B5dE1eeACD4cD).wards(ORACLE_WALLET01), 1);

        assertEq(OsmAbstract(0xF15993A5C5BE496b8e1c9657Fd2233b579Cd3Bc6).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0x2BA78cb27044edCb715b03685D4bf74261170a70).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0xc3d677a5451cAFED13f748d822418098593D3599).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0x94588e35fF4d2E99ffb8D5095F35d1E37d6dDf12).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0xF953cdebbbf63607EeBc556438d86F2e1d47C8aA).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0x6Fb18806ff87B45220C2DB0941709142f2395069).wards(ORACLE_WALLET02), 1);
        // assertEq(OsmAbstract(0x57A00620Ba1f5f81F20565ce72df4Ad695B389d7).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0xCB772363E2DEc06942edbc5E697F4A9114B5989c).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0x75B4e743772D25a7998F4230cb016ddCF2c52629).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0x5AD3A560BB125d00db8E94915232BA8f6166967C).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0x001eDD66a5Cc9268159Cf24F3dC0AdcE456AAAAb).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0xDe112F61b823e776B3439f2F39AfF41f57993045).wards(ORACLE_WALLET02), 1);
        // assertEq(OsmAbstract(0xdF8474337c9D3f66C0b71d31C7D3596E4F517457).wards(ORACLE_WALLET02), 1);
        // assertEq(OsmAbstract(0xdF8474337c9D3f66C0b71d31C7D3596E4F517457).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0xE7de200a3a29E9049E378b52BD36701A0Ce68C3b).wards(ORACLE_WALLET02), 1);
        // assertEq(OsmAbstract(0x95282c2cDE88b93F784E2485f885580275551387).wards(ORACLE_WALLET02), 1);
        // assertEq(OsmAbstract(0xF1E8E72AE116193A9fA551beC1cda965147b31DA).wards(ORACLE_WALLET02), 1);
        // assertEq(OsmAbstract(0x27E599C9D69e02477f5ffF4c8E4E42B97777eE52).wards(ORACLE_WALLET02), 1);
        // assertEq(OsmAbstract(0x3C191d5a74800A99D8747fdffAea42F60f7d3Bff).wards(ORACLE_WALLET02), 1);
        // assertEq(OsmAbstract(0xa6A7f2408949cAbD13f254F8e77ad5C9896725aB).wards(ORACLE_WALLET02), 1);
        // assertEq(OsmAbstract(0xA410A66313F943d022b79f2943C9A37CefdE2371).wards(ORACLE_WALLET02), 1);
        // assertEq(OsmAbstract(0x0ce19eA2C568890e63083652f205554C927a0caa).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0xf1a5b808fbA8fF80982dACe88020d4a80c91aFe6).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0xFADF05B56E4b211877248cF11C0847e7F8924e10).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0x044c9aeD56369aA3f696c898AEd0C38dC53c6C3D).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0xEf22289E240cFcCCdCD2B98fdefF167da10f452d).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0x2fc2706C61Fba5b941381e8838bC646908845db6).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0x974f7f4dC6D91f144c87cc03749c98f85F997bc7).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0x11C884B3FEE1494A666Bb20b6F6144387beAf4A6).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0xB18BC24e52C23A77225E7cf088756581EE257Ad8).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0x54ADcaB9B99b1B548764dAB637db751eC66835F0).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0x916fc346910fd25867c81874f7F982a1FB69aac7).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0xD375daC26f7eF991878136b387ca959b9ac1DDaF).wards(ORACLE_WALLET02), 1);
        // assertEq(OsmAbstract(0x838212865E2c2f4F7226fCc0A3EFc3EB139eC661).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0x1fA3B8DAeE1BCEe33990f66F1a99993daD14D855).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0xE7de200a3a29E9049E378b52BD36701A0Ce68C3b).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0x323eac5246d5BcB33d66e260E882fC9bF4B6bf41).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0xAafF0066D05cEe0D6a38b4dac77e73d9E0a5Cf46).wards(ORACLE_WALLET02), 1);
        assertEq(OsmAbstract(0xe9245D25F3265E9A36DcCDC72B0B5dE1eeACD4cD).wards(ORACLE_WALLET02), 1);
    }

    function testSpellIsCast_GENERAL() public {
        string memory description = new DssSpell().description();
        assertTrue(bytes(description).length > 0, "TestError/spell-description-length");
        // DS-Test can't handle strings directly, so cast to a bytes32.
        assertEq(stringToBytes32(spell.description()),
                stringToBytes32(description), "TestError/spell-description");

        if(address(spell) != address(spellValues.deployed_spell)) {
            assertEq(spell.expiration(), block.timestamp + spellValues.expiration_threshold, "TestError/spell-expiration");
        } else {
            assertEq(spell.expiration(), spellValues.deployed_spell_created + spellValues.expiration_threshold, "TestError/spell-expiration");

            // If the spell is deployed compare the on-chain bytecode size with the generated bytecode size.
            // extcodehash doesn't match, potentially because it's address-specific, avenue for further research.
            address depl_spell = spellValues.deployed_spell;
            address code_spell = address(new DssSpell());
            assertEq(getExtcodesize(depl_spell), getExtcodesize(code_spell), "TestError/spell-codesize");
        }

        assertTrue(spell.officeHours() == spellValues.office_hours_enabled, "TestError/spell-office-hours");

        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done(), "TestError/spell-not-done");

        checkSystemValues(afterSpell);

        checkCollateralValues(afterSpell);
    }

    function testRemoveChainlogValues() private {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        try chainLog.getAddress("XXX") {
            assertTrue(false);
        } catch Error(string memory errmsg) {
            assertTrue(cmpStr(errmsg, "dss-chain-log/invalid-key"));
        } catch {
            assertTrue(false);
        }
    }

    function testCollateralIntegrations() private { // make public to use
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Insert new collateral tests here
        checkIlkIntegration(
            "TOKEN-X",
            GemJoinAbstract(addr.addr("MCD_JOIN_TOKEN_X")),
            ClipAbstract(addr.addr("MCD_CLIP_TOKEN_X")),
            addr.addr("PIP_TOKEN"),
            true,
            true,
            false
        );
    }

    function testLerpSurplusBuffer() private { // make public to use
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Insert new SB lerp tests here

        LerpAbstract lerp = LerpAbstract(lerpFactory.lerps("NAME"));

        uint256 duration = 210 days;
        hevm.warp(block.timestamp + duration / 2);
        assertEq(vow.hump(), 60 * MILLION * RAD);
        lerp.tick();
        assertEq(vow.hump(), 75 * MILLION * RAD);
        hevm.warp(block.timestamp + duration / 2);
        lerp.tick();
        assertEq(vow.hump(), 90 * MILLION * RAD);
        assertTrue(lerp.done());
    }

    function testNewChainlogValues() public { // make public to use
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Insert new chainlog values tests here
        assertEq(chainLog.getAddress("FLASH_KILLER"), addr.addr("FLASH_KILLER"));
        assertEq(chainLog.version(), "1.11.0");
    }

    function testNewIlkRegistryValues() private { // make public to use
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Insert new ilk registry values tests here
        assertEq(reg.pos("TOKEN-X"), 47);
        assertEq(reg.join("TOKEN-X"), addr.addr("MCD_JOIN_TOKEN_X"));
        assertEq(reg.gem("TOKEN-X"), addr.addr("TOKEN"));
        assertEq(reg.dec("TOKEN-X"), GemAbstract(addr.addr("TOKEN")).decimals());
        assertEq(reg.class("TOKEN-X"), 1);
        assertEq(reg.pip("TOKEN-X"), addr.addr("PIP_TOKEN"));
        assertEq(reg.xlip("TOKEN-X"), addr.addr("MCD_CLIP_TOKEN_X"));
        //assertEq(reg.name("TOKEN-X"), "NAME"); // Token Name Not Present (DSToken, ONLY ON GOERLI)
        assertEq(reg.symbol("TOKEN-X"), "SYMBOL");
    }

    function testFailWrongDay() public {
        require(spell.officeHours() == spellValues.office_hours_enabled);
        if (spell.officeHours()) {
            vote(address(spell));
            scheduleWaitAndCastFailDay();
        } else {
            revert("Office Hours Disabled");
        }
    }

    function testFailTooEarly() public {
        require(spell.officeHours() == spellValues.office_hours_enabled);
        if (spell.officeHours()) {
            vote(address(spell));
            scheduleWaitAndCastFailEarly();
        } else {
            revert("Office Hours Disabled");
        }
    }

    function testFailTooLate() public {
        require(spell.officeHours() == spellValues.office_hours_enabled);
        if (spell.officeHours()) {
            vote(address(spell));
            scheduleWaitAndCastFailLate();
        } else {
            revert("Office Hours Disabled");
        }
    }

    function testOnTime() public {
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
    }

    function testCastCost() public {
        vote(address(spell));
        spell.schedule();

        castPreviousSpell();
        hevm.warp(spell.nextCastTime());
        uint256 startGas = gasleft();
        spell.cast();
        uint256 endGas = gasleft();
        uint256 totalGas = startGas - endGas;

        assertTrue(spell.done());
        // Fail if cast is too expensive
        assertTrue(totalGas <= 10 * MILLION);
    }

    // The specific date doesn't matter that much since function is checking for difference between warps
    function test_nextCastTime() public {
        hevm.warp(1606161600); // Nov 23, 20 UTC (could be cast Nov 26)

        vote(address(spell));
        spell.schedule();

        uint256 monday_1400_UTC = 1606744800; // Nov 30, 2020
        uint256 monday_2100_UTC = 1606770000; // Nov 30, 2020

        // Day tests
        hevm.warp(monday_1400_UTC);                                    // Monday,   14:00 UTC
        assertEq(spell.nextCastTime(), monday_1400_UTC);               // Monday,   14:00 UTC

        if (spell.officeHours()) {
            hevm.warp(monday_1400_UTC - 1 days);                       // Sunday,   14:00 UTC
            assertEq(spell.nextCastTime(), monday_1400_UTC);           // Monday,   14:00 UTC

            hevm.warp(monday_1400_UTC - 2 days);                       // Saturday, 14:00 UTC
            assertEq(spell.nextCastTime(), monday_1400_UTC);           // Monday,   14:00 UTC

            hevm.warp(monday_1400_UTC - 3 days);                       // Friday,   14:00 UTC
            assertEq(spell.nextCastTime(), monday_1400_UTC - 3 days);  // Able to cast

            hevm.warp(monday_2100_UTC);                                // Monday,   21:00 UTC
            assertEq(spell.nextCastTime(), monday_1400_UTC + 1 days);  // Tuesday,  14:00 UTC

            hevm.warp(monday_2100_UTC - 1 days);                       // Sunday,   21:00 UTC
            assertEq(spell.nextCastTime(), monday_1400_UTC);           // Monday,   14:00 UTC

            hevm.warp(monday_2100_UTC - 2 days);                       // Saturday, 21:00 UTC
            assertEq(spell.nextCastTime(), monday_1400_UTC);           // Monday,   14:00 UTC

            hevm.warp(monday_2100_UTC - 3 days);                       // Friday,   21:00 UTC
            assertEq(spell.nextCastTime(), monday_1400_UTC);           // Monday,   14:00 UTC

            // Time tests
            uint256 castTime;

            for(uint256 i = 0; i < 5; i++) {
                castTime = monday_1400_UTC + i * 1 days; // Next day at 14:00 UTC
                hevm.warp(castTime - 1 seconds); // 13:59:59 UTC
                assertEq(spell.nextCastTime(), castTime);

                hevm.warp(castTime + 7 hours + 1 seconds); // 21:00:01 UTC
                if (i < 4) {
                    assertEq(spell.nextCastTime(), monday_1400_UTC + (i + 1) * 1 days); // Next day at 14:00 UTC
                } else {
                    assertEq(spell.nextCastTime(), monday_1400_UTC + 7 days); // Next monday at 14:00 UTC (friday case)
                }
            }
        }
    }

    function testFail_notScheduled() public view {
        spell.nextCastTime();
    }

    function test_use_eta() public {
        hevm.warp(1606161600); // Nov 23, 20 UTC (could be cast Nov 26)

        vote(address(spell));
        spell.schedule();

        uint256 castTime = spell.nextCastTime();
        assertEq(castTime, spell.eta());
    }

    function test_Medianizers() private { // make public to use
        vote(address(spell));
        scheduleWaitAndCast(address(spell));
        assertTrue(spell.done());

        // Track Median authorizations here
        address SET_TOKEN    = address(0);
        address TOKENUSD_MED = OsmAbstract(addr.addr("PIP_TOKEN")).src();
        assertEq(MedianAbstract(TOKENUSD_MED).bud(SET_TOKEN), 1);
    }

    function test_auth() public {
        checkAuth(false);
    }

    function test_auth_in_sources() public {
        checkAuth(true);
    }

    // Verifies that the bytecode of the action of the spell used for testing
    // matches what we'd expect.
    //
    // Not a complete replacement for Etherscan verification, unfortunately.
    // This is because the DssSpell bytecode is non-deterministic because it
    // deploys the action in its constructor and incorporates the action
    // address as an immutable variable--but the action address depends on the
    // address of the DssSpell which depends on the address+nonce of the
    // deploying address. If we had a way to simulate a contract creation by
    // an arbitrary address+nonce, we could verify the bytecode of the DssSpell
    // instead.
    //
    // Vacuous until the deployed_spell value is non-zero.
    function test_bytecode_matches() public {
        address expectedAction = (new DssSpell()).action();
        address actualAction   = spell.action();
        uint256 expectedBytecodeSize;
        uint256 actualBytecodeSize;
        assembly {
            expectedBytecodeSize := extcodesize(expectedAction)
            actualBytecodeSize   := extcodesize(actualAction)
        }

        uint256 metadataLength = getBytecodeMetadataLength(expectedAction);
        assertTrue(metadataLength <= expectedBytecodeSize);
        expectedBytecodeSize -= metadataLength;

        metadataLength = getBytecodeMetadataLength(actualAction);
        assertTrue(metadataLength <= actualBytecodeSize);
        actualBytecodeSize -= metadataLength;

        assertEq(actualBytecodeSize, expectedBytecodeSize);
        uint256 size = actualBytecodeSize;
        uint256 expectedHash;
        uint256 actualHash;
        assembly {
            let ptr := mload(0x40)

            extcodecopy(expectedAction, ptr, 0, size)
            expectedHash := keccak256(ptr, size)

            extcodecopy(actualAction, ptr, 0, size)
            actualHash := keccak256(ptr, size)
        }
        assertEq(expectedHash, actualHash);
    }
}
