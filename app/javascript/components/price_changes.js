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

  var priceChanges = []

  function fetch_data(symbol, pair){
    fetch(`https://www.binance.com/api/v1/ticker/24hr?symbol=${pair}`)
    .then(response => response.json())
    .then((data) => {
      var currency = {}
      currency['symbol'] = symbol;
      currency['priceChange'] = data['priceChange'];
      currency['priceChangePercent'] = data['priceChangePercent'];
      priceChanges.push(currency);
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

  // function add_data(){

  // }

  build_data();
  console.log(priceChanges);
}

export { get_price_change };
