// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./interfaces/IHuman.sol";

contract Stoic is IHuman {
  string public greeting;

  constructor(
    string memory _greeting
  ) public {
    greeting = _greeting;
  }

  function speak() external override view returns (string memory) {
    return greeting;
  }
}
