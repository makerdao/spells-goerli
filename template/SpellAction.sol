contract SpellAction {
    address constant MCD_VAT = ;
    address constant MCD_CAT = ;
    address constant MCD_JUG = ;
    address constant MCD_SPOT = ;
    address constant MCD_POT = ;
    address constant MCD_END = ;
    address constant FLIPPER_MOM = ;
    address constant OSM_MOM = ; // Only if PIP_TOKEN = Osm
    address constant ILK_REGISTRY = ;
    address constant FAUCET = ;

    address constant TOKEN = ;
    address constant MCD_JOIN_TOKEN_LETTER = ;
    address constant MCD_FLIP_TOKEN_LETTER = ;
    address constant PIP_TOKEN = ;

    uint256 constant THOUSAND = 10**3;
    uint256 constant MILLION = 10**6;
    uint256 constant WAD = 10**18;
    uint256 constant RAY = 10**27;
    uint256 constant RAD = 10**45;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    uint256 constant public X_PERCENT_RATE = ;

    function execute() external {
        bytes32 ilk = "TOKEN-LETTER";

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_TOKEN_LETTER).vat() == MCD_VAT, "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_TOKEN_LETTER).ilk() == ilk, "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_TOKEN_LETTER).gem() == TOKEN, "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_TOKEN_LETTER).dec() == 18, "join-dec-not-match");
        require(FlipAbstract(MCD_FLIP_TOKEN_LETTER).vat() == MCD_VAT, "flip-vat-not-match");
        require(FlipAbstract(MCD_FLIP_TOKEN_LETTER).cat() == MCD_CAT, "flip-cat-not-match");
        require(FlipAbstract(MCD_FLIP_TOKEN_LETTER).ilk() == ilk, "flip-ilk-not-match");

        // Set the TOKEN PIP in the Spotter
        SpotAbstract(MCD_SPOT).file(ilk, "pip", PIP_TOKEN);

        // Set the TOKEN-LETTER Flipper in the Cat
        CatAbstract(MCD_CAT).file(ilk, "flip", MCD_FLIP_TOKEN_LETTER);

        // Init TOKEN-LETTER ilk in Vat & Jug
        VatAbstract(MCD_VAT).init(ilk);
        JugAbstract(MCD_JUG).init(ilk);

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
        OsmMomAbstract(OSM_MOM).setOsm(ilk, PIP_TOKEN);

        // Set the global debt ceiling
        VatAbstract(MCD_VAT).file("Line", X * MILLION * RAD);
        // Set the TOKEN-LETTER debt ceiling
        VatAbstract(MCD_VAT).file(ilk, "line", X * MILLION * RAD);
        // Set the TOKEN-LETTER dust
        VatAbstract(MCD_VAT).file(ilk, "dust", X * RAD);
        // Set the Lot size
        CatAbstract(MCD_CAT).file(ilk, "dunk", X * THOUSAND * RAD);
        // Set the TOKEN-LETTER liquidation penalty (e.g. 13% => X = 113)
        CatAbstract(MCD_CAT).file(ilk, "chop", X * WAD / 100);
        // Set the TOKEN-LETTER stability fee (e.g. 1% = 1000000000315522921573372069)
        JugAbstract(MCD_JUG).file(ilk, "duty", X_PERCENT_RATE);
        // Set the TOKEN-LETTER percentage between bids (e.g. 3% => X = 103)
        FlipAbstract(MCD_FLIP_TOKEN_LETTER).file("beg", X * WAD / 100);
        // Set the TOKEN-LETTER time max time between bids
        FlipAbstract(MCD_FLIP_TOKEN_LETTER).file("ttl", X hours);
        // Set the TOKEN-LETTER max auction duration to
        FlipAbstract(MCD_FLIP_TOKEN_LETTER).file("tau", X hours);
        // Set the TOKEN-LETTER min collateralization ratio (e.g. 150% => X = 150)
        SpotAbstract(MCD_SPOT).file(ilk, "mat", X * RAY / 100);

        // Update TOKEN-LETTER spot value in Vat
        SpotAbstract(MCD_SPOT).poke(ilk);

        // Add new ilk to the IlkRegistry
        IlkRegistryAbstract(ILK_REGISTRY).add(MCD_JOIN_TOKEN_LETTER);

        // Set gulp amount in faucet on kovan (only use WAD for decimals = 18)
        FaucetAbstract(FAUCET).setAmt(TOKEN, X * WAD);
    }
}
