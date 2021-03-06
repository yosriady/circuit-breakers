// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./interfaces/IHuman.sol";
import "./utils/ReentrancyGuard.sol";
import "./CircuitBreaker.sol";

contract Resilient is ReentrancyGuard {
  using CircuitBreaker for CircuitBreaker.Breaker;

  // we have to repeat the CircuitBreaker event declarations in the contract
  // in order for some client-side frameworks to detect them (otherwise they won't show up in the contract ABI)
  event Opened(uint retryAt);
  event Closed();
  
  IHuman public primary;
  IHuman public secondary;
  CircuitBreaker.Breaker public breaker;

  event Log(string msg); // Event used for testing safeAsk's non-view return value

  constructor(
    IHuman _primary,
    IHuman _secondary,
    uint8 _treshold, 
    uint256 _cooldown
  ) public {
    primary = _primary;
    secondary = _secondary;
    breaker = CircuitBreaker.build(_treshold, _cooldown);
  }

  function safeAsk() external nonReentrant returns (string memory) {
    if (breaker.isOpen()) {
      string memory greeting = secondary.speak();
      Log(greeting);
      return greeting;
    }

    // When breaker is half opened or closed, try primary 
    try primary.speak() returns (string memory greeting) 
    {
      breaker.success(); // Notify breaker of success
      Log(greeting);
      return greeting;
    } catch {
      breaker.fail(); // Notify breaker of failure
      string memory greeting = secondary.speak();
      Log(greeting);
      return greeting;
    }
  }

  function ask() external view returns (string memory) {
    try primary.speak() returns (string memory greeting) 
    {
      return greeting;
    } catch {
      return secondary.speak();
    }
  }  
}
