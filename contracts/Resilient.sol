// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./interfaces/IHuman.sol";
import "./CircuitBreaker.sol";

contract Resilient {
  using CircuitBreaker for CircuitBreaker.Breaker;
  
  IHuman public primary;
  IHuman public secondary;
  CircuitBreaker.Breaker public breaker;

  constructor(
    IHuman _primary,
    IHuman _secondary,
    uint8 _failureTreshold, 
    uint256 _cooldown
  ) public {
    primary = _primary;
    secondary = _secondary;
    breaker = CircuitBreaker.build(_failureTreshold, _cooldown);
  }

  function ask() external view returns (string memory) {
    // TODO: call secondary if breaker opened
    // return secondary.speak();

    // else if breaker is half opened or opened, try primary 
    try primary.speak() returns (string memory greeting) 
    {
      return greeting;
    } catch {
      // TODO: use circuit breaker
      // breakerFailures++;
    }
  }
}
