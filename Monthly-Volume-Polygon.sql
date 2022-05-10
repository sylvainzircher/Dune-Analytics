------------------------------------------------------------------------------------
-- Polygon | volume
------------------------------------------------------------------------------------

WITH token_mat AS
(
    SELECT call_tx_hash AS tx_hash
    -- , CASE
    --   -- WETH | https://polygonscan.com/address/0x7ceb23fd6bc0add59e62ac25578270cff1b9f619
    --   WHEN ("leftOrder"->'makerAssetData')::text = '"0xf47261b00000000000000000000000007ceb23fd6bc0add59e62ac25578270cff1b9f619"' THEN '\x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619'
    --   -- DAI | https://polygonscan.com/address/0x8f3cf7ad23cd3cadbd9735aff958023239c6a063
    --   WHEN ("leftOrder"->'makerAssetData')::text = '"0xf47261b00000000000000000000000008f3cf7ad23cd3cadbd9735aff958023239c6a063"' THEN '\x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063'
    --   -- REVV | https://polygonscan.com/address/0x70c006878a5a50ed185ac4c87d837633923de296
    --   WHEN ("leftOrder"->'makerAssetData')::text = '"0xf47261b000000000000000000000000070c006878a5a50ed185ac4c87d837633923de296"' THEN '\x70c006878a5a50ed185ac4c87d837633923de296'
    --   -- USDC | https://polygonscan.com/address/0x2791bca1f2de4661ed88a30c99a7a9449aa84174
    --   WHEN ("leftOrder"->'makerAssetData')::text = '"0xf47261b00000000000000000000000002791bca1f2de4661ed88a30c99a7a9449aa84174"' THEN '\x2791Bca1f2de4661ED88A30C99A7a9449Aa84174'
    --   -- Else DAI
    --   ELSE '\x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063'::bytea
    -- All the above can be replaced by:
    , concat('\x', right(to_json("leftOrder"->'makerAssetData'::text) #>> '{}', 40)) as token_address
    , CASE 
    WHEN ("leftOrder"->'makerAssetData')::text = '"0xf47261b00000000000000000000000002791bca1f2de4661ed88a30c99a7a9449aa84174"' THEN 6
    ELSE 18
    END AS decimals
    FROM opensea_polygon_v2."ZeroExFeeWrapper_call_matchOrders"
    WHERE call_block_time >= date('{{From}}')
    AND call_block_time < date('{{To}}')    
),

polygon as (
SELECT
    'Polygon' as Blockchain
    , date_trunc('month', om."call_block_time") AS MONTH
    -- The LEAST function returns the “least” or “smallest” value from the list of expressions.
    , SUM(p.price * least("output_matchedFillResults"->'left'->'makerFeePaid', "output_matchedFillResults"->'right'->'takerFeePaid')::numeric / 10^token_mat.decimals) as usd
FROM opensea_polygon_v2."ZeroExFeeWrapper_call_matchOrders" om
INNER JOIN token_mat 
    ON token_mat.tx_hash = om.call_tx_hash
INNER JOIN prices.usd p 
    ON p.minute = date_trunc('minute', om.call_block_time)
    AND token_mat.token_address::bytea = p.contract_address
GROUP BY 1, 2)

select * from polygon
