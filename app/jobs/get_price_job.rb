require 'sidekiq-scheduler'
require 'open-uri'
require 'json'

class GetPriceJob < ApplicationJob
  queue_as :default

  def perform
    coins = Coin.all
    coins.each do |coin|
      puts "Calling Binance API for #{coin.name}..."

      unless coin.symbol == 'USDT'
        usdt_data = get_parsed_data("https://www.binance.com/api/v3/ticker/price?symbol=#{coin.symbol}USDT")
      end

      unless coin.is_base_coin
        btc_data = get_parsed_data("https://www.binance.com/api/v3/ticker/price?symbol=#{coin.symbol}BTC")
      end

      bitcoin_data = get_parsed_data("https://www.binance.com/api/v3/ticker/price?symbol=BTCUSDT")

      if coin.symbol == 'USDT'
        price_usdt = 1
        price_btc = 1.0 / bitcoin_data['price'].to_f
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

  private

  def get_parsed_data(url)
    json = open(url).read
    data = JSON.parse(json)
    return data
  end
end
