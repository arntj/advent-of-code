module.exports = (data) => {
  const steps = Number.parseInt(data.trim());
  const limit1 = 2018;
  const limit2 = 50000000;

  let buffer = [ 0 ];
  let pos = 0;

  for (let i = buffer.length; i < limit1; i++) {
    pos = ((pos + steps) % buffer.length) + 1;
    buffer.splice(pos, 0, i);
  }

  const part1solution = buffer[(pos + 1) % buffer.length];

  let len = buffer.length;
  let zeroPos = buffer.indexOf(0);
  let afterZero = buffer[(zeroPos + 1) % buffer.length];

  while (len < limit2) {
    pos = ((pos + steps) % len) + 1;

    if (pos <= zeroPos) {
      zeroPos = (zeroPos + 1) % len;
    }
    else if (pos === zeroPos + 1) {
      afterZero = len;
    }
    len++;
  }

  const part2solution = afterZero;

  return [part1solution, part2solution];
}