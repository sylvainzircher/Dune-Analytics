------------------------------------------------------------------------------------------------
-- Polygon
------------------------------------------------------------------------------------------------
-- From Opensea | https://docs.opensea.io/reference/terminology

-- A maker is the first mover in a trade. 
-- Makers either declare intent to sell an item, or they declare intent 
-- to buy by bidding on one

-- A taker is the counterparty who responds to a maker's order by, 
-- respectively, either buying the item or accepting a bid on it.
------------------------------------------------------------------------------------------------

with makerNtaker as (
    -- Listing all takers and makers i.e. all accounts that transacted
    -- Taker
    SELECT date_trunc('day', MIN(call_block_time)) AS date
        , "leftOrder"->'makerAddress' AS account
     FROM opensea_polygon_v2."ZeroExFeeWrapper_call_matchOrders"
     GROUP BY 2
     UNION 
     -- Maker
     SELECT date_trunc('day', MIN(call_block_time)) AS date
        , "rightOrder"->'makerAddress' AS account
     FROM opensea_polygon_v2."ZeroExFeeWrapper_call_matchOrders"
     GROUP BY 2
),

uniqueAccounts as (
    -- Getting all unique accounts regardless of whether they are Taker or Maker
    SELECT account
        , min(date) as date
    FROM makerNtaker
    group by 1
),

countAccounts as (
    -- Count of accounts over time
    SELECT date
        , count(distinct account) as accounts
    FROM uniqueAccounts
    GROUP BY 1
)

-- Cumulated number of accounts over time
SELECT date
    , sum(accounts) OVER (ORDER BY date) as cumulated_traders
FROM countAccounts
