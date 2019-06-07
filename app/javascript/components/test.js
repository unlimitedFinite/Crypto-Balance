var hash = {
  Bitcoin: '10',
  Tron: '20',
  Ethereum: '30'
}

var array = [];

for (let [key, value] of Object.entries(hash)) {
  array.push([key, value]);
};

console.log(array);
