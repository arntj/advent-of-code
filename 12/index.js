const splitLines = require('../util/splitLines');

module.exports = (data) => {
  const lines = splitLines(data);
  let sets = [];

  lines.forEach(l => {
    const match = /^(\d+) <-> (.+)$/.exec(l);

    const ids = match[2].split(',').map(id => Number.parseInt(id.trim())).concat(Number.parseInt(match[1]));

    const matchingSets = sets.filter(s => ids.some(id => s.has(id)));

    if (matchingSets.length === 0) {
      sets.push(new Set(ids));
      return;
    }

    ids.forEach(id => matchingSets[0].add(id));

    matchingSets.slice(1).forEach(s => {
      s.forEach(v => matchingSets[0].add(v));
      sets.splice(sets.indexOf(s), 1);
    });
  });

  const part1result = sets.find(s => s.has(0)).size;
  const part2result = sets.length;

  return [part1result, part2result];
}