import bootbox from "bootbox";

function rebalanceConf(){
  document.querySelector('#rebalance-btn').addEventListener('click', (e)=>{
    e.preventDefault();
    bootbox.confirm({
      title: "Rebalance Portfolio?",
      size: "small",
      centerVertical: true,
      backdrop: true,
      message: "We will execute the required trades in order to \
      meet your set allocations. This shouldn't be done too often \
      as Binance will charge you a commision for each trade! Still want us to go ahead?",
      buttons: {
          cancel: {
              label: '<i class="fa fa-times"></i> Nope'
          },
          confirm: {
              label: '<i class="fa fa-check"></i> Rebalance!',
              className: 'btn-success'
          }
      },
      callback: function(result){
       if(result === true){
        document.querySelector('#rebalance-btn').submit();
        var dialog = bootbox.dialog({
            title: 'Rebalancing Portfolio',
            message: '<p><i class="fa fa-spin fa-spinner"></i> Rebalancing at work...</p>'
        });

        dialog.init(function(){
            setTimeout(function(){
                dialog.find('.bootbox-body').html('I was loaded after the dialog was shown!');
            }, 60000);
        });
        }
      }
    })
  });
}

function sellConf(){
  document.querySelector('#sell-btn').addEventListener('click', (e)=>{
    e.preventDefault();
    bootbox.confirm({
      size: "small",
      title: "Feeling drastic?",
      centerVertical: true,
      backdrop: true,
      message: "We will sell all your crypto to USD Tether. This will \
      mean you will stabilise your portfolio and miss out on any \
      gains or losses! Are you sure?",
      buttons: {
          cancel: {
              label: '<i class="fa fa-times"></i> Not sure'
          },
          confirm: {
              label: '<i class="fa fa-check"></i> SELL SELL!',
              className: 'btn-danger'
          }
      },
      callback: function(result){
       if(result === true){
        document.querySelector('#sell').submit();
        var dialog = bootbox.dialog({
            title: "Don't Panic",
            message: '<p><i class="fa fa-spin fa-spinner"></i> Positions being sold...</p>'
        });

        dialog.init(function(){
            setTimeout(function(){
                dialog.find('.bootbox-body').html('I was loaded after the dialog was shown!');
            }, 60000);
        });
        }
      }
    })
  });
}

export { rebalanceConf, sellConf }
