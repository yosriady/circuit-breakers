// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./interfaces/IHuman.sol";

contract Moody is IHuman {
  bool public isMoody = false;
  string public greeting;

  constructor(
    string memory _greeting
  ) public {
    greeting = _greeting;
  }

  function toggleMood() external {
    isMoody = !isMoody;
  }

  function speak() external override view returns (string memory) {
    require(!isMoody, "REeEeEeEeEeEeEeEeEeEeEeEe");
    return greeting;
  }
}
