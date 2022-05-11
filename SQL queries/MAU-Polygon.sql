------------------------------------------------------------------------------------------------
-- Polygon | Monthly Active Users
------------------------------------------------------------------------------------------------

with makerNtaker as (
    -- Listing all takers and makers i.e. all accounts that transacted
    -- Taker
    SELECT date_trunc('month', MIN(call_block_time)) AS date
        , "leftOrder"->'makerAddress' AS account
     FROM opensea_polygon_v2."ZeroExFeeWrapper_call_matchOrders"
     WHERE  call_block_time >= date('{{From}}')
     AND call_block_time < date('{{To}}')
     GROUP BY 2
     UNION 
     -- Maker
     SELECT date_trunc('month', MIN(call_block_time)) AS date
        , "rightOrder"->'makerAddress' AS account
     FROM opensea_polygon_v2."ZeroExFeeWrapper_call_matchOrders"
     WHERE  call_block_time >= date('{{From}}')
     AND call_block_time < date('{{To}}')     
     GROUP BY 2
),

staging as (
SELECT date as month
    , count(distinct account) AS MAU
FROM makerNtaker
GROUP BY 1
ORDER BY 1)

SELECT month
    , MAU
    , LAG(MAU, 1) OVER (ORDER BY month)  MAU_previous_month
    , MAU - LAG(MAU, 1) OVER (ORDER BY month)  MAU_change
    , (MAU - LAG(MAU, 1) OVER (ORDER BY month)) /  LAG(MAU, 1) OVER (ORDER BY month)::float as MAU_change_perc
FROM staging
