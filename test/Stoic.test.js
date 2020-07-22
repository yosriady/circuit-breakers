const Stoic = artifacts.require("Stoic");

contract('Stoic', (accounts) => {
  beforeEach(async () => {
    this.contract = await Stoic.new("Sup.");
  });

  it('speaks', async () => {
    const greeting = await this.contract.speak();

    expect(greeting).to.equal("Sup.");
  });
})