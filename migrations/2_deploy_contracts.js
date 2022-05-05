const Lottery = artifacts.require("Lottery");
const Ticket = artifacts.require("TicketToken");

module.exports = function (deployer) {
    deployer.deploy(Lottery);
    deployer.deploy(Ticket);
};