------------------------------------------------------------------------------------------------
-- Average of monthly nfts sold on Ethereum Blockchain
------------------------------------------------------------------------------------------------
WITH cte as (
SELECT date_trunc('month', evt_block_time) as month
       , count(*) as nft_sold
FROM opensea."WyvernExchange_evt_OrdersMatched"
WHERE  evt_block_time >= date('{{From}}')
AND evt_block_time < date('{{To}}')
GROUP BY 1)

SELECT AVG(nft_sold) as avg_nft_sold
FROM CTE
