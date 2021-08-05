import "lib/dss-interfaces/src/dapp/DSPauseAbstract.sol";
import "lib/dss-interfaces/src/dapp/DSTokenAbstract.sol";
import "lib/dss-interfaces/src/dss/ChainlogAbstract.sol";
import "lib/dss-interfaces/src/dss/VatAbstract.sol";
import "lib/dss-interfaces/src/dss/SpotAbstract.sol";
import "lib/dss-interfaces/src/dss/FlipAbstract.sol";
import "lib/dss-interfaces/src/dss/JugAbstract.sol";
import "lib/dss-interfaces/src/dss/CatAbstract.sol";
import "lib/dss-interfaces/src/dss/IlkRegistryAbstract.sol";
import "lib/dss-interfaces/src/dss/FaucetAbstract.sol";
import "lib/dss-interfaces/src/dss/GemJoinAbstract.sol";
import "lib/dss-interfaces/src/dss/OsmMomAbstract.sol";
import "lib/dss-interfaces/src/dss/OsmMomAbstract.sol";
import "lib/dss-interfaces/src/dss/MedianAbstract.sol";
import "lib/dss-interfaces/src/dss/DssAutoLineAbstract.sol";

contract SpellAction {
    // Goerli ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    //  against the current release list at:
    //     https://changelog.makerdao.com/releases/goerli/active/contracts.json
    ChainlogAbstract constant CHANGELOG =
        ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);

    address constant TOKEN = ;
    address constant MCD_JOIN_TOKEN_LETTER = ;
    address constant MCD_FLIP_TOKEN_LETTER = ;
    address constant PIP_TOKEN = ;
    bytes32 constant ILK_TOKEN_A = "TOKEN-LETTER";

    // decimals & precision
    uint256 constant THOUSAND = 10**3;
    uint256 constant MILLION  = 10**6;
    uint256 constant WAD      = 10**18;
    uint256 constant RAY      = 10**27;
    uint256 constant RAD      = 10**45;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmefQMseb3AiTapiAKKexdKHig8wroKuZbmLtPLv4u2YwW
    //
    uint256 constant public X_PERCENT_RATE = ;

    function execute() external {
        address MCD_VAT      = CHANGELOG.getAddress("MCD_VAT");
        address MCD_CAT      = CHANGELOG.getAddress("MCD_CAT");
        address MCD_JUG      = CHANGELOG.getAddress("MCD_JUG");
        address MCD_SPOT     = CHANGELOG.getAddress("MCD_SPOT");
        address MCD_POT      = CHANGELOG.getAddress("MCD_POT");
        address MCD_END      = CHANGELOG.getAddress("MCD_END");
        address FLIPPER_MOM  = CHANGELOG.getAddress("FLIPPER_MOM");
        address OSM_MOM      = CHANGELOG.getAddress("OSM_MOM"); // Only if PIP_TOKEN = Osm
        address ILK_REGISTRY = CHANGELOG.getAddress("ILK_REGISTRY");
        address FAUCET       = CHANGELOG.getAddress("FAUCET");

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_TOKEN_LETTER).vat() == MCD_VAT, "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_TOKEN_LETTER).ilk() == ILK_TOKEN_A, "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_TOKEN_LETTER).gem() == TOKEN, "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_TOKEN_LETTER).dec() == DSTokenAbstract(TOKEN).decimals(), "join-dec-not-match");
        require(FlipAbstract(MCD_FLIP_TOKEN_LETTER).vat() == MCD_VAT, "flip-vat-not-match");
        require(FlipAbstract(MCD_FLIP_TOKEN_LETTER).cat() == MCD_CAT, "flip-cat-not-match");
        require(FlipAbstract(MCD_FLIP_TOKEN_LETTER).ilk() == ILK_TOKEN_A, "flip-ilk-not-match");

        // Set the TOKEN PIP in the Spotter
        SpotAbstract(MCD_SPOT).file(ILK_TOKEN_A, "pip", PIP_TOKEN);

        // Set the TOKEN-LETTER Flipper in the Cat
        CatAbstract(MCD_CAT).file(ILK_TOKEN_A, "flip", MCD_FLIP_TOKEN_LETTER);

        // Init TOKEN-LETTER ilk in Vat & Jug
        VatAbstract(MCD_VAT).init(ILK_TOKEN_A);
        JugAbstract(MCD_JUG).init(ILK_TOKEN_A);

        // Allow TOKEN-LETTER Join to modify Vat registry
        VatAbstract(MCD_VAT).rely(MCD_JOIN_TOKEN_LETTER);
        // Allow the TOKEN-LETTER Flipper to reduce the Cat litterbox on deal()
        CatAbstract(MCD_CAT).rely(MCD_FLIP_TOKEN_LETTER);
        // Allow Cat to kick auctions in TOKEN-LETTER Flipper
        FlipAbstract(MCD_FLIP_TOKEN_LETTER).rely(MCD_CAT);
        // Allow End to yank auctions in TOKEN-LETTER Flipper
        FlipAbstract(MCD_FLIP_TOKEN_LETTER).rely(MCD_END);
        // Allow FlipperMom to access to the TOKEN-LETTER Flipper
        FlipAbstract(MCD_FLIP_TOKEN_LETTER).rely(FLIPPER_MOM);
        // Disallow Cat to kick auctions in TOKEN-LETTER Flipper
        // !!!!!!!! Only for certain collaterals that do not trigger liquidations like USDC-A)
        FlipperMomAbstract(FLIPPER_MOM).deny(MCD_FLIP_TOKEN_LETTER);

        // Allow OsmMom to access to the TOKEN Osm
        // !!!!!!!! Only if PIP_TOKEN = Osm and hasn't been already relied due a previous deployed ilk
        OsmAbstract(PIP_TOKEN).rely(OSM_MOM);
        // Whitelist Osm to read the Median data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_TOKEN = Osm, its src is a Median and hasn't been already whitelisted due a previous deployed ilk
        MedianAbstract(OsmAbstract(PIP_TOKEN).src()).kiss(PIP_TOKEN);
        // Whitelist Spotter to read the Osm data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_TOKEN = Osm or PIP_TOKEN = Median and hasn't been already whitelisted due a previous deployed ilk
        OsmAbstract(PIP_TOKEN).kiss(MCD_SPOT);
        // Whitelist End to read the Osm data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_TOKEN = Osm or PIP_TOKEN = Median and hasn't been already whitelisted due a previous deployed ilk
        OsmAbstract(PIP_TOKEN).kiss(MCD_END);
        // Set TOKEN Osm in the OsmMom for new ilk
        // !!!!!!!! Only if PIP_TOKEN = Osm
        OsmMomAbstract(OSM_MOM).setOsm(ILK_TOKEN_A, PIP_TOKEN);

        // Set the global debt ceiling
        VatAbstract(MCD_VAT).file("Line", VatAbstract(MCD_VAT).Line() + X * MILLION * RAD);
        // Set the TOKEN-LETTER debt ceiling
        VatAbstract(MCD_VAT).file(ILK_TOKEN_A, "line", X * MILLION * RAD);
        // Set the TOKEN-LETTER dust
        VatAbstract(MCD_VAT).file(ILK_TOKEN_A, "dust", X * RAD);
        // Set the Lot size
        CatAbstract(MCD_CAT).file(ILK_TOKEN_A, "dunk", X * THOUSAND * RAD);
        // Set the TOKEN-LETTER liquidation penalty (e.g. 13% => X = 113)
        CatAbstract(MCD_CAT).file(ILK_TOKEN_A, "chop", X * WAD / 100);
        // Set the TOKEN-LETTER stability fee (e.g. 1% = 1000000000315522921573372069)
        JugAbstract(MCD_JUG).file(ILK_TOKEN_A, "duty", X_PERCENT_RATE);
        // Set the TOKEN-LETTER percentage between bids (e.g. 3% => X = 103)
        FlipAbstract(MCD_FLIP_TOKEN_LETTER).file("beg", X * WAD / 100);
        // Set the TOKEN-LETTER time max time between bids
        FlipAbstract(MCD_FLIP_TOKEN_LETTER).file("ttl", X hours);
        // Set the TOKEN-LETTER max auction duration to
        FlipAbstract(MCD_FLIP_TOKEN_LETTER).file("tau", X hours);
        // Set the TOKEN-LETTER min collateralization ratio (e.g. 150% => X = 150)
        SpotAbstract(MCD_SPOT).file(ILK_TOKEN_A, "mat", X * RAY / 100);

        // Update TOKEN-LETTER spot value in Vat
        SpotAbstract(MCD_SPOT).poke(ILK_TOKEN_A);

        // Add new ilk to the IlkRegistry
        IlkRegistryAbstract(ILK_REGISTRY).add(MCD_JOIN_TOKEN_LETTER);

        // Set gulp amount in faucet on Goerli (only use WAD for decimals = 18)
        FaucetAbstract(FAUCET).setAmt(TOKEN, X * WAD);

        CHANGELOG.setAddress("TOKEN", TOKEN);
        CHANGELOG.setAddress("MCD_JOIN_TOKEN_LETTER", MCD_JOIN_TOKEN_LETTER);
        CHANGELOG.setAddress("MCD_FLIP_TOKEN_LETTER", MCD_FLIP_TOKEN_LETTER);
        CHANGELOG.setAddress("PIP_TOKEN", PIP_TOKEN);

        // Bump version
        CHANGELOG.setVersion("X.X.X");
    }
}
