import {introJs} from 'intro.js';
import 'intro.js/minified/introjs.min.css';

function apiHelper(){

  var introGuide = introJs();

  introGuide.setOptions({
    steps: [
      {
        element: '.apiInfo',
        intro: `In order to maintain the required distribution across your chosen allocations, CryptoBalance makes trades on Binance. These trades are facilitated through the exchange's API, for which we need your keys.`,
        position: 'bottom'
      },
      {
        element: '.apikeys',
        intro: 'Please login to your Binance account and set up an API key pair. You can then copy and paste the keys here to allow us to trade on your behalf',
        position: 'bottom'
      }
    ]
  })
  document.querySelector('#api').addEventListener('click', (e) => {
    e.preventDefault();
    introGuide.start();
  });
}

function portfolioHelper(){

  var introGuide = introJs();

  introGuide.setOptions({
    steps: [
      {
        element: '.helper1',
        intro: `This is where you can set up your auto rebalance schedule. We recommend to set this to weekly, as you can always manually rebalance from your dashboard! `,
        position: 'right'
      },
      {
        element: '.helper2',
        intro: 'Here is where you can define your allocations. We have preloaded an equal share of each coin, feel free to change them!',
        position: 'top'
      },
      {
        element: '.helper3',
        intro: 'If you accidently set your allocations too high or low, you can see how far off you are before submitting!',
        position: 'left'
      }
    ]
  })
  // document.querySelector('#api').addEventListener('click', (e) => {
  //   e.preventDefault();
    introGuide.start();
  // });
}

function dashboardHelper(){

  var introGuide = introJs();

  introGuide.setOptions({
    steps: [
      {
        element: '.price-container',
        intro: `Here you can see your current portfolio balance in USD value`,
        position: 'bottom'
      },
      {
        element: '.helper2',
        intro: 'Here you can see the coins current weight, and the portfolio target',
        position: 'right'
      },
      {
        element: '.helper3',
        intro: 'This is current value of the coin in USD',
        position: 'left'
      },
      {
        element: '.helper4',
        intro: 'This section shows the latest price and the change over last 24 hours',
        position: 'left'
      },
      {
        element: '.helper5',
        intro: 'This button will manually force a rebalance of your portfolio, which is advised if there has been some big changes in the market',
        position: 'left'
      },
      {
        element: '.helper6',
        intro: 'Refresh to get the latest prices',
        position: 'bottom'
      },
      {
        element: '.helper7',
        intro: 'If you have a feeling the market is about to tumble, you can quickly sell your positions to USDT',
        position: 'right'
      }
    ]
  })
  document.querySelector('#guide').addEventListener('click', (e) => {
    console.log(e);
    e.preventDefault();
    introGuide.start();
  });
}




export {apiHelper, portfolioHelper, dashboardHelper}
