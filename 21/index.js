const splitLines = require('../util/splitLines');
const Cell = require('./Cell');

module.exports = (data) => {
  const rules = splitLines(data).map(line => {
    const regex = /^([\.\/#]+) => ([\.\/#]+)$/
    const match = regex.exec(line);

    return [match[1], match[2]];
  });

  let curr = new Cell('.#./..#/###');
  let part1solution;

  for (let i = 0; i < 18; i++) {
    const cells = curr.splitCells();
    const cellsTransformed = cells.map(row => row.map(c => c.transform(rules)));
    curr = new Cell(cellsTransformed);

    if (i === 4) {
      part1solution = curr.onCount();
    }
  }

  const part2solution = curr.onCount();

  return [part1solution, part2solution];
}