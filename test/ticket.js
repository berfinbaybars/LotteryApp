const Ticket = artifacts.require("TicketToken");

contract('Ticket', function(accounts){
    it("add 100 tickets and reveal them", async function(){
        let ticket = await Ticket.deployed();
        for(let i = 0; i < accounts.length; i++){
            await ticket.addTicket(accounts[i], i+1, 1);
            await ticket.revealHash(i+1, i+5,1);
        }
        //await ticket.chooseWinners.call(1,accounts.length * 10);
    })
    it("add 100 tickets", async function(){
        console.log(accounts.length);
        let ticket = await Ticket.deployed();
        for(let i = 0; i < accounts.length; i++){
            await ticket.addTicket(accounts[i], i+1, 1);
        }
    })
    it("add ticket", async function(){
        let ticket = await Ticket.deployed();
        let receipt = await ticket.addTicket(accounts[0], 1, 1);
        console.log(receipt.receipt.gasUsed)
    })
    it("choose winners", async function(){
        let ticket = await Ticket.deployed();
        let receipt = await ticket.chooseWinners(1,1000);
        console.log(receipt.receipt.gasUsed)
    })
})