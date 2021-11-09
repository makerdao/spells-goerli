pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "./SpellsGoerliLocal.sol";

contract SpellsGoerliLocalTest is DSTest {
    SpellsGoerliLocal local;

    function setUp() public {
        local = new SpellsGoerliLocal();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
