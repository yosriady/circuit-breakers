const { expectEvent, expectRevert, time } = require('@openzeppelin/test-helpers');
const Resilient = artifacts.require("Resilient");
const Moody = artifacts.require("Moody");
const Stoic = artifacts.require("Stoic");

const CLOSED = 0;
const OPEN = 1;
const MOODY_REVERT_MESSAGE = "REeEeEeEeEeEeEeEeEeEeEeEe";
const PRIMARY_RESPONSE = "Huzzah!";
const SECONDARY_RESPONSE = "Sup.";
const TRESHOLD = 2;
const COOLDOWN = time.duration.minutes(5); // 300

contract('Resilient', (accounts) => {
  const [ owner ] = accounts;

  beforeEach(async () => {
    this.moody = await Moody.new(PRIMARY_RESPONSE);
    this.stoic = await Stoic.new(SECONDARY_RESPONSE);
    this.resilient = await Resilient.new(
      this.moody.address,
      this.stoic.address,
      TRESHOLD,
      COOLDOWN
    )
  });

  it('initializes circuit breaker', async () => {
    const breaker = await this.resilient.breaker();
    expect(breaker.status.toNumber()).to.equal(CLOSED);
    expect(breaker.failureCount.toNumber()).to.equal(0);
    expect(breaker.failureTreshold.toNumber()).to.equal(TRESHOLD);
    expect(breaker.cooldown.toNumber()).to.equal(COOLDOWN.toNumber());
    expect(breaker.retryAt.toNumber()).to.equal(0);
  });    

  it('ask returns primary response when not moody', async () => {
    const greeting = await this.resilient.ask();
    expect(greeting).to.equal(PRIMARY_RESPONSE);
  });

  it('ask returns secondary response when moody', async () => {
    await this.moody.toggleMood()
    const isMoody = await this.moody.isMoody();
    expect(isMoody);    

    const greeting = await this.resilient.ask();
    expect(greeting).to.equal(SECONDARY_RESPONSE);
  });

  it('safeAsk increments failure count when moody', async () => {
    await this.moody.toggleMood()
    const isMoody = await this.moody.isMoody();
    expect(isMoody);
    await expectRevert(this.moody.speak(), MOODY_REVERT_MESSAGE);

    await this.resilient.safeAsk();

    let breaker = await this.resilient.breaker();
    expect(breaker.status.toNumber()).to.equal(CLOSED);
    expect(breaker.failureCount.toNumber()).to.equal(1);
    expect(breaker.retryAt.toNumber()).to.equal(0);
  });

  it('exceeding failure count treshold trips open breaker', async () => {
    await this.moody.toggleMood()
    await expectRevert(this.moody.speak(), MOODY_REVERT_MESSAGE);

    // safeAsk TRESHOLD times to trip open breaker
    await this.resilient.safeAsk();
    const receipt = await this.resilient.safeAsk();
    expectEvent(receipt, 'Opened');
    expectEvent(receipt, 'Log', { msg: SECONDARY_RESPONSE });

    const breaker = await this.resilient.breaker();
    expect(breaker.status.toNumber()).to.equal(OPEN);
    expect(breaker.failureCount.toNumber()).to.equal(2);
    expect(breaker.retryAt.toNumber() > time.latest());
  });

  it('circuit closes after a successful call when open', async () => {
    await this.moody.toggleMood()
    await this.resilient.safeAsk();
    await this.resilient.safeAsk();
    let breaker = await this.resilient.breaker();
    expect(breaker.status.toNumber()).to.equal(OPEN);

    await this.moody.toggleMood()
    expect(await this.moody.speak(), PRIMARY_RESPONSE); // Moody recovers

    await time.increase(COOLDOWN); // Wait for cooldown, enters half-open state

    const receipt = await this.resilient.safeAsk(); // Retry after moody recovers
    expectEvent(receipt, 'Closed');
    expectEvent(receipt, 'Log', { msg: PRIMARY_RESPONSE });
    breaker = await this.resilient.breaker();
    expect(breaker.status.toNumber()).to.equal(CLOSED);
    expect(breaker.failureCount.toNumber()).to.equal(0); // Failure count reset 

    await this.resilient.safeAsk();
    const receipt2 = await this.resilient.safeAsk(); // Call safeAsk() TRESHOLD times
    expectEvent(receipt2, 'Log', { msg: PRIMARY_RESPONSE }); // Still closed since Moody recovered
    breaker = await this.resilient.breaker();
    expect(breaker.status.toNumber()).to.equal(CLOSED); // Still closed
    expect(breaker.failureCount.toNumber()).to.equal(0);
  });
})