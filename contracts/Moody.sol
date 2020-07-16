// SPDX-License-Identifier: MIT
pragma solidity ^0.6.11;

import "./interfaces/IHuman.sol";

contract Moody is IHuman {
  bool public isMoody = false;

  function toggleMood() external {
    isMoody = !isMoody;
  }

  function speak() external override view returns (uint) {
    require(!isMoody, "REeEeEeEeEeEeEeEeEeEeEeEe");
    return 1;
  }
}
