------------------------------------------------------------------------------------------------
-- Total number of nfts sold on Polygon Blockchain
------------------------------------------------------------------------------------------------
SELECT count(*) as nft_sold
FROM opensea_polygon_v2."ZeroExFeeWrapper_call_matchOrders"
WHERE call_block_time >= date('{{From}}')
AND call_block_time < date('{{To}}')
