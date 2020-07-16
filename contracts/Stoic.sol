// SPDX-License-Identifier: MIT
pragma solidity ^0.6.11;

import "./interfaces/IHuman.sol";

contract Stoic is IHuman {
  function speak() external override view returns (uint) {
    return 10;
  }
}
