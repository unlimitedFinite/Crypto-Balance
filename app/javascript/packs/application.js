import "bootstrap";

import { apiHelper, portfolioHelper, dashboardHelper } from 'components/onboarding'
import { rebalanceConf, sellConf } from 'components/button_confirms';
import { get_price_change } from 'components/price_changes';
import { addValues, listeners, allocationChart, prepareData } from 'components/allocation_chart';
import { drawChart } from 'components/portfolio_chart';

const portfolioPage = document.querySelector('.portfolios.show');
if (portfolioPage != null) {
  dashboardHelper();
  drawChart();
  prepareData();
  get_price_change();
  rebalanceConf();
  sellConf();
}

const allocationsNewPage = document.querySelector('.portfolios.new');
if (allocationsNewPage != null) {
  listeners();
  portfolioHelper();
  addValues();
  allocationChart();
  // loadIndex();
}

const allocationsEditPage = document.querySelector('.portfolios.edit');
if (allocationsEditPage != null) {
  addValues();
  listeners();
  allocationChart();
}

const signUpPage = document.querySelector('.registrations.new');
if (signUpPage != null) {
  apiHelper();
}



