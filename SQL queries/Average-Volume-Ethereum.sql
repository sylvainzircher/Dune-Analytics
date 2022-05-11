------------------------------------------------------------------------------------
-- Ethereum | average volume
------------------------------------------------------------------------------------


-- ETHEREUM
-- Credits to https://dune.xyz/queries/3469/6913 | @rchen8 / OpenSea monthly volume (Ethereum)
-- Also great Data Explanation | https://mtitus6.medium.com/dune-nft-trading-volume-939f77a6dcfe
with token_eth AS (
    SELECT DISTINCT call_tx_hash AS tx_hash
    , CASE
        -- Wrapped Ether Contract Address | https://etherscan.io/address/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2
        -- The 7th item (addrs[7]) represents the value of the transfer. 
        -- The value of the transfer is represented by either the USDC, WETH, or mint address.
        -- We must substitute the mint address with the WETH token, since the mint address has no USD value associated with it.
        WHEN addrs[7] = '\x0000000000000000000000000000000000000000' THEN '\xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2' -- WETH
        ELSE addrs[7] -- USDC or WETH
    END AS token_address
    FROM opensea."WyvernExchange_call_atomicMatch_"
    -- The 5th item (addrs[5]) in the list represents the NFT contract address
    -- Open Sea Wallet | https://etherscan.io/address/0x5b3256965e7c3cf26e11fcaf296dfc8807c01073
    WHERE (addrs[4] = '\x5b3256965e7c3cf26e11fcaf296dfc8807c01073' OR addrs[11] = '\x5b3256965e7c3cf26e11fcaf296dfc8807c01073')
    AND call_success
    AND call_block_time >= date('{{From}}')
    AND call_block_time < date('{{To}}')     
),

transactions_to_exclude as (
    select tx_hash
    , count(distinct token_address) as tokens
    from token_eth
    group by 1
    having count(distinct token_address) > 1
)

SELECT AVG((om.price / 10^erc.decimals) * p.price) AS usd
FROM opensea."WyvernExchange_evt_OrdersMatched" om
-- Here we are joining the previously created CTE with the orders matched table to include only transactions that were matched and bring in the price
INNER JOIN token_eth ON token_eth.tx_hash = om.evt_tx_hash
-- By using the erc20.tokens we can find the number of decimals for the token in the CTE
INNER JOIN erc20.tokens erc ON token_eth.token_address = erc.contract_address
-- Finally we can get the usd price at the time the block was created for a specific token (WETH / USDT etc...)
INNER JOIN prices.usd p ON p.minute = date_trunc('minute', om.evt_block_time)
-- Making sure that the seller and buyer are not the same address
AND om.maker != om.taker
-- Making sure we are getting the right USD price based on token address (WETH / USDT ...)
AND token_eth.token_address = p.contract_address
AND p.minute >= date('{{From}}')
AND om.evt_tx_hash not in (Select tx_hash from transactions_to_exclude)
