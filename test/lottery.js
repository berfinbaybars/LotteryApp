const Lottery = artifacts.require("Lottery");
const { toBN } = web3.utils;

function delay(time) {
    return new Promise(resolve => setTimeout(resolve, time));
}

contract('Lottery', function(accounts){
    it("depositTL", async function(){
        let lottery = await Lottery.deployed();
        let gasUsed = await lottery.depositTL.estimateGas(150);
        console.log(gasUsed)
    })
    it("withdrawTL", async function(){
        let lottery = await Lottery.deployed();
        let gasUsed = await lottery.withdrawTL.estimateGas(50);
        console.log(gasUsed)
    })
    it("buyTicket", async function(){
        let lottery = await Lottery.deployed();
        let gasUsed = await lottery.attemptBuying.estimateGas(36);
        console.log(gasUsed)
    })
    it("buy n Ticket", async function(){
        let n = 10;
        let lottery = await Lottery.deployed();
        await lottery.depositTL(n*10);
        for(let i = 1; i <= n; i++){
            await lottery.attemptBuying(i*5);
        }
    })
    it("collectTicketRefund", async function(){
        let lottery = await Lottery.deployed();
        let gasUsed = await lottery.collectTicketRefund.estimateGas(0, 1);
        console.log(gasUsed)
    })
    it("revealRndNumber", async function(){
        let lottery = await Lottery.deployed();
        await lottery.depositTL(20);
        await lottery.attemptBuying(5)
        await delay(20 * 1000); // should be bigger than purchase period
        let gasUsed = await lottery.revealRndNumber.estimateGas(0,5);
        console.log(gasUsed)
    })
    it("getLastOwnedTicketNo", async function(){
        let lottery = await Lottery.deployed();
        let gasUsed = await lottery.getLastOwnedTicketNo.estimateGas(1);
        console.log(gasUsed)
    })
    it("getIthOwnedTicketNo", async function(){
        let lottery = await Lottery.deployed();
        let gasUsed = await lottery.getIthOwnedTicketNo.estimateGas(1,1);
        console.log(gasUsed)
    })
    it("checkIfTicketWon", async function(){
        let lottery = await Lottery.deployed();
        let gasUsed = await lottery.checkIfTicketWon.estimateGas(0,1);
        console.log(gasUsed)
    })
    it("collectTicketPrize", async function(){
        let lottery = await Lottery.deployed();
        let gasUsed = await lottery.collectTicketPrize.estimateGas(0,1);
        console.log(gasUsed)
    }) 
    it("getIthOwnedTicketNo", async function(){
        let lottery = await Lottery.deployed();
        let gasUsed = await lottery.getIthOwnedTicketNo.estimateGas(1,1);
        console.log(gasUsed)
    })
    it("getLotteryNo", async function(){
        let lottery = await Lottery.deployed();
        let gasUsed = await lottery.getLotteryNo.estimateGas(await lottery.timeSinceStart());
        console.log(gasUsed)
    })
    it("getTotalLotteryMoneyCollected", async function(){
        let lottery = await Lottery.deployed();
        let gasUsed = await lottery.getTotalLotteryMoneyCollected.estimateGas(1);
        console.log(gasUsed)
    })
 
    
})