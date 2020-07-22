const { expectRevert } = require('@openzeppelin/test-helpers');
const Moody = artifacts.require("Moody");

contract('Moody', (accounts) => {
  const [ owner ] = accounts;

  beforeEach(async () => {
    this.contract = await Moody.new("Huzzah!");
  });

  it('speaks when not moody', async () => {
    const isMoody = await this.contract.isMoody();
    expect(!isMoody);

    const greeting = await this.contract.speak();

    expect(greeting).to.equal("Huzzah!");
  });

  it('reverts when moody', async () => {
    await this.contract.toggleMood();
    const isMoody = await this.contract.isMoody();
    expect(isMoody);

    await expectRevert(this.contract.speak(), 'REeEeEeEeEeEeEeEeEeEeEeEe');
  });  
})