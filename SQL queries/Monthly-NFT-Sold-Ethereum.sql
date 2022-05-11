------------------------------------------------------------------------------------------------
-- Count the number of monthly nfts sold on Opensea for the Ethereum Blockchain
-- last 12 months only
------------------------------------------------------------------------------------------------

SELECT date_trunc('month', evt_block_time) as month
       , count(*) as nft_sold
FROM opensea."WyvernExchange_evt_OrdersMatched"
WHERE  evt_block_time >= date('{{From}}')
and evt_block_time < date('{{To}}')
GROUP BY 1
ORDER BY 1
