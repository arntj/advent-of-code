const splitLines = require('../util/splitLines');

// this function calculates whether we would get caught at this depth and range.
const caught = (depth, range, delay) => {
  // we accomodate for the fact that scanners move back and forth, by pretending they move
  // in one direction only in a space that has the size of 2 * range - 2.
  const pos = (depth + delay) % (2 * range - 2);

  return pos === 0;
}

module.exports = (data) => {
  const firewall = [];

  splitLines(data).forEach(d => {
    const match = /^(\d+): (\d+)$/.exec(d.trim());
    const depth = Number.parseInt(match[1]);
    const range = Number.parseInt(match[2]);

    firewall[depth] = range;
  });

  let sum = 0;
  let delay = -1;
  let wasCaught;
  
  do {
    delay++;
    wasCaught = false;

    for (let depth = 0; depth < firewall.length; depth++) {
      const range = firewall[depth];

      if (typeof range === 'undefined')
        continue;
      
      if (caught(depth, range, delay)) {
        wasCaught = true;
        if (delay === 0)
          sum += depth * range;
      }
    }
  } while (wasCaught)

  return [sum, delay];
};