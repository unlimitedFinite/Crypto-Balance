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
  //
  var coin = coins.find( c => {
      return c.id === positions[0]['coin_id'];
    })
  data.addRows([
    [coin['name'], positions[0]['current_value']],
    [positions[1]['coin_id'].toString(), positions[1]['current_value']],
    [positions[2]['coin_id'].toString(), positions[2]['current_value']],
    [positions[3]['coin_id'].toString(), positions[3]['current_value']],
    [positions[4]['coin_id'].toString(), positions[4]['current_value']],
    [positions[5]['coin_id'].toString(), positions[5]['current_value']],
    [positions[6]['coin_id'].toString(), positions[6]['current_value']],
    [positions[7]['coin_id'].toString(), positions[7]['current_value']]
  ]);

  // Set chart options
  var options = {'title':'Current Positions In Portfolio',
                 'width':400,
                 'height':300};

  // Instantiate and draw our chart, passing in some options.
  var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
  chart.draw(data, options);
};

export {loadChart}
