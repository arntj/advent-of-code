module.exports = (data) => {
  const limit = Number.parseInt(data.trim());

  let sums = [];
  const setSum = (x, y, val) => {
    if (typeof sums[x] === 'undefined') {
      sums[x] = [];
    }
    sums[x][y] = val;
  }
  const newSum = (x, y) => {
    let sum = 0;
    for (let xx = x - 1; xx <= x + 1; xx++)
      for (let yy = y - 1; yy <= y + 1; yy++)
        if (sums[xx])
          sum += (sums[xx][yy] || 0);
    setSum(x, y, sum);
  }

  let x = 0;
  let y = 0;
  setSum(x, y, 1);

  let firstLargerSum = 0;

  for(let i = 1; i < limit;) {
    const dirX = x > 0 ? (y > 0 ? -1 :  0) : (y >  0 ?  0 :  1);
    const dirY = x > 0 ? (y > 0 ?  0 :  1) : (y >  0 ? -1 :  0);
    const finalX = x + dirX * 2 * Math.abs(x) + (dirX > 0 ? 1 : 0);
    const finalY = y + dirY * 2 * Math.abs(y) + (dirY > 0 ? 1 : 0);
  
    while ((x !== finalX || y !== finalY) && i < limit) {
      x += dirX;
      y += dirY;
      i++;
      newSum(x, y);
      
      if (firstLargerSum === 0 && sums[x][y] > limit)
        firstLargerSum = sums[x][y];
    }
  }

  const manhattanDistance = Math.abs(x) + Math.abs(y);

  return [manhattanDistance, firstLargerSum];
}