module.exports = (list) => {
  const sums = [];
  
  for (let block = 0; block < 16; block++) {
    let sum = list[block * 16];
  
    for (let offset = 1; offset < 16; offset++) {
      sum = sum ^ list[block * 16 + offset];
    }
  
    sums.push(sum);
  }
  
  const hash = sums.map(s => (s < 16 ? '0' : '') + s.toString(16)).join('');

  return hash;
}