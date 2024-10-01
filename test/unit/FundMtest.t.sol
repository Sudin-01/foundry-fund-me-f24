// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address User = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployfundMe = new DeployFundMe();
        fundMe = deployfundMe.run();
        vm.deal(User, STARTING_BALANCE);
    }

    function testMinimumUSdisFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testfundMetestOwner() public view {
        console.log(fundMe.i_owner());
        console.log(msg.sender);

        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedisAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundfailsWithoutEnoughEther() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(User);
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountfunded = fundMe.getAddressToAmountFunded(User);
        assertEq(amountfunded, SEND_VALUE);
    }

    function testsAddFunderToArray() public {
        vm.prank(User);
        fundMe.fund{value: SEND_VALUE}();

        address fundme = fundMe.getFunder(0);
        assertEq(fundme, User);
    }

    modifier funded() {
        vm.prank(User);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdrawl() public funded {
        vm.prank(User);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawlWithSinglFunder() public funded {
        //arrange
        //uint256 startGas = gasleft();
        //vm.txGasPrice(GAS_PRICE);

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        //uint256 endGas = gasleft();

        // uint256 gasUsed = (startGas - endGas) * tx.gasprice;
        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawlWithMultipleFunder() public funded {
        uint160 numberOfFunders = 10;

        for (uint160 i = 1; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        //arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //assert
        assert(address(fundMe).balance == 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, fundMe.getOwner().balance);
    }

    function testWithdrawlWithMultipleFundercheaper() public funded {
        uint160 numberOfFunders = 10;

        for (uint160 i = 1; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        //arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheapwithdrawl();
        vm.stopPrank();

        //assert
        assert(address(fundMe).balance == 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, fundMe.getOwner().balance);
    }
}
