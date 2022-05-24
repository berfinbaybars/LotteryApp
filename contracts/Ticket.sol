// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TicketToken is ERC721 {
    mapping(address => mapping(uint256 => uint256[])) balances; // owned tickets by lottery no and ticket no
    mapping(uint256 => uint256[]) submitted; // submitted tickets for each lottery
    mapping(uint256 => uint256[]) winners; // winner tickets for each lottery
    mapping(uint256 => uint256) xor; // random number for each lottery

    constructor() ERC721("Ticket", "TCK") {
    }

    function addTicket(address owner, uint ticketno, uint lotteryNo) public {
        balances[owner][lotteryNo].push(ticketno);
    }

    function revealHash(uint ticketno, uint randomNumber, uint lotteryNo) public {
        xor[lotteryNo] = xor[lotteryNo] ^ randomNumber; //by xoring all the random numbers, will get random numbers to determine winners
        submitted[lotteryNo].push(ticketno);
    }

    function lastTicketOfAccount(address sender, uint lotteryNo) public view returns(uint256){
        require(balances[sender][lotteryNo].length > 0, "You do not have any ticket for this lottery.");
        return balances[sender][lotteryNo][balances[sender][lotteryNo].length-1];
    }

    function ithTicketOfAccount(address sender, uint lotteryNo, uint i) public view returns(uint256){
        require(i <= balances[sender][lotteryNo].length, "You do not have that much tickets.");
        return balances[sender][lotteryNo][i-1];
    }

    function chooseWinners(uint lotteryNo, uint totalMoney) public returns(uint256[] memory){
        require(submitted[lotteryNo].length > 0, "No one has submitted. There is no winner.");
        uint winnerCount = findLogarithm(totalMoney);
        for(uint i = 1; i <= winnerCount; i++){
            uint winner = hashNTimes(i, xor[lotteryNo]) % submitted[lotteryNo].length;  
            winners[lotteryNo].push(submitted[lotteryNo][winner]);
        }
        return winners[lotteryNo];
    }

    //to find how much time "a" can be divided by 2, will used to determine how much winners a lottery will have
    function findLogarithm(uint a) public pure returns(uint256){
        uint i = 0;
        while(2**i < a){
            i++;
        }
        return i;
    }

    //random number get hashed n times to determine nth winner of the lottery
    function hashNTimes(uint n, uint random) public pure returns(uint256){
        bytes32 hash = keccak256(abi.encodePacked(random));
        for(uint i = 1; i <= n; i++){
            hash = keccak256(abi.encodePacked(hash));
        }
        return uint256(hash);
    }

    function calculatePrize(uint prizeNo, uint totalMoney) public pure returns(uint256){
        return ((totalMoney / 2**prizeNo) + ((totalMoney / 2**(prizeNo-1) % 2)));
    }

    function getIthWinnerTicket(uint i, uint lottery_no, uint totalMoney) public view returns (uint ticket_no,uint amount){
        return (winners[lottery_no][i-1], calculatePrize(i, totalMoney));
    }

    function getWinnerCount(uint lotteryNo) public view returns(uint){
        return winners[lotteryNo].length;
    }
}