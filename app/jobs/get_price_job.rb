require 'sidekiq-scheduler'

class GetPriceJob < ApplicationJob
  queue_as :default

  def perform
    coins = Coin.all
    coins.each do |coin|
      puts "Calling Binance API for #{coin.name}..."
      require 'open-uri'
      require 'json'

      unless coin.symbol == 'USDT'
        usdt_url = "https://www.binance.com/api/v3/ticker/price?symbol=#{coin.symbol}USDT"
        usdt_json = open(usdt_url).read
        usdt_data = JSON.parse(usdt_json)
      end

      unless coin.is_base_coin
        btc_url = "https://www.binance.com/api/v3/ticker/price?symbol=#{coin.symbol}BTC"
        btc_json = open(btc_url).read
        btc_data = JSON.parse(btc_json)
      end

      if coin.symbol == 'USDT'
        price_usdt = 1
        price_btc = 0
      elsif coin.symbol == 'BTC'
        price_usdt = usdt_data['price']
        price_btc = 1
      else
        price_usdt = usdt_data['price']
        price_btc = btc_data['price']
      end

      coin.price_usdt = price_usdt
      coin.price_btc = price_btc
      coin.save
      puts "Done! Updated #{coin.name} from Binance"
      end
  end
end
