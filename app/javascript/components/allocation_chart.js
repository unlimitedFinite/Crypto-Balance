function allocationChart(){

// Load the Visualization API and the corechart package.
google.charts.load('current', {'packages':['corechart']});

// Set a callback to run when the Google Visualization API is loaded.
// google.charts.setOnLoadCallback(drawChart);
}

function setListeners(){
  document.querySelectorAll('.num_input').forEach( (input) => {
    input.addEventListener('change', (evt) => {
      dataHash[evt.target.id] = evt.target.value;
      console.log(dataHash);
    });
  });
};

function updateChart(){
  document.querySelector('#update').addEventListener('click', (e) => {
    for (let [key, value] of Object.entries(dataHash)) {
      console.log(typeof(key) + ' ' + typeof(value));
      dataArray.push([key.toString(), parseInt(value)]);
      drawChart();
    };
  })
}

function resetdataArray(){

}

function drawChart() {

  var data = new google.visualization.DataTable();
  data.addColumn('string', 'Coin');
  data.addColumn('number', 'Value');

  data.addRows(dataArray);

  // Set chart options
  var options = {
    'title':'Allocations',
    'height': 500,
    'legend' : {position: 'bottom'}
  };

  // Instantiate and draw our chart, passing in some options.
  var chart = new google.visualization.BarChart(document.getElementById('chart_div'));
  chart.draw(data, options);
};

export {allocationChart, setListeners, updateChart}
