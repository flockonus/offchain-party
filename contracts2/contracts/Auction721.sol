pragma solidity >=0.4.25 <0.6.0;

import 'openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol';
import 'openzeppelin-solidity/contracts/token/ERC721/ERC721Mintable.sol';

contract Auction721 is ERC721Full, ERC721Mintable {
	struct Auction {
		uint tokenId;
		uint price;
		uint64 endsAtBlock;
		address winning;
	}
	// tokenId -> auction
	// mapping(uint => Auction) auctions;
	Auction public auction;

	address public owner;

	constructor() ERC721Full("MyNFT", "MNFT") public {
		owner = msg.sender;
  }

	function mintAndAuction(uint tokenId, uint initialPrice, uint endBlock) external {
		require(msg.sender == owner, "only owner can mint");
		require(auction.endsAtBlock == 0, "auction already exists");

		// create a token belonging to this contract
		mint(address(this), tokenId);

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
		// check it's over
		// TODO send profits
		

		auction = Auction({
			tokenId: 0,
			endsAtBlock: 0,
			winning: address(0),
			price: 0
		});
	}

  /**
	we have this:
   * @dev Function to mint tokens
   * @param to The address that will receive the minted tokens.
   * @param tokenId The token id to mint.
   * @return A boolean that indicates if the operation was successful.
   *
  function mint(
    address to,
    uint256 tokenId
  )
    public
    onlyMinter
    returns (bool)
  {
    _mint(to, tokenId);
    return true;
  }
	*/
	
}