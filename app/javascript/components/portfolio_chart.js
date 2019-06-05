function loadChart(){

// Load the Visualization API and the corechart package.
google.charts.load('current', {'packages':['corechart']});

// Set a callback to run when the Google Visualization API is loaded.
google.charts.setOnLoadCallback(drawChart);

// Callback that creates and populates a data table,
// instantiates the pie chart, passes in the data and
// draws it.
}


function drawChart() {

  // Create the data table.
  var data = new google.visualization.DataTable();
  data.addColumn('string', 'Coin');
  data.addColumn('number', 'Value');
  console.log(positions);
  console.log(coins);

  function findCoinName(coinId) {
    let coin = coins.find(function(c) {
      return c['id'] === coinId;
    });
    return coin['name'];
  }

  var dataArray = [];

  var count = Object.keys(positions).length;
  for(var i = 0 ; i < count ; i++ ){
    // coin = coin(id);
    dataArray.push( [ findCoinName(positions[i]['coin_id']), positions[i]['current_value'] ]);
  };
  // console.log(dataArray)
  data.addRows(dataArray)

  // Set chart options
  var options = {'title':'Current Positions In Portfolio',
                 'width':400,
                 'height':300};

  // Instantiate and draw our chart, passing in some options.
  var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
  chart.draw(data, options);
};

export {loadChart}
