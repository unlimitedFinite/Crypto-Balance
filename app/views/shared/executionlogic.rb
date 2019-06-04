
# calculation for initial set up

# If in USDT base
# take portfolio balance
# Take allocations % per coin and calculate the allocation in coin amounts
# amount = $1000 * 40% BTC
# allocation = $400
# number of coins target = allocation / coin.USDT price

# If in BTC base = 2btc
# take portfolio BTC balance
# Leave 40% BTC in portfolio
# Take the coin/BTC price
# number of alt coins target = Divide btc balance / coin price in btc


# execution ideal liquidty and volatility conditions within a time window

# if buying then take the live bid price to calculate and factor in the liquidity
# if selling then take the live offer price to calculate and factor in the liquidity
# Take a look at the rolling 5 min volatility and its moving average

# what if get partial fill...resubmit?

# submit better bids/offers inside the spread before dealing at market after 5 mins


# calculation for rebalancing

# Take USDT portfolio value
# take difference in % between target and current allocation
# portfolio value in USDT x diff % = USD difference
# USD difference/ coin.USDT price = number of coins to buy/sell

# to make it easier just do BTC or USDT conversion via the spot rate first then
# apply all excution logic in one standard method.

def portfolio_setup(balance_in_USDT)
end
