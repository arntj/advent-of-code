const splitLines = require('../util/splitLines');
const bridgeHelpers = require('./bridgeHelpers');

module.exports = (data) => {
  const components = splitLines(data).map(line => {
    const numbers = line.split('/');
    return [ Number.parseInt(numbers[0]), Number.parseInt(numbers[1]) ];
  });

  const part1solution = bridgeHelpers.highestBridgeSum(components);

  const longestBridges = bridgeHelpers.longestBridges(components);
  const strongestBridge = bridgeHelpers.strongestBridge(longestBridges);
  const part2solution = bridgeHelpers.bridgeStrength(strongestBridge);

  return [ part1solution, part2solution ];
}