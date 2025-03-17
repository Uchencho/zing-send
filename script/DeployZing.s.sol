// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {SendFunds} from "../src/Zing.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {MockERC20} from "../test/mocks/MockERC20.sol";

contract DeployZing is Script {
    HelperConfig helperConfig = new HelperConfig();
    HelperConfig.Config activeConfig = helperConfig.getActiveConfig();

    function run() external returns (SendFunds) {
        vm.startBroadcast();
        SendFunds sendFundsContract = new SendFunds(
            activeConfig.minimumFundAmount
        );
        vm.stopBroadcast();
        return sendFundsContract;
    }

    function getUsdcTokenAddress() public view returns (address) {
        return helperConfig.getActiveConfig().usdcTokenAddress;
    }

    function getUsdtTokenAddress() public view returns (address) {
        return helperConfig.getActiveConfig().usdtTokenAddress;
    }

    function fundContractWithToken(
        SendFunds sendFundsContract,
        address tokenAddress,
        uint256 amount
    ) external {
        MockERC20(tokenAddress).mint(address(sendFundsContract), amount);
    }
}
