pragma solidity 0.5.12;

import "lib/dss-interfaces/src/dss/VatAbstract.sol";
import "lib/dss-interfaces/src/dapp/DSPauseAbstract.sol";
import "lib/dss-interfaces/src/dss/JugAbstract.sol";
import "lib/dss-interfaces/src/dss/SpotAbstract.sol";
import "lib/dss-interfaces/src/dss/GemJoinAbstract.sol";
import "lib/dss-interfaces/src/dapp/DSTokenAbstract.sol";
import "lib/dss-interfaces/src/dss/ChainlogAbstract.sol";

interface RwaLiquidationLike {
    function wards(address) external returns (uint256);
    function ilks(bytes32) external returns (bytes32,address,uint48,uint48);
    function rely(address) external;
    function deny(address) external;
    function init(bytes32, uint256, string calldata, uint48) external;
    function tell(bytes32) external;
    function cure(bytes32) external;
    function cull(bytes32) external;
    function good(bytes32) external view;
}

interface RwaOutputConduitLike {
    function wards(address) external returns (uint256);
    function can(address) external returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function hope(address) external;
    function nope(address) external;
    function bud(address) external returns (uint256);
    function kiss(address) external;
    function diss(address) external;
    function pick(address) external;
    function push() external;
}

interface RwaUrnLike {
    function hope(address) external;
}

contract SpellAction {
    // KOVAN ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    // against the current release list at:
    //     https://changelog.makerdao.com/releases/kovan/latest/contracts.json
    ChainlogAbstract constant CHANGELOG =
        ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);

    /*
        OPERATOR: 0xD23beB204328D7337e3d2Fb9F150501fDC633B0e
        TRUST1: 0xda0fab060e6cc7b1C0AA105d29Bd50D71f036711
        TRUST2: 0xDA0111100cb6080b43926253AB88bE719C60Be13
        ILK: RWA001-A
        RWA001: 0x8F9A8cbBdfb93b72d646c8DEd6B4Fe4D86B315cB
        MCD_JOIN_RWA001_A: 0x029A554f252373e146f76Fa1a7455f73aBF4d38e
        RWA001_A_URN: 0x3Ba90D86f7E3218C48b7E0FCa959EcF43d9A30F4
        RWA001_A_INPUT_CONDUIT: 0xe37673730F03060922a2Bd8eC5987AfE3eA16a05
        RWA001_A_OUTPUT_CONDUIT: 0xc54fEee07421EAB8000AC8c921c0De9DbfbE780B
        MIP21_LIQUIDATION_ORACLE: 0x2881c5dF65A8D81e38f7636122aFb456514804CC
    */
    address constant RWA001_OPERATOR           = 0xD23beB204328D7337e3d2Fb9F150501fDC633B0e;
    address constant RWA001_GEM                = 0x8F9A8cbBdfb93b72d646c8DEd6B4Fe4D86B315cB;
    address constant MCD_JOIN_RWA001_A         = 0x029A554f252373e146f76Fa1a7455f73aBF4d38e;
    address constant RWA001_A_URN              = 0x3Ba90D86f7E3218C48b7E0FCa959EcF43d9A30F4;
    address constant RWA001_A_INPUT_CONDUIT    = 0xe37673730F03060922a2Bd8eC5987AfE3eA16a05;
    address constant RWA001_A_OUTPUT_CONDUIT   = 0xc54fEee07421EAB8000AC8c921c0De9DbfbE780B;
    address constant MIP21_LIQUIDATION_ORACLE  = 0x2881c5dF65A8D81e38f7636122aFb456514804CC;

    uint256 constant THREE_PCT_RATE  = 1000000000937303470807876289;

    // precision
    uint256 constant public THOUSAND = 10 ** 3;
    uint256 constant public MILLION  = 10 ** 6;
    uint256 constant public WAD      = 10 ** 18;
    uint256 constant public RAY      = 10 ** 27;
    uint256 constant public RAD      = 10 ** 45;

    uint256 constant RWA001_A_INITIAL_DC    = 1000 * RAD;
    uint256 constant RWA001_A_INITIAL_PRICE = 1060 * WAD;

    // MIP13c3-SP4 Declaration of Intent & Commercial Points -
    //   Off-Chain Asset Backed Lender to onboard Real World Assets
    //   as Collateral for a DAI loan
    //
    // https://ipfs.io/ipfs/QmdmAUTU3sd9VkdfTZNQM6krc9jsKgF2pz7W1qvvfJo1xk
    string constant DOC = "QmdmAUTU3sd9VkdfTZNQM6krc9jsKgF2pz7W1qvvfJo1xk";

    function execute() external {
        address MCD_VAT  = ChainlogAbstract(CHANGELOG).getAddress("MCD_VAT");
        address MCD_JUG  = ChainlogAbstract(CHANGELOG).getAddress("MCD_JUG");
        address MCD_SPOT = ChainlogAbstract(CHANGELOG).getAddress("MCD_SPOT");

        // RWA001-A collateral deploy

        // Set ilk bytes32 variable
        bytes32 ilk = "RWA001-A";

        // add RWA-001 contract to the changelog
        CHANGELOG.setAddress("RWA001", RWA001_GEM);
        CHANGELOG.setAddress("MCD_JOIN_RWA001_A", MCD_JOIN_RWA001_A);
        CHANGELOG.setAddress("MIP21_LIQUIDATION_ORACLE", MIP21_LIQUIDATION_ORACLE);
        CHANGELOG.setAddress("RWA001_A_URN", RWA001_A_URN);
        CHANGELOG.setAddress("RWA001_A_INPUT_CONDUIT", RWA001_A_INPUT_CONDUIT);
        CHANGELOG.setAddress("RWA001_A_OUTPUT_CONDUIT", RWA001_A_OUTPUT_CONDUIT);

        // bump changelog version
        // TODO make sure to update this version on mainnet
        // CHANGELOG.setVersion("1.2.9");

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_RWA001_A).vat() == MCD_VAT, "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA001_A).ilk() == ilk, "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA001_A).gem() == RWA001_GEM, "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA001_A).dec() == DSTokenAbstract(RWA001_GEM).decimals(), "join-dec-not-match");

        // init the RwaLiquidationOracle
        // doc: "doc"
        // tau: 5 minutes
        RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).init(
            ilk, RWA001_A_INITIAL_PRICE, DOC, 300
        );
        (,address pip,,) = RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).ilks(ilk);
        CHANGELOG.setAddress("PIP_RWA001", pip);

        // Set price feed for RWA001
        SpotAbstract(MCD_SPOT).file(ilk, "pip", pip);

        // Init RWA-001 in Vat
        VatAbstract(MCD_VAT).init(ilk);
        // Init RWA-001 in Jug
        JugAbstract(MCD_JUG).init(ilk);

        // Allow RWA-001 Join to modify Vat registry
        VatAbstract(MCD_VAT).rely(MCD_JOIN_RWA001_A);

        // Allow RwaLiquidationOracle to modify Vat registry
        VatAbstract(MCD_VAT).rely(MIP21_LIQUIDATION_ORACLE);

        // 1000 debt ceiling
        VatAbstract(MCD_VAT).file(ilk, "line", RWA001_A_INITIAL_DC);
        VatAbstract(MCD_VAT).file("Line", VatAbstract(MCD_VAT).Line() + RWA001_A_INITIAL_DC);

        // No dust
        // VatAbstract(MCD_VAT).file(ilk, "dust", 0)

        // 3% stability fee
        JugAbstract(MCD_JUG).file(ilk, "duty", THREE_PCT_RATE);

        // collateralization ratio 100%
        SpotAbstract(MCD_SPOT).file(ilk, "mat", RAY);

        // poke the spotter to pull in a price
        SpotAbstract(MCD_SPOT).poke(ilk);

        // give the urn permissions on the join adapter
        GemJoinAbstract(MCD_JOIN_RWA001_A).rely(RWA001_A_URN);

        // set up the urn
        RwaUrnLike(RWA001_A_URN).hope(RWA001_OPERATOR);

        // set up output conduit
        RwaOutputConduitLike(RWA001_A_OUTPUT_CONDUIT).hope(RWA001_OPERATOR);
        // could potentially kiss some BD addresses if they are available
    }
}

contract RwaSpell {

    ChainlogAbstract constant CHANGELOG =
        ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);

    DSPauseAbstract public pause =
        DSPauseAbstract(CHANGELOG.getAddress("MCD_PAUSE"));
    address         public action;
    bytes32         public tag;
    uint256         public eta;
    bytes           public sig;
    uint256         public expiration;
    bool            public done;

    string constant public description = "Kovan Spell Deploy";

    constructor() public {
        sig = abi.encodeWithSignature("execute()");
        action = address(new SpellAction());
        bytes32 _tag;
        address _action = action;
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
        expiration = block.timestamp + 30 days;
    }

    function schedule() public {
        require(block.timestamp <= expiration, "This contract has expired");
        require(eta == 0, "This spell has already been scheduled");
        eta = block.timestamp + DSPauseAbstract(pause).delay();
        pause.plot(action, tag, sig, eta);
    }

    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}
