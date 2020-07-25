// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;


library CircuitBreaker {
  enum Status { CLOSED, OPEN }
  event Closed();
  event Opened();

  struct Breaker {
    Status status; // OPEN or CLOSED
    uint8 failureCount; // Counter for number of failed calls
    uint8 failureTreshold; // When failures >= treshold, trip the breaker
    uint cooldown; // How long after a trip before the breaker is half-opened (in seconds)
    uint retryAt; // Unix timestamp when breaker is half-opened (in seconds)
  }

  function build(uint8 _failureTreshold, uint256 _cooldown) internal pure returns (Breaker memory) {
    require(_failureTreshold > 0, 'Breaker failure treshold must be greater than zero.');
    require(_cooldown > 0, 'Breaker cooldown must be greater than zero.');
    return Breaker(
      Status.CLOSED,
      0,
      _failureTreshold,
      _cooldown,
      0
    );
  }

  // Track success
  function success(Breaker storage self) internal {
    // TODO: only call this after a isHalfOpen() check and actual successful call
    if (canRestore(self)) _restore(self);
  }

  // Track failure
  function fail(Breaker storage self) internal {
    self.failureCount++;
    if (canTrip(self)) _trip(self);
  }

  // Returns true if breaker can be tripped
  function canTrip(Breaker storage self) internal view returns (bool) {
    return (isClosed(self) && self.failureCount >= self.failureTreshold);
  }

  function _trip(Breaker storage self) private {
    self.status = Status.OPEN;
    self.retryAt = now + self.cooldown;
    emit Opened();
  }

  // Returns true if breaker can be restored
  function canRestore(Breaker storage self) private view returns (bool) {
    return (isOpen(self) && now >= self.retryAt);
  }

  function _restore(Breaker storage self) private {
    self.status = Status.CLOSED;
    self.failureCount = 0;
    emit Closed();
  }

  function isOpen(Breaker storage self) internal view returns (bool) {
    return self.status == Status.OPEN;
  }

  function isClosed(Breaker storage self) internal view returns (bool) {
    return self.status == Status.CLOSED;
  }

  // Returns true if cooldown met
  function isHalfOpen(Breaker storage self) internal view returns (bool) {
    return (isClosed(self) && self.retryAt >= now);
  }

  // modifier whenOpen() {
  //     require(isOpen(), "CircuitBreaker: self is not OPEN");
  //     _;
  // }

  // modifier whenClosed() {
  //     require(isClosed(), "CircuitBreaker: self is not CLOSED");
  //     _;
  // }
}
