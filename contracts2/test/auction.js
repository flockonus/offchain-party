const Auction721 = artifacts.require("Auction721");

const mineOneBlock = async () => {
  await web3.currentProvider.send({
    jsonrpc: '2.0',
    method: 'evm_mine',
    params: [],
    id: 0,
  });
};
const mineNBlocks = async (n) => {
  for (let i = 0; i < n; i++) {
    await mineOneBlock();
  }
};

async function getAuction(instance) {
  const auctionData = await instance.auction();
  return {
    tokenId: auctionData.tokenId.toString(),
    price: auctionData.price.toString(),
    endsAtBlock: auctionData.endsAtBlock.toString(),
    winning: auctionData.winning,
  };
}

contract('Auction721', (accounts) => {
  it('deploy and open auction', async function() {
    const instance = await Auction721.deployed();

    const nowBlock = await web3.eth.getBlockNumber();
    
    console.log('current block', nowBlock);

    const targetEnd = nowBlock + 10;

    await instance.mintAndAuction(777, 100, targetEnd);
    
    console.log('>>', await getAuction(instance));
  });
});
