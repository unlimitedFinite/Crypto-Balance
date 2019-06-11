function sumAllocations(oldValue, newValue){
  var span = document.getElementById("allocations");
  oldValue = oldValue || 0;
  if (newValue >= oldValue){
    sum += newValue;
  }
  else {
    sum = (sum - oldValue) + newValue;
  }

  if (sum > 100){
    span.innerText = (`Please deduct ${sum - 100} shares!`);
    document.getElementById("submit-alloc").disabled = true;
  } else if (sum < 100){
    span.innerText = (`Please add ${100 - sum} more shares`);
    document.getElementById("submit-alloc").disabled = true;
  } else {
    span.innerText = (`That's perfect!`);
    document.getElementById("submit-alloc").disabled = false;
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
      console.log(evt);
      sumAllocations(parseInt(evt.target.oldvalue), evt.target.valueAsNumber);
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
    height    : 400,
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
  var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
  chart.draw(data, options);
};

export {allocationChart, setListeners, updateChart, initdataArray, sumAllocations}
