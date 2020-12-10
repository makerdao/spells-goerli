    // add a TOKEN-LETTER specific section with the correct addressess
    DSTokenAbstract            token = DSTokenAbstract();
    GemJoinAbstract  joinTOKENLETTER = GemJoinAbstract();
    FlipAbstract     flipTOKENLETTER = FlipAbstract();
    OsmAbstract             pipTOKEN = OsmAbstract();
    MedianAbstract    medTOKENLETTER = MedianAbstract();

        // add to the end of the list of collateral tests
        // change the values as appropriate
        afterSpell.collaterals["TOKEN-LETTER"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         4 * MILLION,
            dust:         100,
            pct:          500,
            chop:         1300,
            dunk:         500,
            mat:          17500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });

    // this will tests a new collateral addition. Reaplace all occurences
    // of TOKEN with the appropriate collateral, and LETTER with the appropriate
    // letter.  Also replace lowercase token with the appropriate letter.
    function testSpellIsCast_TOKEN_INTEGRATION() public {
        vote();
        scheduleWaitAndCast();
        assertTrue(spell.done());

        pipTOKEN.poke();
        hevm.warp(now + 3601);
        pipTOKEN.poke();
        spot.poke("TOKEN-LETTER");

        // Check faucet amount
        uint256 faucetAmount = faucet.amt(address(token));
        uint256 faucetAmountWad = faucetAmount * (10 ** (18 - token.decimals()));
        assertTrue(faucetAmount > 0);
        faucet.gulp(address(token));
        assertEq(token.balanceOf(address(this)), faucetAmount);

        // Check median matches pip.src()
        assertEq(pipTOKEN.src(), address(medTOKENLETTER));

        // Authorization
        assertEq(joinTOKENLETTER.wards(pauseProxy), 1);
        assertEq(vat.wards(address(joinTOKENLETTER)), 1);
        assertEq(flipTOKENLETTER.wards(address(end)), 1);
        assertEq(flipTOKENLETTER.wards(address(flipMom)), 1);
        assertEq(pipTOKEN.wards(address(osmMom)), 1);
        assertEq(pipTOKEN.bud(address(spot)), 1);
        assertEq(pipTOKEN.bud(address(end)), 1);
        assertEq(MedianAbstract(pipTOKEN.src()).bud(address(pipTOKEN)), 1);

        // Join to adapter
        assertEq(vat.gem("TOKEN-LETTER", address(this)), 0);
        token.approve(address(joinTOKENLETTER), faucetAmount);
        joinTOKENLETTER.join(address(this), faucetAmount);
        assertEq(token.balanceOf(address(this)), 0);
        assertEq(vat.gem("TOKEN-LETTER", address(this)), faucetAmountWad);

        // Deposit collateral, generate DAI
        assertEq(vat.dai(address(this)), 0);
        vat.frob("TOKEN-LETTER", address(this), address(this), address(this), int(faucetAmountWad), int(100 * WAD));
        assertEq(vat.gem("TOKEN-LETTER", address(this)), 0);
        assertEq(vat.dai(address(this)), 100 * RAD);

        // Payback DAI, withdraw collateral
        vat.frob("TOKEN-LETTER", address(this), address(this), address(this), -int(faucetAmountWad), -int(100 * WAD));
        assertEq(vat.gem("TOKEN-LETTER", address(this)), faucetAmountWad);
        assertEq(vat.dai(address(this)), 0);

        // Withdraw from adapter
        joinTOKENLETTER.exit(address(this), faucetAmount);
        assertEq(token.balanceOf(address(this)), faucetAmount);
        assertEq(vat.gem("TOKEN-LETTER", address(this)), 0);

        // Generate new DAI to force a liquidation
        token.approve(address(joinTOKENLETTER), faucetAmount);
        joinTOKENLETTER.join(address(this), faucetAmount);
        (,,uint256 spotV,,) = vat.ilks("TOKEN-LETTER");
        // dart max amount of DAI
        vat.frob("TOKEN-LETTER", address(this), address(this), address(this), int(faucetAmountWad), int(mul(faucetAmount, spotV) / RAY));
        hevm.warp(now + 1);
        jug.drip("TOKEN-LETTER");
        assertEq(flipTOKENLETTER.kicks(), 0);
        cat.bite("TOKEN-LETTER", address(this));
        assertEq(flipTOKENLETTER.kicks(), 1);
    }

