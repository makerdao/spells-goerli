pragma solidity ^0.5.15;

import "ds-test/test.sol";

import "./DssLaunchKovan.sol";

contract DssLaunchKovanTest is DSTest {
    DssLaunchKovan kovan;

    function setUp() public {
        kovan = new DssLaunchKovan();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
