// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;


interface IERC721 {
	function transferFrom
	(
		address _from,
		address _to,
		uint _nftId
	) external;
}

contract Auction 
{
	/*IERC721 public immutable nft;
    uint public immutable nftId;*/
	address public owner;

	// It is not safe to refer to the timestamps of blocks. Instead, we refer to block numbers for time.
	uint public auctionStart;
	uint public auctionEnd;
	uint public minimumBid;
	string public ipfsHash;

	uint highestBid;
	address highestBidder;
	mapping(address => uint256) public fundsByBidder;

	bool ownerWithdrawn;
	bool winnerWithdrawn;

	constructor (address _owner, uint _start, uint _end, uint _minBid, string memory _ipfsHash/*, address _nft, uint _nftId*/) 
	{
		assert (_start < _end /*&& _start >= block.number*/ && _owner != address(0));
		assert (_minBid > 0);

		owner = _owner;
		auctionStart = _start;
		auctionEnd = _end;
		ipfsHash = _ipfsHash;
		minimumBid = _minBid;

		highestBid = 0;
		highestBidder = address(0);

		/*nft = IERC721(_nft);
		nftId = _nftId;*/

		ownerWithdrawn = false;
		winnerWithdrawn = false;
	}

	event LogBid(address bidder, uint bid, bool isHighest);

	function placeBid() public
	payable
	onlyRunning
	onlyNotOwner
	onlyValidBid
	returns (bool success) 
	{
		uint newBid = fundsByBidder[msg.sender] + msg.value;
		assert (newBid > fundsByBidder[msg.sender]);
		bool isHighest = (newBid > highestBid);

		if (isHighest)
		{
			highestBid = newBid;
			highestBidder = msg.sender;
		}

		fundsByBidder[msg.sender] = newBid;
		emit LogBid(msg.sender, newBid, isHighest);
		return true;
	}

	function withdraw() public
	onlyAfterEnding
	returns (bool success)
	{
		uint withdrawalAmount = 0;
		bool isAuctionSuccessful = (highestBid > minimumBid && highestBidder != owner && highestBidder != address(0));

		if (msg.sender == owner)
		{
			assert (!ownerWithdrawn);

			// Success Auction: Gets Highest Bid
			if (isAuctionSuccessful)
			{
				withdrawalAmount = highestBid;
				fundsByBidder[highestBidder] -= highestBid;
			}
			// Else: Gets NFT Back (nothing to do)

			ownerWithdrawn = true;
		}
		else if (msg.sender == highestBidder)
		{
			assert (!winnerWithdrawn);

			// Success Auction: Gets NFT
			if (isAuctionSuccessful)
			{
				// nft.transferFrom(owner, msg.sender, nftId);
				// uint refund = firstBid - secondBid;

				// withdrawalAmount = refund;
				// fundsByBidder[firstBidder] -= refund;
			}
			// Else: Gets refund
			else
			{
				assert (fundsByBidder[highestBidder] > 0);
				withdrawalAmount = fundsByBidder[highestBidder];
				fundsByBidder[highestBidder] = 0;
			}

			winnerWithdrawn = true;
		}
		// Others: gets refund
		else
		{
			assert (fundsByBidder[msg.sender] > 0);
			withdrawalAmount = fundsByBidder[msg.sender];
			fundsByBidder[msg.sender] = 0;
		}

		if (withdrawalAmount > 0)
		{
			assert (payable(msg.sender).send(withdrawalAmount));
		}

		return true;
	}

	modifier onlyRunning 
	{
		assert (auctionEnd >= block.number && block.number >= auctionStart);
		_;
	}

	modifier onlyValidBid 
	{
		assert (msg.value > 0 && msg.value > minimumBid);
		_;
	}

	modifier onlyNotOwner 
	{
		assert (msg.sender != owner);
		_;
	}
	
	modifier onlyAfterEnding
	{
		assert (block.number > auctionEnd);
		_;
	}
}

