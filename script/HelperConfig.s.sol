// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockERC20} from "../test/mocks/MockERC20.sol";

contract HelperConfig is Script {
    struct Config {
        uint256 minimumFundAmount;
        address usdcTokenAddress;
        address usdtTokenAddress;
    }
    Config public activeConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeConfig = getSepoliaEthConfig();
        } else {
            activeConfig = getOrCreateAnvilETHConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (Config memory) {
        Config memory config = Config({
            minimumFundAmount: 0.01 ether,
            usdcTokenAddress: 0xf08A50178dfcDe18524640EA6618a1f965821715,
            usdtTokenAddress: 0xA1d7f71cbBb361A77820279958BAC38fC3667c1a
            // minimumTokenAmount: 20000  // 0.02 USDC/USDT (6 decimals: 0.02 * 10^6)
        });
        return config;
    }

    function getOrCreateAnvilETHConfig() public returns (Config memory) {
        // Only deploy mocks if they haven't been set yet
        if (activeConfig.usdcTokenAddress != address(0)) {
            return activeConfig;
        }
        vm.startBroadcast();
        // Deploy mock USDC with 6 decimals
        MockERC20 mockUsdc = new MockERC20("USD Coin", "USDC", 6);
        // Deploy mock USDT with 6 decimals
        MockERC20 mockUsdt = new MockERC20("Tether USD", "USDT", 6);
        vm.stopBroadcast();

        Config memory config = Config({
            minimumFundAmount: 0.01 ether,
            // minimumTokenAmount: 20000,  // 0.02 USDC/USDT (6 decimals)
            usdcTokenAddress: address(mockUsdc),
            usdtTokenAddress: address(mockUsdt)
        });
        return config;
    }

    function getActiveConfig() public view returns (Config memory) {
        return activeConfig;
    }
}
