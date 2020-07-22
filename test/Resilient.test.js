const { expectRevert } = require('@openzeppelin/test-helpers');
const Resilient = artifacts.require("Resilient");
const Moody = artifacts.require("Moody");
const Stoic = artifacts.require("Stoic");

contract('Moody', (accounts) => {
  const [ owner ] = accounts;

  beforeEach(async () => {
    this.moody = await Moody.new("Huzzah!");
    this.stoic = await Stoic.new("Sup.");
    this.resilient = await Resilient.new(
      this.moody.address,
      this.stoic.address
    )
  });

  it('asks returns when not moody', async () => {
    const greeting = await this.resilient.ask();

    expect(greeting).to.equal("Huzzah!");
  });
})