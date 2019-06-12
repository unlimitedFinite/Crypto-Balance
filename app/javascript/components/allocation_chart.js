// Load the Visualization API and the corechart package.
google.charts.load('current', {'packages':['corechart']});

// Set a callback to run when the Google Visualization API is loaded.
google.charts.setOnLoadCallback(drawChart);

function addValues(){
  sum = 0
  var inputs = document.querySelectorAll('.num_input');
  inputs.forEach(function(i){
    var value = parseInt(i.value) || 0;
    sum += value;
  })
  displaySum(sum);
}

function listeners(){
  document.querySelectorAll('.num_input').forEach( (input) => {
    input.addEventListener('change', (evt) => {
      addValues();
    });
  });
}

function displaySum(sum){
  var span = document.getElementById("allocations");
  var button = document.getElementById("submit-alloc");
  var shares = document.getElementById('shares');
  if (sum > 100){
    shares.classList.remove('green', 'yellow')
    shares.classList.add('red');
    span.innerText = (`You've selected ${sum}, deduct ${sum - 100}!`);
    button.disabled = true;
  } else if (sum < 100){
    shares.classList.remove('red', 'green')
    shares.classList.add('yellow');
    span.innerText = (`You've selected ${sum}, add ${100 - sum} more!`);
    button.disabled = true;
  } else {
    button.disabled = false;
    shares.classList.remove('red', 'yellow')
    shares.classList.add('green');
    span.innerText = ('Cool! Now you can submit!')
  }
}

function sumAllocations(oldValue, newValue){
  var span = document.getElementById("allocations");
  oldValue = oldValue || 0;
  if (newValue >= oldValue){
    sum += newValue;
  }
  else {
    sum = (sum - oldValue) + newValue;
  }
  console.log(sum);
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

//create trigger to resizeEnd event
  $(window).resize(function() {
      if(this.resizeTO) clearTimeout(this.resizeTO);
      this.resizeTO = setTimeout(function() {
          $(this).trigger('resizeEnd');
      }, 25);
  });

  //redraw graph when window resize is completed
  $(window).on('resizeEnd', function() {
      drawChart();
      console.log('hello');
  });
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

  var data = google.visualization.arrayToDataTable([
               ['Coins','Bitcoin','Ethereum','Ripple','Bitcoin-Cash','Litecoin','EOS','Cardano','Tron','Stellar','Zcash'],
               ["",10,10,10,10,10,10,10,10,10,10]
            ]);

  // Set chart options
  var options = {
    title     : '',
    width : '94%',
    isStacked : true,
    chartArea: {left:20, right:20, width:'100%'},
    legend    : {position: 'none'},
    backgroundColor : '#173055'
  };

  // Instantiate and draw our chart, passing in some options.
  var chart = new google.visualization.BarChart(document.getElementById('alloc_chart'));
  chart.draw(data, options);
};


export {addValues, listeners, allocationChart, setListeners, updateChart, initdataArray, sumAllocations}
