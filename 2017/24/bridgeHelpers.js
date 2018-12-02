const bridgeHelpers = {
  bridgeStrength: (bridge) => {
    return bridge.reduce((prev, curr) => prev + curr[0] + curr[1], 0);
  },
  highestBridgeSum: (availableComponents, port = 0, sum = 0) => {
    let highestSum = sum;

    for (let comp of availableComponents) {
      if (!(comp[0] === port || comp[1] === port)) {
        continue;
      }

      const nextAvailableComponents = availableComponents.filter(c => c !== comp);
      const nextPort = (comp[0] === port) ? comp[1] : comp[0];
      const nextSum = sum + comp[0] + comp[1];

      const currSum = bridgeHelpers.highestBridgeSum(nextAvailableComponents, nextPort, nextSum);

      if (currSum > highestSum) {
        highestSum = currSum;
      }
    }

    return highestSum;
  },
  longestBridges: (availableComponents, bridge = [], port = 0) => {
    let maxLength = bridge.length;
    let bridges = [ bridge ];

    for (let comp of availableComponents) {
      if (!(comp[0] === port || comp[1] === port)) {
        continue;
      }

      const nextAvailableComponents = availableComponents.filter(c => c !== comp);
      const nextBridge = bridge.concat([comp]);
      const nextPort = (comp[0] === port) ? comp[1] : comp[0];

      const nextBridges = bridgeHelpers.longestBridges(nextAvailableComponents, nextBridge, nextPort);

      if (nextBridges[0].length >= maxLength) {
        maxLength = nextBridges[0].length;
        bridges = bridges.concat(nextBridges);
      }
    }

    const longestBridges = bridges.filter(b => b.length === maxLength);

    return longestBridges;
  },
  strongestBridge: (bridges) => {
    const highestStrength = Math.max(...bridges.map(b => bridgeHelpers.bridgeStrength(b)));

    return bridges.find(b => bridgeHelpers.bridgeStrength(b) === highestStrength);
  }
};

module.exports = bridgeHelpers;