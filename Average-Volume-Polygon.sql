------------------------------------------------------------------------------------
-- Polygon | Avg Transaction Value
------------------------------------------------------------------------------------

WITH token_mat AS
(
    SELECT call_tx_hash AS tx_hash
    , concat('\x', right(to_json("leftOrder"->'makerAssetData'::text) #>> '{}', 40)) as token_address
    , CASE 
    WHEN ("leftOrder"->'makerAssetData')::text = '"0xf47261b00000000000000000000000002791bca1f2de4661ed88a30c99a7a9449aa84174"' THEN 6
    ELSE 18
    END AS decimals
    FROM opensea_polygon_v2."ZeroExFeeWrapper_call_matchOrders"
    WHERE call_block_time >= date('{{From}}')
    AND call_block_time < date('{{To}}')      
)

SELECT AVG(p.price * least("output_matchedFillResults"->'left'->'makerFeePaid', "output_matchedFillResults"->'right'->'takerFeePaid')::numeric / 10^token_mat.decimals) as usd
FROM opensea_polygon_v2."ZeroExFeeWrapper_call_matchOrders" om
INNER JOIN token_mat 
    ON token_mat.tx_hash = om.call_tx_hash
INNER JOIN prices.usd p 
    ON p.minute = date_trunc('minute', om.call_block_time)
    AND token_mat.token_address::bytea = p.contract_address
