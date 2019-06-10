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
      priceChanges.forEach(function(coin) {
        var symbol = coin['symbol'];
        var percentSpan = document.getElementById(`${symbol}percent24`);
        var valueSpan = document.getElementById(`${symbol}value24`);
        var price = coin['price'];
        var percent = coin['priceChangePercent'];
        var value = Math.round((coin['priceChange'] / price) * 100) / 100;
        if (value > 0) {
          percentSpan.classList.add("price-up");
          valueSpan.classList.add("price-up");
        } else if (value < 0 ){
          percentSpan.classList.add("price-down");
          valueSpan.classList.add("price-down");
        };
        percentSpan.innerText = `${Math.round(percent * 100) / 100}%`;
        valueSpan.innerText = `$${value}`;
      })
    };
  }
  build_data();
}


export { get_price_change };
