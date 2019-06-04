import "bootstrap";


import { loadChart } from 'components/portfolio_chart';

const portfolioPage = document.querySelector('.portfolios.show');
if (portfolioPage != null) {
  loadChart();
}
