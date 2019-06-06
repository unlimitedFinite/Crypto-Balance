import "bootstrap";


import { allocationChart, updateChart } from 'components/allocation_chart';
import { loadChart } from 'components/portfolio_chart';

const portfolioPage = document.querySelector('.portfolios.show');
if (portfolioPage != null) {
  loadChart();
}
const allocationsPage = document.querySelector('.allocations.new');
if (allocationsPage != null) {
  allocationChart();
  updateChart();
}

