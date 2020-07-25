// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./interfaces/IHuman.sol";
import "./utils/ReentrancyGuard.sol";
import "./CircuitBreaker.sol";

contract Resilient is ReentrancyGuard {
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
    if (breaker.isOpen()) return secondary.speak();
    return primary.speak();
  }

  function tryAsk() external nonReentrant returns (string memory) {
    // if breaker opened, call secondary
    if (breaker.isOpen()) return secondary.speak();

    // else if breaker is half opened or opened, try primary 
    try primary.speak() returns (string memory greeting) 
    {
      breaker.success(); // Notify breaker of success
      return greeting;
    } catch {
      breaker.fail(); // Notify breaker of failure
      return secondary.speak(); // Use backup
    }
  }
}
