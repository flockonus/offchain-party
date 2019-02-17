pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';
// import 'openzeppelin-solidity/contracts/token/ERC721/ERC721Mintable.sol';

contract Auction721 is ERC721 /*, ERC721Mintable*/ {
	struct Auction {
		uint tokenId;
		uint price;
		uint64 endsAtBlock;
		address winning;
	}
	// tokenId -> auction
	// mapping(uint => Auction) auctions;
	Auction public auction;

	address payable public owner;

	constructor() ERC721() public {
		owner = msg.sender;
  }

	function mintAndAuction(uint tokenId, uint initialPrice, uint endBlock) external {
		require(msg.sender == owner, "only owner can mint");
		require(auction.endsAtBlock == 0, "auction already exists");

		// create a token belonging to this contract
		_mint(address(this), tokenId);

		auction = Auction({
			tokenId: tokenId,
			endsAtBlock: uint64(endBlock),
			winning: address(0),
			price: initialPrice
		});
	}

	function bid() external payable {
		require(auction.endsAtBlock < block.number, "auction ended");
		require(msg.value > auction.price, "value sent cant be less than auction");

		uint64 endBlock = auction.endsAtBlock;
		// get more eyes on this logic
		if (block.number + 20 > auction.endsAtBlock) {
			endBlock += 20;
		}
		
		auction = Auction({
			tokenId: auction.tokenId,
			endsAtBlock: uint64(endBlock),
			winning: address(0),
			price: msg.value
		});
	}

	function endAuction() external {
		// anyone can call it to finish it
		// require(msg.sender == owner, "only owner can mint");
		require(auction.endsAtBlock < now, "not over yet");
		require(auction.winning != address(0));

		// TODO send profits
		owner.transfer(address(this).balance);

		// this can only be executed once
		_transferFrom(owner, auction.winning, auction.tokenId);

		// NOTE: do we want a single auction?
		// auction = Auction({
		// 	tokenId: 0,
		// 	endsAtBlock: 0,
		// 	winning: address(0),
		// 	price: 0
		// });
	}
}