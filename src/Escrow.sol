// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.21;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

struct Allocation {
    uint256 amount;
    uint256 price;
}

/// @title Escrow contract.
/// @notice Allows token1 to be sold for token2 without a trusted intermediary.
contract Escrow is Ownable {
    /// @notice Token to be sold.
    IERC20 public immutable s_token1;
    /// @notice Token used to buy.
    IERC20 public immutable s_token2;
    /// @notice Buy allocations.
    mapping(address => Allocation) s_allocations;

    constructor(
        address initialOwner,
        IERC20 token1,
        IERC20 token2
    ) Ownable(initialOwner) {
        s_token1 = token1;
        s_token2 = token2;
    }

    /// @notice Allocate a buy order. Can only be filled by the set address.
    function allocate(
        address addr,
        Allocation calldata allocation
    ) public onlyOwner {
        require(s_allocations[addr].amount == 0);

        s_allocations[addr] = allocation;

        require(
            s_token1.transferFrom(msg.sender, address(this), allocation.amount)
        );
    }

    /// @notice Clear a buy order.
    function deallocate(address addr) public onlyOwner {
        uint256 amount = s_allocations[addr].amount;

        delete s_allocations[addr];

        require(s_token1.transfer(msg.sender, amount));
    }

    /// @notice Execute a buy.
    function buy(address receiver, uint256 amount, uint256 price) public {
        require(amount > 0);
        Allocation memory allocation = s_allocations[msg.sender];
        require(amount == allocation.amount);
        require(price == allocation.price);

        delete s_allocations[msg.sender];

        // Transfer token2 from buyer's sending address to owner.
        // Requires prior approval.
        require(s_token2.transferFrom(msg.sender, owner(), price));
        // Transfer token1 to buyer's receiving address.
        require(s_token1.transfer(receiver, amount));
    }

    /// @notice Reap all of a token deposited to this contract.
    /// @dev Used for disaster recovery.
    function reap(IERC20 token) public onlyOwner {
        uint256 balance = token.balanceOf(address(this));

        require(token.transfer(msg.sender, balance));
    }

    /// @notice Reap all ETH deposited to this contract.
    /// @dev Used for disaster recovery.
    function reapeth() public onlyOwner {
        uint256 balance = address(this).balance;

        payable(msg.sender).transfer(balance);
    }
}
