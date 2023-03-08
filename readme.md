# Lottery App
This app created with Solidity and OpenZeppelin library with the purpose of creating a lottery service in which each Ticket that user buys is an NFT.
- Users can purchase Tickets using their TL tokens.
- In given intervals, winners of the current lottery are determined and rewarded accordingly.

## To install dependencies
```bash
npm install
``` 

## To start the contracts
```bash
truffle develop
```

```bash
truffle(develop)> migrate 
```

## To test (truffle develop console should be kept open, use another for this)
```bash
truffle test ./test/lottery.js
```
or

```bash
truffle test ./test/ticket.js
```
