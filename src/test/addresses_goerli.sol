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

contract Addresses {

    mapping (bytes32 => address) public addr;

    constructor() {
        addr["CHANGELOG"]                       = 0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F;
        addr["MULTICALL"]                       = 0xb8c864B60e9467398800Df34da39BF4f0c459461;
        addr["FAUCET"]                          = 0xa473CdDD6E4FAc72481dc36f39A409D86980D187;
        addr["MCD_DEPLOY"]                      = 0xc09880a0D6d06fa18C8bDC9dF2E203F0d0124fa1;
        addr["JOIN_FAB"]                        = 0x0aaA1E0f026c194E0F951a7763F9edc796c6eDeE;
        addr["FLIP_FAB"]                        = 0x333Ec4d92b546d6107Dc931156139A76dFAfD938;
        addr["CLIP_FAB"]                        = 0xcfAab43101A01548A95F0f7dBB0CeF6f6490A389;
        addr["CALC_FAB"]                        = 0x579f007Fb7151162e3095606232ef9029E090366;
        addr["LERP_FAB"]                        = 0xE7988B75a19D8690272D65882Ab0D07D492f7002;
        addr["MCD_GOV"]                         = 0xc5E4eaB513A7CD12b2335e8a0D57273e13D499f7;
        addr["PIP_MKR"]                         = 0x496C851B2A9567DfEeE0ACBf04365F3ba00Eb8dC;
        addr["GOV_GUARD"]                       = 0xB9b861e8F9b29322815260B6883Bbe1DBC91dA8A;
        addr["MCD_IOU"]                         = 0x651D1B91e4F657392a51Dba7A6A1A1a72eC6aD1c;
        addr["MCD_ADM"]                         = 0x33Ed584fc655b08b2bca45E1C5b5f07c98053bC1;
        addr["VOTE_PROXY_FACTORY"]              = 0x1a7c1ee5eE2A3B67778ff1eA8c719A3fA1b02b6f;
        addr["VOTE_DELEGATE_PROXY_FACTORY"]     = 0xE2d249AE3c156b132C40D07bd4d34e73c1712947;
        addr["MCD_VAT"]                         = 0xB966002DDAa2Baf48369f5015329750019736031;
        addr["MCD_JUG"]                         = 0xC90C99FE9B5d5207A03b9F28A6E8A19C0e558916;
        addr["MCD_CAT"]                         = 0xd744377001FD3411d7d0018F66E2271CB215f6fd;
        addr["MCD_DOG"]                         = 0x5cf85A37Dbd28A239698B4F9aA9a03D55C04F292;
        addr["MCD_VOW"]                         = 0x23f78612769b9013b3145E43896Fa1578cAa2c2a;
        addr["MCD_JOIN_DAI"]                    = 0x6a60b7070befb2bfc964F646efDF70388320f4E0;
        addr["MCD_FLAP"]                        = 0x584491031764f94a97a0f98bBe536B004Ab9467b;
        addr["FLAPPER_MOM"]                     = 0x7316C080BFd1c8857605627a251A2F0ae511E4A1;
        addr["MCD_FLOP"]                        = 0x742D041dFBA61110Bd886509CB299DF6A521B352;
        addr["MCD_PAUSE"]                       = 0xefcd235B1f13e7fC5eab1d05C910d3c390b3439F;
        addr["MCD_PAUSE_PROXY"]                 = 0x5DCdbD3cCF9B09EAAD03bc5f50fA2B3d3ACA0121;
        addr["MCD_GOV_ACTIONS"]                 = 0x5857F3e0e6Fb75658037b3c3410b7446b985B353;
        addr["MCD_DAI"]                         = 0x11fE4B6AE13d2a6055C8D9cF65c55bac32B5d844;
        addr["MCD_SPOT"]                        = 0xACe2A9106ec175bd56ec05C9E38FE1FDa8a1d758;
        addr["MCD_POT"]                         = 0x50672F0a14B40051B65958818a7AcA3D54Bd81Af;
        addr["MCD_END"]                         = 0xb82F60bAf6980b9fE035A82cF6Acb770C06d3896;
        addr["MCD_CURE"]                        = 0xFA5d993DdA243A57eefbbF86Cb3a1c817Dfc7e4E;
        addr["MCD_ESM"]                         = 0x023A960cb9BE7eDE35B433256f4AfE9013334b55;
        addr["PROXY_ACTIONS"]                   = 0x4023f89983Ece35e227c49806aFc13Bc0248d178;
        addr["PROXY_ACTIONS_END"]               = 0xBbA4aBF0a12738f093cFD2199C5497044bAa68A8;
        addr["PROXY_ACTIONS_DSR"]               = 0x15679CdbDb284fe07Eff3809150126697c6e3Dd6;
        addr["CDP_MANAGER"]                     = 0xdcBf58c9640A7bd0e062f8092d70fb981Bb52032;
        addr["DSR_MANAGER"]                     = 0xF7F0de3744C82825D77EdA8ce78f07A916fB6bE7;
        addr["GET_CDPS"]                        = 0x7843fd599F5382328DeBB45255deB3E2e0DEC876;
        addr["ILK_REGISTRY"]                    = 0x525FaC4CEc48a4eF2FBb0A72355B6255f8D5f79e;
        addr["OSM_MOM"]                         = 0xEdB6b497D2e18A33130CB0D2b70343E6Dcd9EE86;
        addr["FLIPPER_MOM"]                     = 0x7ceCdf6b214a3eBA1589eB8B844fB6Cb12B67Bd7;
        addr["CLIPPER_MOM"]                     = 0xC67fFD490903521F778b2A3B2A13D0FC0Be96F98;
        addr["LINE_MOM"]                        = 0x5D54E2d56BA83C42f63a10642DcFa073EBD9D92E;
        addr["MCD_IAM_AUTO_LINE"]               = 0x21DaD87779D9FfA8Ed3E1036cBEA8784cec4fB83;
        addr["MCD_FLASH"]                       = 0xAa5F7d5b29Fa366BB04F6E4c39ACF569d5214075;
        addr["MCD_FLASH_LEGACY"]                = 0x0a6861D6200B519a8B9CFA1E7Edd582DD1573581;
        addr["FLASH_KILLER"]                    = 0xa95FaD7948079df3c579DDb0752E39dC29Eb1AFf;
        addr["PROXY_FACTORY"]                   = 0x84eFB9c18059394172D0d69A3E58B03320001871;
        addr["PROXY_REGISTRY"]                  = 0x46759093D8158db8BB555aC7C6F98070c56169ce;
        addr["MCD_VEST_DAI"]                    = 0x7520970Bd0f63D4EA4AA5E4Be05F22e0b8b09BD4;
        addr["MCD_VEST_DAI_LEGACY"]             = 0x59B1a603cAC9e38EA2AC2C479FFE42Ce48123Fd4;
        addr["MCD_VEST_MKR"]                    = 0x183bE7a75B8b5F35236270b060e95C65D82f5fF9;
        addr["MCD_VEST_MKR_TREASURY"]           = 0xd1B8dFF41F3268fAC524869f4C7dA27232044916;
        addr["ETH"]                             = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
        addr["PIP_ETH"]                         = 0x94588e35fF4d2E99ffb8D5095F35d1E37d6dDf12;
        addr["MCD_JOIN_ETH_A"]                  = 0x2372031bB0fC735722AA4009AeBf66E8BEAF4BA1;
        addr["MCD_CLIP_ETH_A"]                  = 0x2603c6EC5878dC70f53aD3a90e4330ba536d2385;
        addr["MCD_CLIP_CALC_ETH_A"]             = 0xfD7d0BaB582EC2FA031A0d0a6Aee6493934b1B04;
        addr["MCD_JOIN_ETH_B"]                  = 0x1710BB6dF1967679bb1f247135794692F7963B46;
        addr["MCD_CLIP_ETH_B"]                  = 0xA5d173b77965F2A58B0686b5683f3277de8d3D66;
        addr["MCD_CLIP_CALC_ETH_B"]             = 0xa4b7e9E5E342af456378576e46a52670E4f58517;
        addr["MCD_JOIN_ETH_C"]                  = 0x16e6490744d4B3728966f8e72416c005EB3dEa79;
        addr["MCD_CLIP_ETH_C"]                  = 0xDdAfCbed3A02617EbE1eEAC86eae701870747649;
        addr["MCD_CLIP_CALC_ETH_C"]             = 0xB90197A17d9A90ECa634954e393F51ec74DBa93f;
        addr["BAT"]                             = 0x75645f86e90a1169e697707C813419977ea26779;
        addr["PIP_BAT"]                         = 0x2BA78cb27044edCb715b03685D4bf74261170a70;
        addr["MCD_JOIN_BAT_A"]                  = 0xfea8C23D32e4bA46d90AeD2445fBD099010eAdF5;
        addr["MCD_CLIP_BAT_A"]                  = 0x4B05c2A4EEef04D1eed017B9003a344bbDeb19DE;
        addr["MCD_CLIP_CALC_BAT_A"]             = 0xE1C16d3D5BC91E091A23Ad0a467D1c47DA53ED73;
        addr["USDC"]                            = 0x6Fb5ef893d44F4f88026430d82d4ef269543cB23;
        addr["PIP_USDC"]                        = 0x838212865E2c2f4F7226fCc0A3EFc3EB139eC661;
        addr["MCD_JOIN_USDC_A"]                 = 0x33E88C8b3530e2f19050b24f44AcB78C7114AF46;
        addr["MCD_CLIP_USDC_A"]                 = 0xA8566b54C3447A741B2aE6bF920859600507AC1A;
        addr["MCD_CLIP_CALC_USDC_A"]            = 0x3a278aA4264AD66c5DEaAfbC1fCf6E43ceD47325;
        addr["MCD_JOIN_USDC_B"]                 = 0x0Dc70CC4505c1952e719C9C740608A75Ca9e299e;
        addr["MCD_CLIP_USDC_B"]                 = 0x71e44e17359fFbC3626893D13A133870FEc9Fee6;
        addr["MCD_CLIP_CALC_USDC_B"]            = 0xae3c77F36436Ac242bf2BC3E1A271058529F207A;
        addr["MCD_JOIN_PSM_USDC_A"]             = 0xF2f86B76d1027f3777c522406faD710419C80bbB;
        addr["MCD_CLIP_PSM_USDC_A"]             = 0x8f570B146655Cd52173B0db2DDeb40B7b32c5A9C;
        addr["MCD_CLIP_CALC_PSM_USDC_A"]        = 0x6eB7f16842b13A1Fbb270Fc952Fb9a73D7c90a0e;
        addr["MCD_PSM_USDC_A"]                  = 0xb480B8dD5A232Cb7B227989Eacda728D1F247dB6;
        addr["TUSD"]                            = 0xe0B3D300E2e09c1Fd01252287dDbC70A7730ffB0;
        addr["PIP_TUSD"]                        = 0x0ce19eA2C568890e63083652f205554C927a0caa;
        addr["MCD_JOIN_TUSD_A"]                 = 0x5BC597f00d74fAcEE53Be784f0B7Ace63b4e2EBe;
        addr["MCD_CLIP_TUSD_A"]                 = 0x22d843aE7121F399604D5C00863B95F9Af7e7E9C;
        addr["MCD_CLIP_CALC_TUSD_A"]            = 0xD4443E7CcB1Cf40DbE4E27C60Aef82054c7d27B3;
        addr["WBTC"]                            = 0x7ccF0411c7932B99FC3704d68575250F032e3bB7;
        addr["PIP_WBTC"]                        = 0xE7de200a3a29E9049E378b52BD36701A0Ce68C3b;
        addr["MCD_JOIN_WBTC_A"]                 = 0x3cbE712a12e651eEAF430472c0C1BF1a2a18939D;
        addr["MCD_CLIP_WBTC_A"]                 = 0x752c35fa3d21863257bbBCB7e2B344fd0948B61b;
        addr["MCD_CLIP_CALC_WBTC_A"]            = 0x87982983Bb0B843Ba41D593A3722E87734bb1d7F;
        addr["MCD_JOIN_WBTC_B"]                 = 0x13B8EB3d2d40A00d65fD30abF247eb470dDF6C25;
        addr["MCD_CLIP_WBTC_B"]                 = 0x4F51B15f8B86822d2Eca8a74BB4bA1e3c64F733F;
        addr["MCD_CLIP_CALC_WBTC_B"]            = 0x1b5a9aDaf15CAE0e3d0349be18b77180C1a0deCc;
        addr["MCD_JOIN_WBTC_C"]                 = 0xe15E69F10E1A362F69d9672BFeA20B75CFf8574A;
        addr["MCD_CLIP_WBTC_C"]                 = 0xDa3cd88f5FF7D2B9ED6Ab171C8218421916B6e10;
        addr["MCD_CLIP_CALC_WBTC_C"]            = 0xD26B140fdaA11c23b09230c24cBe71f456AC7ab6;
        addr["ZRX"]                             = 0x96E0C18524789ED3e62CD9F56aAEc7cEAC78725a;
        addr["PIP_ZRX"]                         = 0xe9245D25F3265E9A36DcCDC72B0B5dE1eeACD4cD;
        addr["MCD_JOIN_ZRX_A"]                  = 0xC279765B3f930742167dB91271f13353336B6C72;
        addr["MCD_CLIP_ZRX_A"]                  = 0xeF5931608d21D49fF014E17C8cfDD8d51c90b388;
        addr["MCD_CLIP_CALC_ZRX_A"]             = 0xA514d3dC8B7697a0Df26200591cfeaCF42e2DE6f;
        addr["KNC"]                             = 0x9A58801cf901486Df9323bcE83A7684915DBAE54;
        addr["PIP_KNC"]                         = 0xCB772363E2DEc06942edbc5E697F4A9114B5989c;
        addr["MCD_JOIN_KNC_A"]                  = 0xA48f0d5DA642928BC1F5dB9De5F5d3D466500075;
        addr["MCD_CLIP_KNC_A"]                  = 0x777871Fde2845a52F455642f5da2f7AC17563739;
        addr["MCD_CLIP_CALC_KNC_A"]             = 0x404521f9FB3ba305cd7a0DCbD9f86E4Bec9ad21d;
        addr["MANA"]                            = 0x347fceA8b4fD1a46e2c0DB8F79e22d293c2F8513;
        addr["PIP_MANA"]                        = 0x001eDD66a5Cc9268159Cf24F3dC0AdcE456AAAAb;
        addr["MCD_JOIN_MANA_A"]                 = 0xF4a1E7Dd685b4EaFBE5d0E70e20c153dee2E290b;
        addr["MCD_CLIP_MANA_A"]                 = 0x09231df919ce19E48bf552a33D9e7FaD9c939025;
        addr["MCD_CLIP_CALC_MANA_A"]            = 0xD14d44fE5006d4eb61E194256462E1593eb8DF2f;
        addr["USDT"]                            = 0x5858f25cc225525A7494f76d90A6549749b3030B;
        addr["PIP_USDT"]                        = 0x1fA3B8DAeE1BCEe33990f66F1a99993daD14D855;
        addr["MCD_JOIN_USDT_A"]                 = 0xa8C62cC41AbF8A199FB484Ea363b90C3e9E01d86;
        addr["MCD_CLIP_USDT_A"]                 = 0x057eF98FAf86562ce9aBc3Ad2e07Fd65B653cBFB;
        addr["MCD_CLIP_CALC_USDT_A"]            = 0x2e6cD41fc9B62190A9081a69cd1167ab59E0e89d;
        addr["PAXUSD"]                          = 0x4547863912Fe2d17D3827704138957a8317E8dCD;
        addr["PAX"]                             = 0x4547863912Fe2d17D3827704138957a8317E8dCD;
        addr["PIP_PAXUSD"]                      = 0xdF8474337c9D3f66C0b71d31C7D3596E4F517457;
        addr["PIP_PAX"]                         = 0xdF8474337c9D3f66C0b71d31C7D3596E4F517457;
        addr["MCD_JOIN_PAXUSD_A"]               = 0x8Ef390647A74150a79EC73FE120EaaF8bE9eEdf0;
        addr["MCD_CLIP_PAXUSD_A"]               = 0x80cb788cf316361B0998C3a831c9ea82C5274F6D;
        addr["MCD_CLIP_CALC_PAXUSD_A"]          = 0x8EE38002052CA938646F653831E9a6Af6Cc8BeBf;
        addr["MCD_JOIN_PSM_PAX_A"]              = 0xF27E1F580D5e82510b47C7B2A588A8A533787d38;
        addr["MCD_CLIP_PSM_PAX_A"]              = 0xfe0b736a8bDc01869c94a0799CDD10683404D78f;
        addr["MCD_CLIP_CALC_PSM_PAX_A"]         = 0x1e14F8ED0f1a6A908cACabb290Ef71a69cDe1abf;
        addr["MCD_PSM_PAX_A"]                   = 0x934dAaa0778ee137993d2867340440d70a74A44e;
        addr["COMP"]                            = 0x8032dce0b793C21B8F7B648C01224c3b557271ED;
        addr["PIP_COMP"]                        = 0xc3d677a5451cAFED13f748d822418098593D3599;
        addr["MCD_JOIN_COMP_A"]                 = 0x544EFa934f26cd6FdFD86883408538150Bdd6725;
        addr["MCD_CLIP_COMP_A"]                 = 0x5fea7d7Fc72972D8bC65a49a5d19DfFF50f19d0D;
        addr["MCD_CLIP_CALC_COMP_A"]            = 0x782657Bf07cE2F100D14eD1cFa15151290947fCe;
        addr["LRC"]                             = 0xe32aC5b19051728421A8F4A8a5757D0e127a14F6;
        addr["PIP_LRC"]                         = 0x5AD3A560BB125d00db8E94915232BA8f6166967C;
        addr["MCD_JOIN_LRC_A"]                  = 0x12af538aCf746c0BBe076E5eBAE678e022E1F5f6;
        addr["MCD_CLIP_LRC_A"]                  = 0xe5C499CBB12fA65db469496e5966aCcBA5Fff3b9;
        addr["MCD_CLIP_CALC_LRC_A"]             = 0x238AbB8f221df1816d066b32b572066A320A13d0;
        addr["LINK"]                            = 0x4724A967A4F7E42474Be58AbdF64bF38603422FF;
        addr["PIP_LINK"]                        = 0x75B4e743772D25a7998F4230cb016ddCF2c52629;
        addr["MCD_JOIN_LINK_A"]                 = 0x4420FD4E5C414189708376F3fBAA4dCA6277369a;
        addr["MCD_CLIP_LINK_A"]                 = 0x42cbA983D2403003af554fec0e68dAC4920906CC;
        addr["MCD_CLIP_CALC_LINK_A"]            = 0xE3Cf29E132EFad92d604Fa5C86AA21b7c7fBB76e;
        addr["BAL"]                             = 0x8c6e73CA229AB3933426aDb5cc829c1E4928551d;
        addr["PIP_BAL"]                         = 0xF15993A5C5BE496b8e1c9657Fd2233b579Cd3Bc6;
        addr["MCD_JOIN_BAL_A"]                  = 0xb31cE33511c2CCEfBc1713A783042eE670Cf5930;
        addr["MCD_CLIP_BAL_A"]                  = 0x738040Bc6834835B04e80c3C3cB07f6010eab2e3;
        addr["MCD_CLIP_CALC_BAL_A"]             = 0xa798c71d899f4f687B51Cd3Dc6e461B3401eD76e;
        addr["YFI"]                             = 0xd9510EF268F8273C9b7514F0bfFe18Fe1EFC0d43;
        addr["PIP_YFI"]                         = 0xAafF0066D05cEe0D6a38b4dac77e73d9E0a5Cf46;
        addr["MCD_JOIN_YFI_A"]                  = 0xa318E65982E80F54486f71965A0C320858759299;
        addr["MCD_CLIP_YFI_A"]                  = 0x9B97923CDf21CdB898702EE6878960Db446Daa86;
        addr["MCD_CLIP_CALC_YFI_A"]             = 0x5682Dfc718107e5A81805fd089d2De422A130b93;
        addr["GUSD"]                            = 0x67aeF79654D8F6CF44FdC08949c308a4F6b3c45B;
        addr["PIP_GUSD"]                        = 0x57A00620Ba1f5f81F20565ce72df4Ad695B389d7;
        addr["MCD_JOIN_GUSD_A"]                 = 0x455451293100C5c5355db10512DEE81F75E45Edf;
        addr["MCD_CLIP_GUSD_A"]                 = 0xF535799F8b4Ac661cd33E37421A571c742ed9B19;
        addr["MCD_CLIP_CALC_GUSD_A"]            = 0x738EA932C2aFb1D8e47bebB7ed1c604399f2A99e;
        addr["MCD_JOIN_PSM_GUSD_A"]             = 0x4115fDa246e2583b91aD602213f2ac4fC6E437Ca;
        addr["MCD_CLIP_PSM_GUSD_A"]             = 0x7A58fF23D5437C99b44BB02D7e24213D6dA20DFa;
        addr["MCD_CLIP_CALC_PSM_GUSD_A"]        = 0xE99bd8c56d7B9d90A36C8a563a4CA375b144dD94;
        addr["MCD_PSM_GUSD_A"]                  = 0x3B2dBE6767fD8B4f8334cE3E8EC3E2DF8aB3957b;
        addr["UNI"]                             = 0x82D98aA89E391c6759012df39ccDA0d9d6b24143;
        addr["PIP_UNI"]                         = 0xf1a5b808fbA8fF80982dACe88020d4a80c91aFe6;
        addr["MCD_JOIN_UNI_A"]                  = 0x31aE6e37964f26f4112A8Fc70e0B680F18e4DC6A;
        addr["MCD_CLIP_UNI_A"]                  = 0xE177B027030c1F691031451534bea409ff27b080;
        addr["MCD_CLIP_CALC_UNI_A"]             = 0xf9367E7cC9e4E547772312E60E238C35B7016C41;
        addr["RENBTC"]                          = 0x30d0A215aef6DadA4771a2b30a59B842f969EfD4;
        addr["PIP_RENBTC"]                      = 0xE7de200a3a29E9049E378b52BD36701A0Ce68C3b;
        addr["MCD_JOIN_RENBTC_A"]               = 0xb4576162aC5d1bC7C69bA85F39e8f694d44d09D0;
        addr["MCD_CLIP_RENBTC_A"]               = 0xFEff5d71D665A4C0712cd87d802380958b7Eb333;
        addr["MCD_CLIP_CALC_RENBTC_A"]          = 0x621b1c98132d32c077EA23fe93eCB999d07Df20b;
        addr["AAVE"]                            = 0x251661BB7C6869165eF35810E5e1D25Ed57be2Fe;
        addr["PIP_AAVE"]                        = 0xC26E53eF1F71481DE53bfb77875Ffb3aCf4d91f0;
        addr["MCD_JOIN_AAVE_A"]                 = 0x71Ae3e3ac4412865A4E556230b92aB58d895b497;
        addr["MCD_CLIP_AAVE_A"]                 = 0x962271248Db1F4c31318c11a89FD3b11f6047f32;
        addr["MCD_CLIP_CALC_AAVE_A"]            = 0x56f390b5DF5dDeBC1aDAd5cFEB65202CC6e2eaB6;
        addr["MATIC"]                           = 0x5B3b6CF665Cc7B4552F4347623a2A9E00600CBB5;
        addr["PIP_MATIC"]                       = 0xDe112F61b823e776B3439f2F39AfF41f57993045;
        addr["MCD_JOIN_MATIC_A"]                = 0xeb680839564F0F9bFB96fE2dF47a31cE31689e63;
        addr["MCD_CLIP_MATIC_A"]                = 0x2082c825b5311A2612c12e6DaF7EFa3Fb37BACbD;
        addr["MCD_CLIP_CALC_MATIC_A"]           = 0xB2dF4Ed2f6a665656CE3405E8f75b9DE8A6E24e9;
        addr["STETH"]                           = 0x1643E812aE58766192Cf7D2Cf9567dF2C37e9B7F;
        addr["WSTETH"]                          = 0x6320cD32aA674d2898A68ec82e869385Fc5f7E2f;
        addr["PIP_WSTETH"]                      = 0x323eac5246d5BcB33d66e260E882fC9bF4B6bf41;
        addr["MCD_JOIN_WSTETH_A"]               = 0xF99834937715255079849BE25ba31BF8b5D5B45D;
        addr["MCD_CLIP_WSTETH_A"]               = 0x3673978974fC3fB1bA61aea0a6eb1Bac8e27182c;
        addr["MCD_CLIP_CALC_WSTETH_A"]          = 0xb4f2f0eDFc10e9084a8bba23d84aF2c23B312852;
        addr["MCD_JOIN_WSTETH_B"]               = 0x4a2dfbdFb0ea68823265FaB4dE55E22f751eD12C;
        addr["MCD_CLIP_WSTETH_B"]               = 0x11D962d87EB3718C8012b0A71627d60c923d36a8;
        addr["MCD_CLIP_CALC_WSTETH_B"]          = 0xF4ffD00E0821C28aE673B4134D142FD8e479b061;
        addr["UNIV2DAIETH"]                     = 0x5dD9dec52a16d4d1Df10a66ac71d4731c9Dad984;
        addr["PIP_UNIV2DAIETH"]                 = 0x044c9aeD56369aA3f696c898AEd0C38dC53c6C3D;
        addr["MCD_JOIN_UNIV2DAIETH_A"]          = 0x66931685b532CB4F31abfe804d2408dD34Cd419D;
        addr["MCD_CLIP_UNIV2DAIETH_A"]          = 0x76a4Ee8acEAAF7F92455277C6e10471F116ffF2c;
        addr["MCD_CLIP_CALC_UNIV2DAIETH_A"]     = 0x7DCA9CAE2Dc463eBBF05341727FB6ed181D690c2;
        addr["UNIV2WBTCETH"]                    = 0x7883a92ac3e914F3400e8AE6a2FF05E6BA4Bd403;
        addr["PIP_UNIV2WBTCETH"]                = 0xD375daC26f7eF991878136b387ca959b9ac1DDaF;
        addr["MCD_JOIN_UNIV2WBTCETH_A"]         = 0x345a29Db10Aa5CF068D61Bb20F74771eC7DF66FE;
        addr["MCD_CLIP_UNIV2WBTCETH_A"]         = 0x8520AA6784d51B1984B6f693f1Ea646368d9f868;
        addr["MCD_CLIP_CALC_UNIV2WBTCETH_A"]    = 0xab5B4759c8D28d05c4cd335a0315A52981F93D04;
        addr["UNIV2USDCETH"]                    = 0xD90313b3E43D9a922c71d26a0fBCa75A01Bb3Aeb;
        addr["PIP_UNIV2USDCETH"]                = 0x54ADcaB9B99b1B548764dAB637db751eC66835F0;
        addr["MCD_JOIN_UNIV2USDCETH_A"]         = 0x46267d84dA4D6e7b2F5A999518Cf5DAF91E204E3;
        addr["MCD_CLIP_UNIV2USDCETH_A"]         = 0x7424D5319172a3dC57add04dBb48E6323Da4B473;
        addr["MCD_CLIP_CALC_UNIV2USDCETH_A"]    = 0x83B20C43D92224E128c2b1e0ECb6305B1001FF4f;
        addr["UNIV2DAIUSDC"]                    = 0x260719B2ef507A86116FC24341ff0994F2097D42;
        addr["PIP_UNIV2DAIUSDC"]                = 0xEf22289E240cFcCCdCD2B98fdefF167da10f452d;
        addr["MCD_JOIN_UNIV2DAIUSDC_A"]         = 0x4CEEf4EB4988cb374B0b288D685AeBE4c6d4C41E;
        addr["MCD_CLIP_UNIV2DAIUSDC_A"]         = 0x04254C28c09C8a09c76653acA92538EC04954341;
        addr["MCD_CLIP_CALC_UNIV2DAIUSDC_A"]    = 0x3dB02f19D2d1609661f9bD774De23a962642F25B;
        addr["UNIV2ETHUSDT"]                    = 0xfcB32e1C4A4F1C820c9304B5CFfEDfB91aE2321C;
        addr["PIP_UNIV2ETHUSDT"]                = 0x974f7f4dC6D91f144c87cc03749c98f85F997bc7;
        addr["MCD_JOIN_UNIV2ETHUSDT_A"]         = 0x46A8f8e2C0B62f5D7E4c95297bB26a457F358C82;
        addr["MCD_CLIP_UNIV2ETHUSDT_A"]         = 0x4bBCD4dc8cD4bfc907268AB5AD3aE01e2567f0E1;
        addr["MCD_CLIP_CALC_UNIV2ETHUSDT_A"]    = 0x9e24c087EbBA685dFD4AF1fC6C31C414f6EfA74f;
        addr["UNIV2LINKETH"]                    = 0x3361fB8f923D1Aa1A45B2d2eD4B8bdF313a3dA0c;
        addr["PIP_UNIV2LINKETH"]                = 0x11C884B3FEE1494A666Bb20b6F6144387beAf4A6;
        addr["MCD_JOIN_UNIV2LINKETH_A"]         = 0x98B7023Aced6D8B889Ad7D340243C3F9c81E8c5F;
        addr["MCD_CLIP_UNIV2LINKETH_A"]         = 0x71c6d999c54AB5C91589F45Aa5F0E2E782647268;
        addr["MCD_CLIP_CALC_UNIV2LINKETH_A"]    = 0x30747d2D2f9C23CBCc2ff318c31C15A6f0AA78bF;
        addr["UNIV2UNIETH"]                     = 0xB80A38E50B2990Ac83e46Fe16631fFBb94F2780b;
        addr["PIP_UNIV2UNIETH"]                 = 0xB18BC24e52C23A77225E7cf088756581EE257Ad8;
        addr["MCD_JOIN_UNIV2UNIETH_A"]          = 0x52c31E3592352Cd0CBa20Fa73Da42584EC693283;
        addr["MCD_CLIP_UNIV2UNIETH_A"]          = 0xaBb1F3fBe1c404829BC1807D67126286a71b85dE;
        addr["MCD_CLIP_CALC_UNIV2UNIETH_A"]     = 0x663D47b5AF171D7b54dfB2A234406903307721b8;
        addr["UNIV2WBTCDAI"]                    = 0x3f78Bd3980c49611E5FA885f25Ca3a5fCbf0d7A0;
        addr["PIP_UNIV2WBTCDAI"]                = 0x916fc346910fd25867c81874f7F982a1FB69aac7;
        addr["MCD_JOIN_UNIV2WBTCDAI_A"]         = 0x04d23e99504d61050CAF46B4ce2dcb9D4135a7fD;
        addr["MCD_CLIP_UNIV2WBTCDAI_A"]         = 0xee139bB397211A21656046efb2c7a5b255d3bC07;
        addr["MCD_CLIP_CALC_UNIV2WBTCDAI_A"]    = 0xf89C3DDA6D0f496900ecC39e4a7D31075d360856;
        addr["UNIV2AAVEETH"]                    = 0xaF2CC6F46d1d0AB30dd45F59B562394c3E21e6f3;
        addr["PIP_UNIV2AAVEETH"]                = 0xFADF05B56E4b211877248cF11C0847e7F8924e10;
        addr["MCD_JOIN_UNIV2AAVEETH_A"]         = 0x73C4E5430768e24Fd704291699823f35953bbbA2;
        addr["MCD_CLIP_UNIV2AAVEETH_A"]         = 0xeA4F6DA7Ac68F9244FCDd13AE2C36647829AfCa0;
        addr["MCD_CLIP_CALC_UNIV2AAVEETH_A"]    = 0x14F4D6cB78632535230D1591121E35108bbBdAAA;
        addr["UNIV2DAIUSDT"]                    = 0xBF2C9aBbEC9755A0b6144051E19c6AD4e6fd6D71;
        addr["PIP_UNIV2DAIUSDT"]                = 0x2fc2706C61Fba5b941381e8838bC646908845db6;
        addr["MCD_JOIN_UNIV2DAIUSDT_A"]         = 0xBF70Ca17ce5032CCa7cD55a946e96f0E72f79452;
        addr["MCD_CLIP_UNIV2DAIUSDT_A"]         = 0xABB9ca15E7e261E255560153e312c98F638E57f4;
        addr["MCD_CLIP_CALC_UNIV2DAIUSDT_A"]    = 0xDD610087b4a029BD63e4990A6A29a077764B632B;
        addr["MIP21_LIQUIDATION_ORACLE"]        = 0x362dfE51E4f91a8257B8276435792095EE5d85C3;
        addr["RWA_TOKEN_FAB"]                   = 0x8FCe002C320E85e4D8c111E6f46ee4CDb3eBc67E;
        addr["RWA001"]                          = 0xeb7C7DE82c3b05BD4059f11aE8f43dD7f1595bce;
        addr["PIP_RWA001"]                      = 0x95282c2cDE88b93F784E2485f885580275551387;
        addr["MCD_JOIN_RWA001_A"]               = 0x088D6b3f68Bc4F93F90006A1356A21145EDD96E2;
        addr["RWA001_A_URN"]                    = 0xF1AAB03fc1d3588B5910a960f476DbE88D304b9B;
        addr["RWA001_A_INPUT_CONDUIT"]          = 0x4145774D007C88392118f32E2c31686faCc9486E;
        addr["RWA001_A_OUTPUT_CONDUIT"]         = 0x969b3701A17391f2906d8c5E5D816aBcD9D0f199;
        addr["RWA002"]                          = 0x09fE0aE289553010D6EcBdFF98cc9C08030dE3b8;
        addr["PIP_RWA002"]                      = 0xF1E8E72AE116193A9fA551beC1cda965147b31DA;
        addr["MCD_JOIN_RWA002_A"]               = 0xc0aeE42b5E77e931BAfd98EAdd321e704fD7CA1f;
        addr["RWA002_A_URN"]                    = 0xD6953949b2B4Ab5Be19ed6283F4ca0AaEDDffec5;
        addr["RWA002_A_INPUT_CONDUIT"]          = 0x1d3402B809095c3320296f3A77c4be20C3b74d47;
        addr["RWA002_A_OUTPUT_CONDUIT"]         = 0x1d3402B809095c3320296f3A77c4be20C3b74d47;
        addr["RWA003"]                          = 0x5cf15Cc2710aFc0EaBBD7e045f84F9556B204331;
        addr["PIP_RWA003"]                      = 0x27E599C9D69e02477f5ffF4c8E4E42B97777eE52;
        addr["MCD_JOIN_RWA003_A"]               = 0x83fA1F7c423112aBC6B340e32564460eDcf6AD74;
        addr["RWA003_A_URN"]                    = 0x438262Eb709d47b0B3d2524E75E63DBa9571962B;
        addr["RWA003_A_INPUT_CONDUIT"]          = 0x608050Cb6948A9835442E24a5B1964F76fd4acE4;
        addr["RWA003_A_OUTPUT_CONDUIT"]         = 0x608050Cb6948A9835442E24a5B1964F76fd4acE4;
        addr["RWA004"]                          = 0xA7fbA77c4d18e12d1F385E2dcFfb377c9dBD91d2;
        addr["PIP_RWA004"]                      = 0x3C191d5a74800A99D8747fdffAea42F60f7d3Bff;
        addr["MCD_JOIN_RWA004_A"]               = 0xA74036937413B799b2f620a3b6Ea61ad08F1D354;
        addr["RWA004_A_URN"]                    = 0x1527A3B844ca194783BDeab8DF4F9264D1A9F529;
        addr["RWA004_A_INPUT_CONDUIT"]          = 0x551837D1C1638944A97a6476ffCD1bE4E1391Fc9;
        addr["RWA004_A_OUTPUT_CONDUIT"]         = 0x551837D1C1638944A97a6476ffCD1bE4E1391Fc9;
        addr["RWA005"]                          = 0x650d168fC94B79Bb16898CAae773B0Ce1097Cc3F;
        addr["PIP_RWA005"]                      = 0xa6A7f2408949cAbD13f254F8e77ad5C9896725aB;
        addr["MCD_JOIN_RWA005_A"]               = 0xc5052A70e00983ffa6894679f1d9c0cDAFe28416;
        addr["RWA005_A_URN"]                    = 0x047E68a3c1F22f9BB3fB063b311dC76c6E308404;
        addr["RWA005_A_INPUT_CONDUIT"]          = 0x8347e6e08cAF1FB63428465b76BafD4Cf6fcA2e1;
        addr["RWA005_A_OUTPUT_CONDUIT"]         = 0x8347e6e08cAF1FB63428465b76BafD4Cf6fcA2e1;
        addr["RWA006"]                          = 0xf754FD6611852eE94AC0614c51B8692cAE9fEe9F;
        addr["PIP_RWA006"]                      = 0xA410A66313F943d022b79f2943C9A37CefdE2371;
        addr["MCD_JOIN_RWA006_A"]               = 0x5b4B7797FC41123578718AD4E3F04d1Bde9685DC;
        addr["RWA006_A_URN"]                    = 0xd0d2Ef46b64C07b5Ce4f2634a82984C1B3804C22;
        addr["RWA006_A_INPUT_CONDUIT"]          = 0xd2Ef07535267D17d2314894f7821A43e9700A02e;
        addr["RWA006_A_OUTPUT_CONDUIT"]         = 0xd2Ef07535267D17d2314894f7821A43e9700A02e;
        addr["RWA007"]                          = 0xD063270642ff718DA1c58E12BD6a2598f7e874B3;
        addr["PIP_RWA007"]                      = 0xEB87118831B52B53FF11430c71B946fEafC903a2;
        addr["MCD_JOIN_RWA007_A"]               = 0x9C9E33E22b683F789411288497f8DC560f1F0466;
        addr["RWA007_A_URN"]                    = 0xa1b1D392fCB99F8B39c7530a599bCfcd2f1fB22f;
        addr["RWA007_A_JAR"]                    = 0x708bC8bF869c336ab6f04cf6A62a86a8DFc5f7c4;
        addr["RWA007_A_INPUT_CONDUIT"]          = 0x1C3faBF61B470B0e9aA4Ca5F1A08fcf44ADAb414;
        addr["RWA007_A_JAR_INPUT_CONDUIT"]      = 0xA7ae4F30f237BB8E8975d22eD777778202F64c91;
        addr["RWA007_A_OUTPUT_CONDUIT"]         = 0x87EaB54D118529Eb15a4286b8A96455ECBdbFD27;
        addr["RWA007_A_OPERATOR"]               = 0x94cfBF071f8be325A5821bFeAe00eEbE9CE7c279;
        addr["RWA007_A_COINBASE_CUSTODY"]       = 0xC3acf3B96E46Aa35dBD2aA3BD12D23c11295E774;
        addr["RWA008"]                          = 0x9A900f506b88ae6C7F9C5fbEffC5AFEC24A6fAAA;
        addr["PIP_RWA008"]                      = 0x98e62fFAf27C022283cB492f1bB05AfdE877b5ac;
        addr["MCD_JOIN_RWA008_A"]               = 0x36fA17FA0b4Be214cDc04faD2587dC85a7c2c086;
        addr["RWA008_A_URN"]                    = 0xF50FE370839c295DADFADFCC5b6DC9b904604F7d;
        addr["RWA008_A_INPUT_CONDUIT"]          = 0x8c4295EF77e503E5fd0c8dE3f73985834bE85DE2;
        addr["RWA008_A_OUTPUT_CONDUIT"]         = 0x1aA21d2E39EC0da185CA04609c8868bC324d8553;
        addr["RWA009"]                          = 0xfD775125701524461580Bf865f33068E4710591b;
        addr["PIP_RWA009"]                      = 0xB78a90D7475e67F4e0Ac876C2e9b38AF2c538041;
        addr["MCD_JOIN_RWA009_A"]               = 0xE1ee48D4a7d28078a1BEb6b3C0fe8391669661Fb;
        addr["RWA009_A_URN"]                    = 0xd334bbA9172a6F615Be93d194d1322148fb5222e;
        addr["RWA009_A_JAR"]                    = 0xad4e1696d008A656F810498A974C5D3dC4A6150d;
        addr["RWA009_A_OUTPUT_CONDUIT"]         = 0x5DCdbD3cCF9B09EAAD03bc5f50fA2B3d3ACA0121;
        addr["RWA010"]                          = 0x003DD0D987a315C7AEe2611B9b753b383B7a35bF;
        addr["PIP_RWA010"]                      = 0x1C5f15c960B5e1F87041E5a0A8C9Aa9AB18a81B8;
        addr["MCD_JOIN_RWA010_A"]               = 0xeBAfcf1E0B1A6D0F91f41cD77d760AC56B431F05;
        addr["RWA010_A_URN"]                    = 0x59417853EA7B47017c1e2C644C848e8Ef99Afa51;
        addr["RWA010_A_OUTPUT_CONDUIT"]         = 0x8828D2B96fa09864851244a8a2434C5A9a7B7AbD;
        addr["RWA010_A_INPUT_CONDUIT"]          = 0x8828D2B96fa09864851244a8a2434C5A9a7B7AbD;
        addr["RWA011"]                          = 0x480e01A3621f557D99c75C4394Ac17238304e88C;
        addr["PIP_RWA011"]                      = 0xC2926108429d7Ac98f4ce59D5E3cc5d9657D31b1;
        addr["MCD_JOIN_RWA011_A"]               = 0xfc1b3879B259C3561F4E654759D2Fd6Ba3C995de;
        addr["RWA011_A_URN"]                    = 0x5A704B28d65a61E1070662B8cA353D260f36332E;
        addr["RWA011_A_OUTPUT_CONDUIT"]         = 0xcBd44c9Ec0D2b9c466887e700eD88D302281E098;
        addr["RWA011_A_INPUT_CONDUIT"]          = 0xcBd44c9Ec0D2b9c466887e700eD88D302281E098;
        addr["RWA012"]                          = 0x2E4378eF2A6822cfB0d154BA497B351e31C3B89b;
        addr["PIP_RWA012"]                      = 0x3d264f6dD5415E813cE945aA6a3680F9074b2191;
        addr["MCD_JOIN_RWA012_A"]               = 0x0D9a5a31f16164e256E4f8b616c9C57F9d5C12d7;
        addr["RWA012_A_URN"]                    = 0xa35F51d91311F60C904a02E1b0493Fc256A3F6e3;
        addr["RWA012_A_OUTPUT_CONDUIT"]         = 0xaef64c80712d5959f240BE1339aa639CDFA858Ff;
        addr["RWA012_A_INPUT_CONDUIT"]          = 0xaef64c80712d5959f240BE1339aa639CDFA858Ff;
        addr["RWA013"]                          = 0xc5Ac8B809a8De11D94b7Aa63b28b8fbBDF86Ea86;
        addr["PIP_RWA013"]                      = 0xB87331af849c6474a69dDA4A9b7DBD417020b683;
        addr["MCD_JOIN_RWA013_A"]               = 0xD67131c06e93eDF3839C3ec5Bd92FF5D93A1e3df;
        addr["RWA013_A_URN"]                    = 0xdC47d203753D3B5fb4fcD5900EBd96b0eC6761B6;
        addr["RWA013_A_OUTPUT_CONDUIT"]         = 0xc5A1418aC32B5f978460f1211B76B5D44e69B530;
        addr["RWA013_A_INPUT_CONDUIT"]          = 0xc5A1418aC32B5f978460f1211B76B5D44e69B530;
        addr["RWA014"]                          = 0x22a7440DCfF0E8881Ec93cE519c34C15feB2A09a;
        addr["PIP_RWA014"]                      = 0x0dC2eeaAbD3c8F6fD7FB62D690AfEEA8c7AE5A6F;
        addr["MCD_JOIN_RWA014_A"]               = 0xc7Ba0aBa8512199c816834351CC978cf684D7fD9;
        addr["RWA014_A_URN"]                    = 0xb475F63163aE3b0D5f6e30Dd914F5aA7204B1169;
        addr["RWA014_A_JAR"]                    = 0x398E36Ed3c6bEf85f78b03d08b1980c6c3dd5357;
        addr["RWA014_A_INPUT_CONDUIT_URN"]      = 0x3b749869f62694804B0411DA77F13e816C49A25F;
        addr["RWA014_A_INPUT_CONDUIT_JAR"]      = 0xa9C909eDD4ee06D625EaDD546CccDB1BB3e02D02;
        addr["RWA014_A_OUTPUT_CONDUIT"]         = 0x563c3CD928DB7cAf5B9872bFa2dd0E4F31158256;
        addr["RWA014_A_OPERATOR"]               = 0x3064D13712338Ee0E092b66Afb3B054F0b7779CB;
        addr["RWA014_A_COINBASE_CUSTODY"]       = 0x2E5F1f08EBC01d6136c95a40e19D4c64C0be772c;
        addr["RWA015"]                          = 0x8384c55389f1ab6345dd4EF5fF2eF791D4875D2A;
        addr["PIP_RWA015"]                      = 0x0E6Fa7bEAEff74403a72D5CeA803dcEA169C5048;
        addr["MCD_JOIN_RWA015_A"]               = 0x59ea019366FC8E8fBaf20EeA7F68F6557521FD20;
        addr["RWA015_A_URN"]                    = 0xf24456f7132479cdABBD67511D2e985cE69BFd0D;
        addr["RWA015_A_JAR"]                    = 0x3799FF53c20042BB9b0d2580Bc66257397e69CAE;
        addr["RWA015_A_INPUT_CONDUIT_URN"]      = 0xa737C5EB4aD00d30f92CFcdf3f92B8B1AE79383F;
        addr["RWA015_A_INPUT_CONDUIT_JAR"]      = 0xe7Bcb3E53db0E502B3E9127A703c44461ab2b09f;
        addr["RWA015_A_OUTPUT_CONDUIT"]         = 0xEff59711CbB16BCAdA3AA8B8f2Bbd26F5B38a8cA;
        addr["RWA015_A_OPERATOR"]               = 0x23a10f09Fac6CCDbfb6d9f0215C795F9591D7476;
        addr["RWA015_A_CUSTODY"]                = 0x65729807485F6f7695AF863d97D62140B7d69d83;
        addr["PROXY_PAUSE_ACTIONS"]             = 0x8D1187FCa9A104211bd25c689C08718AD8730C83;
        addr["PROXY_DEPLOYER"]                  = 0xc9476Fd378de5b0de5C4280D4323f6F89f723c15;
        addr["GUNIV3DAIUSDC1"]                  = 0xc5D83e829Ecdce4d67645EE1a1317451e0b4c68d;
        addr["PIP_GUNIV3DAIUSDC1"]              = 0xF953cdebbbf63607EeBc556438d86F2e1d47C8aA;
        addr["MCD_JOIN_GUNIV3DAIUSDC1_A"]       = 0xFBF4e3bB9B86d24F91Da185E6F4C8D903Fb63C86;
        addr["MCD_CLIP_GUNIV3DAIUSDC1_A"]       = 0xFb98C5A49eDd0888e85f6d2CCc7695b5202A6B32;
        addr["MCD_CLIP_CALC_GUNIV3DAIUSDC1_A"]  = 0x4652E3a6b4850a0fE50E60B0ac72aBd74199D973;
        addr["GUNIV3DAIUSDC2"]                  = 0x540BBCcb890cEb6c539fA94a0d63fF7a6aA25762;
        addr["MCD_JOIN_GUNIV3DAIUSDC2_A"]       = 0xbd039ea6d63AC57F2cD051202dC4fB6BA6681489;
        addr["MCD_CLIP_GUNIV3DAIUSDC2_A"]       = 0x39aee8F2D5ea5dffE4b84529f0349743C71C07c3;
        addr["MCD_CLIP_CALC_GUNIV3DAIUSDC2_A"]  = 0xbF87fbA8ec2190E50Da297815A9A6Ae668306aFE;
        addr["PIP_GUNIV3DAIUSDC2"]              = 0x6Fb18806ff87B45220C2DB0941709142f2395069;
        addr["PIP_DAI"]                         = 0xe7A915f8Db97f0dE219e0cEf60fF7886305a14ef;
        addr["MCD_CHARTER"]                     = 0x7ea0d7ea31C544a472b55D19112e016Ba6708288;
        addr["MCD_CHARTER_IMP"]                 = 0xf6a9bD36553208ee02049Dc8A9c44919383C9a6b;
        addr["PROXY_ACTIONS_CHARTER"]           = 0xfFb896D7BEf704DF73abc9A2EBf295CE236c5919;
        addr["PROXY_ACTIONS_END_CHARTER"]       = 0xDAdE5a1bAC92c539B886eeC82738Ff26b66Dc484;
        addr["MCD_JOIN_INST_ETH_A"]             = 0x99507A436aC9E8eB5A89001a2dFc80E343D82122;
        addr["MCD_CLIP_INST_ETH_A"]             = 0x6ECc35a9237a73022697976891Def7bAd87Be408;
        addr["MCD_CLIP_CALC_INST_ETH_A"]        = 0xea999A6381e78311Ff176751e00F46360F1562e9;
        addr["MCD_JOIN_INST_WBTC_A"]            = 0xbd5978308C9BbF6d8d1D26cD1df9AA3EA83F782a;
        addr["MCD_CLIP_INST_WBTC_A"]            = 0x81Bf27c821F24b6FC9Bcc0F7d4D7cc2651712E3c;
        addr["MCD_CLIP_CALC_INST_WBTC_A"]       = 0x32ff6F008eB4aA5780efF2e0436b7adCDECb213a;
        addr["MCD_JOIN_TELEPORT_FW_A"]          = 0xE2fddf4e0f5A4B6d0Cc1D162FBFbEF7B6c5D6f69;
        addr["MCD_ROUTER_TELEPORT_FW_A"]        = 0x5A16311D32662E71f1E0beAD41372f60cEb61b26;
        addr["MCD_ORACLE_AUTH_TELEPORT_FW_A"]   = 0x29d292E0773E484dbcA8626F432985630175763b;
        addr["STARKNET_TELEPORT_BRIDGE"]        = 0x6DcC2d81785B82f2d20eA9fD698d5738B5EE3589;
        addr["STARKNET_TELEPORT_FEE"]           = 0x95532D5c4e2064e8dC51F4D41C21f24B33c78BBC;
        addr["STARKNET_DAI_BRIDGE"]             = 0xaB00D7EE6cFE37cCCAd006cEC4Db6253D7ED3a22;
        addr["STARKNET_DAI_BRIDGE_LEGACY"]      = 0xd8beAa22894Cd33F24075459cFba287a10a104E4;
        addr["STARKNET_ESCROW"]                 = 0x38c3DDF1eF3e045abDDEb94f4e7a1a0d5440EB44;
        addr["STARKNET_ESCROW_MOM"]             = 0x464379BD1aC523DdA45b7B78eCB1F703661cad2a;
        addr["STARKNET_GOV_RELAY"]              = 0x8919aefA417745F22c6af5AD6550E83159a373F3;
        addr["STARKNET_GOV_RELAY_LEGACY"]       = 0x73c0049Dd6560E644984Fa3Af30A55a02a7D81fB;
        addr["STARKNET_CORE"]                   = 0xde29d060D45901Fb19ED6C6e959EB22d8626708e;
        addr["OPTIMISM_TELEPORT_BRIDGE"]        = 0x5d49a6BCEc49072D1612cA6d60c8D7985cfc4988;
        addr["OPTIMISM_TELEPORT_FEE"]           = 0x89bcDc64090ddAbB9AFBeeFB7999d564e2875907;
        addr["OPTIMISM_DAI_BRIDGE"]             = 0x05a388Db09C2D44ec0b00Ee188cD42365c42Df23;
        addr["OPTIMISM_ESCROW"]                 = 0xbc892A208705862273008B2Fb7D01E968be42653;
        addr["OPTIMISM_GOV_RELAY"]              = 0xD9b2835A5bFC8bD5f54DB49707CF48101C66793a;
        addr["ARBITRUM_TELEPORT_BRIDGE"]        = 0x737D2B14571b58204403267A198BFa470F0D696e;
        addr["ARBITRUM_TELEPORT_FEE"]           = 0x89bcDc64090ddAbB9AFBeeFB7999d564e2875907;
        addr["ARBITRUM_DAI_BRIDGE"]             = 0x467194771dAe2967Aef3ECbEDD3Bf9a310C76C65;
        addr["ARBITRUM_ESCROW"]                 = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
        addr["ARBITRUM_GOV_RELAY"]              = 0x10E6593CDda8c58a1d0f14C5164B376352a55f2F;
        addr["RETH"]                            = 0x62BC478FFC429161115A6E4090f819CE5C50A5d9;
        addr["PIP_RETH"]                        = 0x27a25935D8b0006A97E11cAdDc2b3bf3a6721c13;
        addr["MCD_JOIN_RETH_A"]                 = 0xDEF7D394a4eD62273265CE983107B3748F775265;
        addr["MCD_CLIP_RETH_A"]                 = 0xBa496CB9637d56466dc112033BF28CC7EC544E3A;
        addr["MCD_CLIP_CALC_RETH_A"]            = 0xC3A95477616c9Db6C772179e74a9A717E8B148a7;
        addr["GNO"]                             = 0x86Bc432064d7F933184909975a384C7E4c9d0977;
        addr["PIP_GNO"]                         = 0xf15221A159A4e7ba01E0d6e72111F0Ddff8Fa8Da;
        addr["MCD_JOIN_GNO_A"]                  = 0x05a3b9D5F8098e558aF33c6b83557484f840055e;
        addr["MCD_CLIP_GNO_A"]                  = 0x8274F3badD42C61B8bEa78Df941813D67d1942ED;
        addr["MCD_CLIP_CALC_GNO_A"]             = 0x08Ae3e0C0CAc87E1B4187D53F0231C97B5b4Ab3E;
        addr["DIRECT_HUB"]                      = 0x79Dcb858D6af6FeD7A5AC9B189ea14bC94076dfb;
        addr["DIRECT_MOM"]                      = 0x8aBafFe006205e306F4307EE7b839846CD1ff471;
        addr["DIRECT_SPARK_DAI_POOL"]           = 0x8b6Ae79852bcae012CBc2244e4ef85c61BAeCE35;
        addr["DIRECT_SPARK_DAI_PLAN"]           = 0x1fB2cF94D896bB50A17dD1Abd901172F088dF309;
        addr["DIRECT_SPARK_DAI_ORACLE"]         = 0xa07C4eDB18E4B3cfB9B94D9CD348BbF6d5a7f4c2;
        addr["SUBPROXY_SPARK"]                  = 0x4e847915D8a9f2Ab0cDf2FC2FD0A30428F25665d;
    }
}

