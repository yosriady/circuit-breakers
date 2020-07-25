const { expectRevert, time } = require('@openzeppelin/test-helpers');
const Resilient = artifacts.require("Resilient");
const Moody = artifacts.require("Moody");
const Stoic = artifacts.require("Stoic");

const CLOSED = 0;
const OPEN = 1;

const TRESHOLD = 2;
const COOLDOWN = time.duration.minutes(5);

contract('Resilient', (accounts) => {
  const [ owner ] = accounts;

  beforeEach(async () => {
    this.moody = await Moody.new("Huzzah!");
    this.stoic = await Stoic.new("Sup.");
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
  });    

  it('ask returns when not moody', async () => {
    const greeting = await this.resilient.ask();

    expect(greeting).to.equal("Huzzah!");
  });
})