-----------------------------------------------------------------------------------------------------------------------
-- Counts the number of nft sold per month on Opensea for the Polygon blockchain
-----------------------------------------------------------------------------------------------------------------------
SELECT 
       date_trunc('month', call_block_time) as month
       , count(*) as nft_sold
FROM opensea_polygon_v2."ZeroExFeeWrapper_call_matchOrders"
WHERE  call_block_time >= date('{{From}}')
and call_block_time < date('{{To}}')
GROUP BY 1
ORDER BY 1
