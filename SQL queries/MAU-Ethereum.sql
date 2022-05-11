------------------------------------------------------------------------------------------------
-- Ethereum | Monthly Active Users
------------------------------------------------------------------------------------------------


with makerNtaker as (
    SELECT date_trunc('month', evt_block_time) AS date
        , maker AS account
    FROM opensea."WyvernExchange_evt_OrdersMatched"
    WHERE  evt_block_time >= date('{{From}}')
    AND evt_block_time < date('{{To}}')
    UNION 
    SELECT date_trunc('month', evt_block_time) AS date
        , taker AS account
    FROM opensea."WyvernExchange_evt_OrdersMatched"
    WHERE  evt_block_time >= date('{{From}}')
    AND evt_block_time < date('{{To}}')    
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
