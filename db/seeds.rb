require 'open-uri'
require 'json'
require 'pry-byebug'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


puts 'Destroying db contents'
# Delete records
User.destroy_all
Portfolio.destroy_all
Allocation.destroy_all
Coin.destroy_all

puts 'creating test user'

User.create(
  first_name: 'Testing',
  last_name: 'Tester',
  email: 'test@testing.com',
  password: 'secret',
  api_key: 'S1zgR71EfhvPCObCe4FhO0Fl79Cqlh4fWYEuUZVAu7YysNXutTwZsdJf5Xz5Ho7K',
  secret_key: 'SE5vnFHHEUFpZGNoALl4ANhE3mntrFe5UIHeRNRukm8mGK0jF4oMR4MOovIsd7bR'
)

puts 'Creating coins'

coins = ['Bitcoin','Ethereum','Ripple','Bitcoin-Cash','Litecoin','EOS','Cardano','Tether','Tron','Stellar','Zcash']
lots = {
  BTC: 0.000001,
  ETH: 0.001,
  XRP: 1,
  BCHABC: 0.001,
  LTC: 0.01,
  EOS: 1,
  ADA: 1,
  USDT: 0.000001,
  TRX: 1,
  XLM: 1,
  ZEC: 0.001
}

colors = {
  BTC: '#F7931A',
  ETH: '#627EEA',
  XRP: '#00AAE4',
  BCHABC: '#8dc351',
  LTC: '#CBC6C6',
  EOS: '#000000',
  ADA: '#3CC8C8',
  USDT: '#26A17B',
  TRX: '#000000',
  XLM: '#14B6E7',
  ZEC: '#ECB244'
}

images = {
  BTC: 'https://res.cloudinary.com/deyw9z6tu/image/upload/v1559749966/crypto-balance/btc_vjj2fj.svg',
  ETH: 'https://res.cloudinary.com/deyw9z6tu/image/upload/v1559749964/crypto-balance/eth_vdvw3n.svg',
  XRP: 'https://res.cloudinary.com/deyw9z6tu/image/upload/v1559749966/crypto-balance/xrp_rh5xm5.svg',
  BCHABC: 'https://res.cloudinary.com/deyw9z6tu/image/upload/v1559749966/crypto-balance/bch_e8tpwh.svg',
  LTC: 'https://res.cloudinary.com/deyw9z6tu/image/upload/v1559749967/crypto-balance/ltc_ru9yju.svg',
  EOS: 'https://res.cloudinary.com/deyw9z6tu/image/upload/v1559749964/crypto-balance/eos_vkfxcq.svg',
  ADA: 'https://res.cloudinary.com/deyw9z6tu/image/upload/v1559749965/crypto-balance/ada_t52cdf.svg',
  USDT: 'https://res.cloudinary.com/deyw9z6tu/image/upload/v1559749964/crypto-balance/usd_dt2gbs.svg',
  TRX: 'https://res.cloudinary.com/deyw9z6tu/image/upload/v1559749967/crypto-balance/trx_n6rkew.svg',
  XLM: 'https://res.cloudinary.com/deyw9z6tu/image/upload/v1559749964/crypto-balance/xlm_grrgrn.svg',
  ZEC: 'https://res.cloudinary.com/deyw9z6tu/image/upload/v1559749967/crypto-balance/zec_ajbvsu.svg'
}

base_coins = ['BTC','USDT']


coins.each do |coin|
  coin_name_url = "https://api.99cryptocoin.com/v1/ticker/#{coin}"
  coin_name_json = open(coin_name_url).read
  coin_name_data = JSON.parse(coin_name_json)

  symbol = coin_name_data['result']['symbol']
  symbol = 'BCHABC' if symbol == 'BCH'

  is_base_coin = true if base_coins.include?(symbol)

  unless symbol == 'USDT'
    usdt_url = "https://www.binance.com/api/v3/ticker/price?symbol=#{symbol}USDT"
    usdt_json = open(usdt_url).read
    usdt_data = JSON.parse(usdt_json)
  end

  unless is_base_coin
    btc_url = "https://www.binance.com/api/v3/ticker/price?symbol=#{symbol}BTC"
    btc_json = open(btc_url).read
    btc_data = JSON.parse(btc_json)
  end


  if coin == 'Tether'
    price_usdt = 1
    price_btc = 0
  elsif coin == 'Bitcoin'
    price_usdt = usdt_data['price']
    price_btc = 1
  else
    price_usdt = usdt_data['price']
    price_btc = btc_data['price']
  end

  Coin.create(
    name: coin,
    symbol: symbol,
    price_usdt: price_usdt,
    price_btc: price_btc,
    is_base_coin: is_base_coin,
    lot_size: lots.fetch(symbol.to_sym),
    image: images.fetch(symbol.to_sym),
    color: colors.fetch(symbol.to_sym)
  )
end

puts 'creating portfolio for test user'

Portfolio.create(
  rebalance_freq: 'Daily',
  next_rebalance_dt: '3/7/19',
  user_id: 1,
  current_value_usdt: 0,
  coin_id: 1
  )

puts 'making allocations for test user test portfolio'

10.times do
  Allocation.create(
    allocation_pct: 10,
    coin_id: rand(1..11),
    portfolio_id: 1
  )
end

