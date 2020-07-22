// SPDX-License-Identifier: MIT
pragma solidity ^0.6.11;

import "./interfaces/IHuman.sol";

// TODO: inherits CircuitBreaker like Ownable
contract Resilient {
  IHuman public primary;
  IHuman public secondary;

  constructor(
    IHuman _primary,
    IHuman _secondary
  ) public {
    primary = _primary;
    secondary = _secondary;
  }

  function ask() external view returns (string memory) {
    // TODO: use circuit breaker
    return primary.speak();
  }
}
