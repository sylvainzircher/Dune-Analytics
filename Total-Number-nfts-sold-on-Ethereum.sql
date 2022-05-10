------------------------------------------------------------------------------------------------
-- Total number of nfts sold on Ethereum Blockchain
------------------------------------------------------------------------------------------------
SELECT count(*) as nft_sold
FROM opensea."WyvernExchange_evt_OrdersMatched"
WHERE  evt_block_time >= date('{{From}}')
AND evt_block_time < date('{{To}}')
