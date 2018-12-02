const splitLines = require('../util/splitLines');

module.exports = (data) => {
  const offsets = splitLines(data).map(line => Number.parseInt(line));

  let i = 0;
  const part1offsets = [...offsets];
  let part1count = 0;
  while (i >= 0 && i < offsets.length) {
    const jump = part1offsets[i];
    part1offsets[i]++;

    i += jump;
    part1count++;
  }

  i = 0;
  const part2offsets = [...offsets];
  let part2count = 0;
  while (i >= 0 && i < offsets.length) {
    const jump = part2offsets[i];

    if (jump >= 3)
      part2offsets[i]--;
    else
      part2offsets[i]++;

    i += jump;
    part2count++;
  }

  return [part1count, part2count];
}