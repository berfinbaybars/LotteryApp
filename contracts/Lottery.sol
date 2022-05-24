// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

import "./TL.sol";
import "./Ticket.sol";

contract Lottery {
    TLToken tl;
    TicketToken ticket;
    uint256 constant ticketPrice = 10;
    uint256 constant purchaseDuration = 2 minutes; //how much time players can buy tickets in each lottery
    uint256 constant revealDuration = 2 minutes; //how much time players can reveal tickets in each lottery
    uint256 constant lotteryDuration = purchaseDuration + revealDuration; // how much time each lottery will be active
    uint256 startDate; //when the contract started (will be used to determine how much time spend since start)

    struct Lotteries {
        Tickets[] tickets;
        bool areWinnersChosen;
    }
    
    struct Tickets {
        uint256 id;
        address owner;
        bytes32 hash;
        uint256 reward;
        bool isRevealed;
        bool isRedeemed;
        bool isRefunded;
    }

    mapping(uint256 => Lotteries) lotteries;
    
    constructor(){
        tl = new TLToken();
        ticket = new TicketToken();
        startDate = block.timestamp;
    }

    modifier lotteryExists(uint256 lotteryNo){
        require(lotteryNo <= getLotteryNo(timeSinceStart()), "Lottery does not exist.");
        _;
    }

    modifier purchasePeriod(){
        require(getCurrentStep() == 1, "It is not purchase period.");
        _;
    }

    modifier revealPeriod(){
        require(getCurrentStep() == 2, "It is not reveal period.");
        _;
    }

    modifier ticketOwner(uint lottery_no, uint ticket_no){
        require(lotteries[lottery_no].tickets[ticket_no].owner == msg.sender, "This is not your ticket.");
        _;
    }

    modifier lotteryPrizes(uint lottery_no){
        require(getLotteryNo(timeSinceStart()) > lottery_no, "Lottery is in progress.");
        if(!lotteries[lottery_no].areWinnersChosen){
            uint256[] memory winners = ticket.chooseWinners(lottery_no, getTotalLotteryMoneyCollected(lottery_no));
            setWinners(winners, lottery_no);
            lotteries[lottery_no].areWinnersChosen = true;
        }
        _;
    }

    modifier lotteryEnded(uint lottery_no){
        require(getLotteryNo(timeSinceStart()) > lottery_no, "Lottery is in progress.");
        _;
    }

    function depositTL(uint amnt) public {
        tl.addTL(amnt, msg.sender);
    }

    function withdrawTL(uint amnt) public {
        require(tlBalance(msg.sender) >= amnt, "You have not that much TL tokens.");
        tl.subtractTL(amnt, msg.sender);
    }

    function tlBalance(address sender) public view returns(uint256){
        return tl.balanceOf(sender);
    }

    function buyTicket(bytes32 hash_rnd_number) private {
        uint lotteryNo = getLotteryNo(timeSinceStart());
        ticket.addTicket(msg.sender, lotteries[lotteryNo].tickets.length, lotteryNo);
        tl.subtractTL(ticketPrice, msg.sender);
        lotteries[lotteryNo].tickets.push(
            Tickets({
                id: lotteries[lotteryNo].tickets.length,
                owner: msg.sender,
                hash: hash_rnd_number,
                reward: 0,
                isRevealed: false,
                isRedeemed: false,
                isRefunded: false
            })
        );
    }

    //will be fired to buy ticket before "buyTicket" function
    function attemptBuying(uint256 random) public purchasePeriod(){
        uint lotteryNo = getLotteryNo(timeSinceStart());
        require(tlBalance(msg.sender) >= ticketPrice, "You do not have enough TL Tokens. Ticket price is 10TL.");
        require(lotteries[lotteryNo].tickets.length <= 10**4, "All the tickets are sold."); //to prevent running out of gas or TL tokens
        bytes32 hash = keccak256(abi.encodePacked(random, msg.sender));
        buyTicket(hash);
    }

    function revealRndNumber(uint ticketno, uint rnd_number) public revealPeriod() ticketOwner(getLotteryNo(timeSinceStart()), ticketno){
        uint lotteryNo = getLotteryNo(timeSinceStart());
        require(lotteries[lotteryNo].tickets[ticketno].isRevealed == false, "You have already revealed this ticket.");
        bytes32 hash = keccak256(abi.encodePacked(rnd_number, msg.sender));
        require(hash == lotteries[lotteryNo].tickets[ticketno].hash, "Entered numbers are not true.");
        ticket.revealHash(ticketno, rnd_number, lotteryNo);
        lotteries[lotteryNo].tickets[ticketno].isRevealed = true;
    }

    function getLastOwnedTicketNo(uint lottery_no) public view lotteryExists(lottery_no) returns(uint,uint8 status){
        uint ticketno = ticket.lastTicketOfAccount(msg.sender, lottery_no);
        uint8 _status = lotteries[lottery_no].tickets[ticketno].isRedeemed ? 2 : lotteries[lottery_no].tickets[ticketno].isRevealed ? 1 : 0;//will be explained to user in interface
        
        return (ticketno, _status);
    }

    function getIthOwnedTicketNo(uint i,uint lottery_no) public view lotteryExists(lottery_no) returns(uint,uint8 status) {
        require(i > 0, "You cannot send 0.");
        uint ticketno = ticket.ithTicketOfAccount(msg.sender, lottery_no, i);
        uint8 _status = lotteries[lottery_no].tickets[ticketno].isRedeemed ? 2 : lotteries[lottery_no].tickets[ticketno].isRevealed ? 1 : 0; //will be explained to user in interface
        return (ticketno, _status);
    }

    //parameter will be time spent since start
    function getLotteryNo(uint unixtimeinweek) public pure returns (uint lottery_no){
        return (unixtimeinweek / lotteryDuration) + 1;
    }

    function getTotalLotteryMoneyCollected(uint lottery_no) public view lotteryExists(lottery_no) returns (uint amount){
        return lotteries[lottery_no].tickets.length * ticketPrice;
    }

    function collectTicketRefund(uint ticket_no, uint lottery_no) public lotteryExists(lottery_no) ticketOwner(lottery_no, ticket_no) 
    lotteryEnded(lottery_no) {
        require(lotteries[lottery_no].tickets[ticket_no].isRevealed == false, "You cannot refund because your ticket is revealed.");
        require(lotteries[lottery_no].tickets[ticket_no].isRefunded == false, "You cannot refund because your ticket is refunded before.");
        tl.addTL((ticketPrice / 2), msg.sender);
        lotteries[lottery_no].tickets[ticket_no].isRefunded = true;
    }

    function timeSinceStart() public view returns (uint){
        return block.timestamp - startDate;
    }

    function getCurrentStep() public view returns (uint){
        return (timeSinceStart() % lotteryDuration) <= purchaseDuration ? 1 : 2; 
    }

    function checkIfTicketWon(uint ticket_no, uint lottery_no) public lotteryExists(lottery_no) lotteryPrizes(lottery_no)
    ticketOwner(lottery_no, ticket_no) returns (uint amount){
        return lotteries[lottery_no].tickets[ticket_no].reward;
    }
    
    function collectTicketPrize(uint ticket_no, uint lottery_no) public lotteryExists(lottery_no) lotteryPrizes(lottery_no) 
    ticketOwner(lottery_no, ticket_no){
        require(lotteries[lottery_no].tickets[ticket_no].reward > 0, "Ticket does not win any prize.");
        tl.addTL(lotteries[lottery_no].tickets[ticket_no].reward, msg.sender);
        lotteries[lottery_no].tickets[ticket_no].isRedeemed = true;
    }

    function setWinners(uint256[] memory winners, uint lotteryNo) private {
        uint totalMoney = getTotalLotteryMoneyCollected(lotteryNo);
        for(uint i = 0; i < winners.length; i++){
            lotteries[lotteryNo].tickets[winners[i]].reward = ticket.calculatePrize(i+1, totalMoney);
        }
    }

    function getIthWinningTicket(uint i, uint lottery_no) public lotteryExists(lottery_no) lotteryPrizes(lottery_no)
    returns (uint ticket_no, uint amount){
        return ticket.getIthWinnerTicket(i, lottery_no, getTotalLotteryMoneyCollected(lottery_no));
    }
}