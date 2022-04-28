const staking = artifacts.require("../contractors/artifacts/staking");
const utils = require("./helpers/utils");

contract("staking", (accounts) => {
    let contractInstance;
    let token = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
    beforeEach(async () => {
        contractInstance = await staking.new(token);
    });
    it("should be able to add Token", async () => {
        const result = await contractInstance.addToken(token);
    })
    it("should be able to stake", async () => {
		await contractInstance.addToken(token);
        const result = await contractInstance.stake(1, token, 365);
		//console.log(result.valueOf());
    })
	it("should be able to getUserInfo", async () => {
		await contractInstance.addToken(token);
        await contractInstance.stake(100, token, 365);
        const result = await contractInstance.getUserInfo(token);
		assert.equal(result.valueOf().amount, 100, "Wrong ammount " + result.valueOf().amount);
    })
	it("should be able to unstake", async () => {
		await contractInstance.addToken(token);
        await contractInstance.stake(100, token, 365);
        await contractInstance.unstake(50, token);
		const result = await contractInstance.getUserInfo(token);
		assert.equal(result.valueOf().amount, 50, "Wrong ammount " + result.valueOf().amount);
		r = await contractInstance.getTokenTotalStaked(token);
		assert.equal(r.valueOf().words[0], 50, "Wrong TotalStaked " + r.valueOf().words[0]);
    })
	it("should be able to getTokenTotalStaked", async () => {
		await contractInstance.addToken(token);
        await contractInstance.stake(100, token, 365);
        await contractInstance.unstake(50, token);
		const result = await contractInstance.getTokenTotalStaked(token);
		assert.equal(result.valueOf().words[0], 50, "Wrong TotalStaked " + result.valueOf().words[0]);
    })
})
