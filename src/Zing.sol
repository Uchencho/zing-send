// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract SendFunds {
    using SafeERC20 for IERC20;

    error SendFunds__MinimumFundAmountNotMet(uint256 minimumFundAmount);
    error SendFunds__NotOwner(address sender, address owner);
    error SendFunds__FailedToSendFunds(address destinationAddress);
    error SendFunds__InvalidTokenAddress();
    error SendFunds__InsufficientTokenBalance(
        address tokenAddress,
        uint256 amount,
        uint256 contractBalance
    );

    uint256 private immutable i_minimumFundAmount;
    uint256 private immutable i_minimumTokenAmount;
    address private immutable i_owner;

    constructor(uint256 minimumFundAmount) {
        i_minimumFundAmount = minimumFundAmount;
        i_owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner)
            revert SendFunds__NotOwner(msg.sender, i_owner);
        _;
    }

    modifier validAddress(address addressToCheck) {
        if (addressToCheck == address(0))
            revert SendFunds__InvalidTokenAddress();
        _;
    }

    function fundContract() public payable {
        if (msg.value < i_minimumFundAmount) {
            revert SendFunds__MinimumFundAmountNotMet(i_minimumFundAmount);
        }
    }

    function sendEtherToDestination(
        address destinationAddress,
        uint256 amount
    ) public payable onlyOwner {
        (bool success, ) = payable(destinationAddress).call{value: amount}("");
        if (!success) {
            revert SendFunds__FailedToSendFunds(destinationAddress);
        }
    }

    function sendTokenToDestination(
        address tokenAddress,
        address destinationAddress,
        uint256 amount
    ) public onlyOwner validAddress(tokenAddress) {
        // Get reference to the token contract
        IERC20 token = IERC20(tokenAddress);

        // Check if the contract has enough token balance
        uint256 contractBalance = token.balanceOf(address(this));
        if (contractBalance < amount) {
            revert SendFunds__InsufficientTokenBalance(
                tokenAddress,
                amount,
                contractBalance
            );
        }

        // Transfer tokens from the contract to the destination address
        token.safeTransfer(destinationAddress, amount);
    }

    function getContractBalance() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    /**
     * @notice Gets the balance of a specific token held by this contract
     * @param tokenAddress The address of the ERC-20 token
     * @return The token balance
     */
    function getTokenBalance(
        address tokenAddress
    ) public view onlyOwner validAddress(tokenAddress) returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    fallback() external payable {
        fundContract();
    }

    receive() external payable {
        fundContract();
    }
}
