const allocationsEditPage = document.querySelector('.portfolios.edit');
const allocationsNewPage = document.querySelector('.portfolios.new');
if (allocationsEditPage != null || allocationsNewPage != null) {
  // Load the Visualization API and the corechart package.
  google.charts.load('current', {'packages':['corechart']});

  // Set a callback to run when the Google Visualization API is loaded.
  google.charts.setOnLoadCallback(loadIndex);
}



// function sumAllocations(oldValue, newValue){
//   var span = document.getElementById("allocations");
//   oldValue = oldValue || 0;
//   if (newValue >= oldValue){
//     sum += newValue;
//   }
//   else {
//     sum = (sum - oldValue) + newValue;
//   }
//   console.log(sum);
//   if (sum > 100){
//     span.innerText = (`Please deduct ${sum - 100} shares!`);
//     document.getElementById("submit-alloc").disabled = true;
//   } else if (sum < 100){
//     span.innerText = (`Please add ${100 - sum} more shares`);
//     document.getElementById("submit-alloc").disabled = true;
//   } else {
//     span.innerText = (`That's perfect!`);
//     document.getElementById("submit-alloc").disabled = false;
//   }
// }




// function initdataArray(){
//   var coins = ['Bitcoin','Ethereum','Ripple','Bitcoin-Cash','Litecoin','EOS','Cardano','Tron','Stellar','Zcash'];
//   coins.forEach(function(c) {
//     dataArray.push( [c, 0] );
//   });
// }


// function setListeners(){
//   document.querySelectorAll('.num_input').forEach( (input) => {
//     input.addEventListener('change', (evt) => {
//       console.log(evt);
//       sumAllocations(parseInt(evt.target.oldvalue), evt.target.valueAsNumber);
//       dataHash[evt.target.id] = evt.target.value;
//       updateChart();
//     });
//   });
// };


// function updateChart(){
//   dataArray = [];

//   for (let [currency, value] of Object.entries(dataHash)) {
//     currency = currency.replace('crypto_', '')
//     dataArray.push([currency, parseInt(value)]);
//   };
//   drawChart();
// }
function resetIndex(){
  var inputs = document.querySelectorAll('.num_input');
  inputs.forEach(function(i){
    i.value = 10;
  })
  addValues();
  prepareData();
}

// function reset-listen(){
//   var reset = document.getElementById("reset-btn");
//   reset.addEventListener('click', (e) => {
//     reset();
//   })
// }


function loadIndex(){
  var inputs = document.querySelectorAll('.num_input');
  inputs.forEach(function(i){
    // i.value = 10;
    if (i.value === "") {
      i.value = 10;
    }
  })
  addValues();
  prepareData();
}


function addValues(){
  var sum = 0
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
      prepareData();
    });
  });
  var reset = document.querySelector(".index-btn");
  reset.addEventListener('click', (e) => {
    resetIndex();
  })
}

function prepareData(){
  var inputs = document.querySelectorAll('.num_input');
  inputs.forEach(function(i){
    var value = parseInt(i.value);
    dataHash[i.name] = value;
  })
  var data = []
  data.push(Object.keys(dataHash));
  data.push(Object.values(dataHash));
  drawChart(data);
}


// convert hash into dataArray and send to chart


function displaySum(sum){
  var span = document.getElementById("allocations");
  var button = document.getElementById("submit-alloc");
  var shares = document.getElementById('shares');
  if (sum > 100){
    shares.classList.remove('green', 'yellow')
    shares.classList.add('red');
    span.innerText = (`You need to deduct ${sum - 100} shares!`);
    button.disabled = true;
  } else if (sum < 100){
    shares.classList.remove('red', 'green')
    shares.classList.add('yellow');
    span.innerText = (`You need to add ${100 - sum} shares!`);
    button.disabled = true;
  } else {
    button.disabled = false;
    shares.classList.remove('red', 'yellow')
    shares.classList.add('green');
    span.innerText = ('Nice one! Now you can submit!')
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
      prepareData();
  });
}

function drawChart(dataArray) {

  dataArray[0].unshift('Coins');
  dataArray[1].unshift('');

  var data = google.visualization.arrayToDataTable([
               dataArray[0],
               dataArray[1]
            ]);

  // Set chart options
  var options = {
    title     : '',
    width : '94%',
    viewWindow: { min: 0, max: 100 },
    isStacked : 'percent',
    chartArea: {left:20, right:20, width:'100%', height: '100%'},
    legend    : {position: 'none'},
    backgroundColor : '#173055',
    colors: ['#edc948','#76b8b2','#4e79a7','#59a04e','#b9b0ac','#9b745f','#b07aa1','#e15658','#86bcb6','#f28d31']
  };

  // Instantiate and draw our chart, passing in some options.
  var chart = new google.visualization.BarChart(document.getElementById('alloc_chart'));
  chart.draw(data, options);
};


export { prepareData, addValues, listeners, allocationChart}
