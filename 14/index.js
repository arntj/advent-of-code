const knotHash = require('../10/knotHash');
const hexToBinary = require('./hexToBinary');

const fillRegion = (grid, x, y) => {
  if (!grid[y] || grid[y][x] !== '1')
    return;

  grid[y][x] = 'x';

  fillRegion(grid, x - 1, y);
  fillRegion(grid, x + 1, y);
  fillRegion(grid, x, y - 1);
  fillRegion(grid, x, y + 1);
}

module.exports = (data) => {
  const input = data.trim();
  const grid = [];
  for (let i = 0; i < 128; i++) {
    const currHash = knotHash(`${input}-${i}`);
    const binary = hexToBinary(currHash);
    const row = binary.split('');

    grid.push(row);
  }

  let usedCount = 0;
  let regionCount = 0;

  for (let x = 0; x < 128; x++) {
    for (let y = 0; y < 128; y++) {
      if (grid[y][x] === '1') {
        usedCount++;
        regionCount++;
        fillRegion(grid, x, y);
      } else if (grid[y][x] === 'x') {
        usedCount++;
      }
    }
  }

  return [usedCount, regionCount];
}