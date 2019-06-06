function allocationChart(){

// Load the Visualization API and the corechart package.
google.charts.load('current', {'packages':['corechart']});

// Set a callback to run when the Google Visualization API is loaded.
google.charts.setOnLoadCallback(drawChart);

// Callback that creates and populates a data table,
// instantiates the pie chart, passes in the data and
// draws it.
}
console.log(coins);

function updateChart(){
  document.querySelectorAll('.num_input').forEach( (input) => {
    input.addEventListener('change', (evt) => {
      dataHash[evt.target.id] = evt.target.value;
      console.log(dataHash);
    });
  });
};



function drawChart() {

  var data = new google.visualization.DataTable();
  data.addColumn('string', 'Coin');
  data.addColumn('number', 'Value');

  data.addRows(dataHash);

  // Set chart options
  var options = {
    'title':'Allocations',
    'height': 500,
    'legend' : {position: 'bottom'}
  };

  // Instantiate and draw our chart, passing in some options.
  var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
  chart.draw(data, options);
};

export {allocationChart, updateChart}
