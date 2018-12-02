const knot = require('./knot');
const knotHash = require('./knotHash');

module.exports = (data) => {
  const part1lengths = data.trim().split(',').map(n => Number.parseInt(n.trim()));
  const part1knot = knot(part1lengths, 1);
  const part1result = part1knot[0] * part1knot[1];

  const part2result = knotHash(data.trim());

  return [part1result, part2result];
}