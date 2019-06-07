function sumAllocations(value){
  var span = document.getElementById("allocations");
  console.log(span);
  sum += value;
  // span.textContent(`Allocated: ${sum}/100 shares`)
  if (sum > 100){
    span.innerText = (`Please deduct ${sum - 100} shares!`)
    document.getElementById("submit-alloc").disabled = true;
  } else {
    span.innerText = (`Please add ${100 - sum} more shares`)
  }
}


function allocationChart(){

  // Load the Visualization API and the corechart package.
  google.charts.load('current', {'packages':['corechart']});

  // Set a callback to run when the Google Visualization API is loaded.
  google.charts.setOnLoadCallback(drawChart);
}

function initdataArray(){
  var coins = ['Bitcoin','Ethereum','Ripple','Bitcoin-Cash','Litecoin','EOS','Cardano','Tron','Stellar','Zcash'];
  coins.forEach(function(c) {
    dataArray.push( [c, 0] );
  });
}


function setListeners(){
  document.querySelectorAll('.num_input').forEach( (input) => {
    input.addEventListener('change', (evt) => {
      sumAllocations(evt.target.valueAsNumber);
      dataHash[evt.target.id] = evt.target.value;
      updateChart();
    });
  });
};

function updateChart(){
  dataArray = [];

  for (let [currency, value] of Object.entries(dataHash)) {
    currency = currency.replace('crypto_', '')
    dataArray.push([currency, parseInt(value)]);
  };
  drawChart();
}



function drawChart() {

  var data = new google.visualization.DataTable();
  data.addColumn('string', 'Coin');
  data.addColumn('number', 'Value');

  data.addRows(dataArray);

  // Set chart options
  var options = {
    title     : 'Allocations',
    height    : 500,
    legend    : {position: 'bottom'},
    ticks     : [0, 25, 50, 75, 100],
    hAxis     : {
      viewWindow: {
        min: 0,
        max: 100
      }
    }
  };

  // Instantiate and draw our chart, passing in some options.
  var chart = new google.visualization.BarChart(document.getElementById('chart_div'));
  chart.draw(data, options);
};

export {allocationChart, setListeners, updateChart, initdataArray, sumAllocations}
