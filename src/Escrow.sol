// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.21;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Escrow is Ownable {
    IERC20 public s_token;

    constructor(address initialOwner) Ownable(initialOwner) {}
}
