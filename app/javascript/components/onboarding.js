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
        intro: 'Here you can manually set your target allocations. Just increase or decrease until you reach 100%!',
        position: 'top'
      },
      {
        element: '.helper3',
        intro: 'If you dont feel like choosing your own allocations, we can set your portfolio to match our recommended index!',
        position: 'left'
      }
    ]
  })
  // document.querySelector('#api').addEventListener('click', (e) => {
  //   e.preventDefault();
    introGuide.start();
  // });
}



export {apiHelper, portfolioHelper}
