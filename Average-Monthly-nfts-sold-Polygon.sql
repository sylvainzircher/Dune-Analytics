------------------------------------------------------------------------------------------------
-- Average of monthly nfts sold on Polygon Blockchain
------------------------------------------------------------------------------------------------
WITH cte as (
SELECT date_trunc('month', call_block_time) as month
       , count(*) as nft_sold
FROM opensea_polygon_v2."ZeroExFeeWrapper_call_matchOrders"
WHERE  call_block_time >= date('{{From}}')
AND call_block_time < date('{{To}}')
GROUP BY 1)

SELECT AVG(nft_sold) as avg_nft_sold
FROM CTE
