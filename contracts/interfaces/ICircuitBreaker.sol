// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;


interface ICircuitBreaker {
  enum Status { CLOSED, OPEN }
  event Closed();
  event Opened(uint retryAt);

  struct Breaker {
    Status status; // OPEN or CLOSED
    uint8 failureCount; // Counter for number of failed calls
    uint8 failureTreshold; // When failure count >= treshold, trip / open the breaker
    uint cooldown; // How long after a trip before the breaker is half-opened (in seconds)
    uint retryAt; // Unix timestamp when breaker is half-opened (in seconds)
  }

  function success() external;
  function fail() external;
  function isClosed() external view returns (bool);
  function isOpen() external view returns (bool);
  function isHalfOpen() external view returns (bool);
}
