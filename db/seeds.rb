# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


coin_list = %w(BTC ETH XRP EOS BitcoinCash LTC ETHclassic ZCash Monero)
puts "creating coins"
coin_list.each do |coin|
  Coin.create(
    name: coin,
    symbol: coin,
    current_price: rand(1000..8000),
    is_base_coin: false
  )
end

puts "creating portfolio"
Portfolio.create(
  rebalance_freq: "weekly",
  next_rebalance_dt: Date.today,
  user_id: 1,
  current_value: rand(1000..8000),
  coin_id: 1
  )
# Portfolio.create(rebalance_freq: "weekly", next_rebalance_dt: Date.today, user_id: 1, current_value: rand(1000..8000), coin_id: 1)
