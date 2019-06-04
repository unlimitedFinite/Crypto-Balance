require 'open-uri'
require 'json'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)



puts 'Destroying db contents'
# Delete records
Coin.destroy_all

puts 'Creating coins'

coins = ['Bitcoin','Ethereum','Ripple','Bitcoin-Cash','Litecoin','EOS','Cardano','Tether','Tron','Stellar','Zcash']
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
    usdt_price = 0
    btc_price = 0
  elsif coin == 'Bitcoin'
    usdt_price = usdt_data['price']
    btc_price = 0
  else
    usdt_price = usdt_data['price']
    btc_price = btc_data['price']
  end

  Coin.create(
    name: coin,
    symbol: symbol,
    usdt_price: usdt_price,
    btc_price: btc_price,
    is_base_coin: is_base_coin
  )
end


