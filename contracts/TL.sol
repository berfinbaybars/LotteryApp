// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TLToken is ERC20 {
    address admin;
    constructor() ERC20("TurkishLira", "TL") {
        admin = msg.sender;
        _mint(msg.sender, 10**18); //to control the supply of token
    }

    function addTL(uint amnt, address sender) public {
        _transfer(admin, sender, amnt);
    }

    function subtractTL(uint amnt, address sender) public {
        _transfer(sender, admin, amnt);
    }
}