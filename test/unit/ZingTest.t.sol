// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {SendFunds} from "../../src/Zing.sol";
import {DeployZing} from "../../script/DeployZing.s.sol";

contract ZingTest is Test {
    SendFunds public sendFundsContract;
    address usdcTokenAddress;
    address usdtTokenAddress;
    address USER = makeAddr("user");
    address DESTINATION = makeAddr("destination");

    uint256 constant USDC_AMOUNT = 10000000; // 10 USDC
    uint256 constant USDT_AMOUNT = 15000000; // 15 USDT
    uint256 constant TOKEN_TRANSFER_AMOUNT = 1000000; // 1 USDC
    uint256 constant STARTING_BALANCE = 20 ether;

    function setUp() public {
        DeployZing deployZing = new DeployZing();
        sendFundsContract = deployZing.run();
        usdcTokenAddress = deployZing.getUsdcTokenAddress();
        usdtTokenAddress = deployZing.getUsdtTokenAddress();
        deployZing.fundContractWithToken(
            sendFundsContract,
            usdcTokenAddress,
            USDC_AMOUNT
        );
        deployZing.fundContractWithToken(
            sendFundsContract,
            usdtTokenAddress,
            USDT_AMOUNT
        );
        vm.deal(USER, STARTING_BALANCE);
    }

    modifier funded() {
        vm.prank(sendFundsContract.getOwner());
        sendFundsContract.fundContract{value: STARTING_BALANCE}();
        _;
    }

    function testBalanceOnContractIsStartingBalance() public {
        vm.prank(sendFundsContract.getOwner());
        sendFundsContract.fundContract{value: STARTING_BALANCE}();
        vm.prank(sendFundsContract.getOwner());
        assertEq(sendFundsContract.getContractBalance(), STARTING_BALANCE);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(sendFundsContract.getOwner(), msg.sender);
    }

    function testGetTokenBalanceFailsDueToInvalidAddress() public {
        vm.prank(sendFundsContract.getOwner());
        vm.expectRevert();
        assertEq(sendFundsContract.getTokenBalance(address(0)), 0);
    }

    function testGetUSDCTokenBalance() public {
        vm.prank(sendFundsContract.getOwner());
        assertEq(
            sendFundsContract.getTokenBalance(usdcTokenAddress),
            USDC_AMOUNT
        );
    }

    function testGetUSDTTokenBalance() public {
        vm.prank(sendFundsContract.getOwner());
        assertEq(
            sendFundsContract.getTokenBalance(usdtTokenAddress),
            USDT_AMOUNT
        );
    }

    function testSendFundsToDestination() public {
        vm.prank(sendFundsContract.getOwner());
        sendFundsContract.sendTokenToDestination(
            usdtTokenAddress,
            DESTINATION,
            TOKEN_TRANSFER_AMOUNT
        );
        vm.prank(sendFundsContract.getOwner());
        assertEq(
            sendFundsContract.getTokenBalance(usdtTokenAddress),
            USDT_AMOUNT - TOKEN_TRANSFER_AMOUNT
        );
    }

    function testSendTokenFailsDueToInsufficientBalance() public {
        vm.prank(sendFundsContract.getOwner());
        vm.expectRevert();
        sendFundsContract.sendTokenToDestination(
            usdtTokenAddress,
            DESTINATION,
            USDT_AMOUNT + USDT_AMOUNT
        );
    }

    function testSendEtherToDestination() public funded {
        vm.prank(sendFundsContract.getOwner());
        sendFundsContract.sendEtherToDestination(DESTINATION, 2 ether);
        vm.prank(sendFundsContract.getOwner());
        assertEq(
            sendFundsContract.getContractBalance(),
            STARTING_BALANCE - 2 ether
        );
    }
}
