------------------------------------------------------------------------------------------------
-- Ethereum | Cumulated number of users
------------------------------------------------------------------------------------------------

with makerNtaker as (
    -- Listing all takers and makers i.e. all accounts that transacted
    SELECT date_trunc('month', evt_block_time) AS date
        , maker AS account
    FROM opensea."WyvernExchange_evt_OrdersMatched"
    UNION 
    SELECT date_trunc('month', evt_block_time) AS date
        , taker AS account
    FROM opensea."WyvernExchange_evt_OrdersMatched"
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
