

// Load the Visualization API and the corechart package.
google.charts.load('current', {'packages':['corechart']});

// Set a callback to run when the Google Visualization API is loaded.
google.charts.setOnLoadCallback(drawChart);

// Callback that creates and populates a data table,
// instantiates the pie chart, passes in the data and
// draws it.




function drawChart() {

  // Create the data table.
  var data = new google.visualization.DataTable();
  data.addColumn('string', 'Coin');
  data.addColumn('number', 'Value');

  const colors = []

  function findCoin(coinId) {
    let coin = coins.find(function(c) {
      return c['id'] === coinId;
    });
    colors.push(coin['color']);
    return coin['name'];
  }

  // coins.forEach(function(c){
  //   if findColor(c) == true
  //   colors.push(c.color);
  // });

  var dataArray = [];

  var count = Object.keys(positions).length;
  for(var i = 0 ; i < count ; i++ ){
    dataArray.push( [ findCoin(positions[i]['coin_id']),  Math.round(positions[i]['value_usdt']) ]);
  };
  data.addRows(dataArray);

  // Set chart options
  var options = {
    'title':'Portfolio Positions',
    height: 400,
    width: '100%',
    'chartArea': {left:0, top:0, width:'100%', height:'100%'},
    'legend' : {position: 'bottom'},
    'colors': colors,
    backgroundColor: '#173055'
  };

  // Instantiate and draw our chart, passing in some options.
  var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
  chart.draw(data, options);
};

export {loadChart}
