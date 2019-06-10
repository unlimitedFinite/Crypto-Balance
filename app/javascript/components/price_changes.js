function get_price_change(){

  function collect_symbols(){
    const arrOfSymbols = [];
    const allSymbols = document.querySelectorAll('.binance-symbols').forEach(element => arrOfSymbols.push(element.id.replace('value24', '')));
    var index = arrOfSymbols.indexOf('USDT');
    if (index > -1) {
      arrOfSymbols.splice(index, 1);
    };
    return arrOfSymbols
  }

  function fetch_data(symbol, pair){
    fetch(`https://www.binance.com/api/v1/ticker/24hr?symbol=${pair}`)
    .then(response => response.json())
    .then((data) => {
      var currency = {}
      currency['symbol'] = symbol;
      currency['priceChange'] = data['priceChange'];
      currency['priceChangePercent'] = data['priceChangePercent'];
      currency['price'] = data['lastPrice'];
      priceChanges.push(currency);

      add_data(priceChanges);
    });
  };

  function build_data(){
    collect_symbols().forEach(function(symbol) {
      var pair = '';
      if (symbol === 'BTC'){
        pair = 'BTCUSDT';
      } else {
        pair = symbol + 'BTC';
      }
      fetch_data(symbol, pair);
    });
  }

  function add_data(priceChanges){
    if (priceChanges.length > 8) {
      var symbol = priceChanges[0]['symbol'];
      var percentSpan = document.getElementById(`${symbol}percent24`);
      var valueSpan = document.getElementById(`${symbol}value24`);
      var percent = priceChanges[0]['priceChangePercent'];
      var value = priceChanges[0]['priceChange'];
      var price = priceChanges[0]['price'];
      percentSpan.innerText = `24 hour: ${Math.round(percent * 100) / 100}%`;
      valueSpan.innerText = `24 hour: $${Math.round((value / price) * 100) / 100}`;
    };
  }


  build_data();
}


export { get_price_change };
