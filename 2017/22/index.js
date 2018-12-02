const splitLines = require('../util/splitLines');

let grid = [];

const states = {
  CLEAN: 0,
  WEAKENED: 1,
  INFECTED: 2,
  FLAGGED: 3,
}

const setValue = (x, y, value) => {
  if (!grid[y]) {
    grid[y] = [];
  }

  grid[y][x] = value;
}

const getValue = (x, y) => {
  if (!grid[y]) {
    return states.CLEAN;
  }
  return grid[y][x] || states.CLEAN;
}

const loadData = (data) => {
  grid = [];

  const lines = splitLines(data);
  
  for (let y = 0; y < lines.length; y++) {
    for (let x = 0; x < lines[y].length; x++) {
      const value = (lines[y][x] === '#') ? states.INFECTED : states.CLEAN;
      setValue(x, y, value);
    }
  }
}

module.exports = (data) => {
  loadData(data);

  let x = Math.floor(grid[0].length / 2);
  let y = Math.floor(grid.length / 2);
  let xDir = 0;
  let yDir = -1;
  let part1solution = 0;

  for (let i = 0; i < 10000; i++) {
    const infected = getValue(x, y) === states.INFECTED;
    const temp = xDir;

    if (infected) {
      xDir = -yDir;
      yDir = temp;
    } else {
      xDir = yDir;
      yDir = -temp;
    }

    setValue(x, y, infected ? states.CLEAN : states.INFECTED);

    x += xDir;
    y += yDir;

    part1solution += (!infected ? 1 : 0);
  }

  loadData(data);

  x = Math.floor(grid[0].length / 2);
  y = Math.floor(grid.length / 2);
  xDir = 0;
  yDir = -1;
  let part2solution = 0;

  for (let i = 0; i < 10000000; i++) {
    const currState = getValue(x, y);

    if (currState === states.CLEAN) {
      const temp = xDir;
      xDir = yDir;
      yDir = -temp;
    } else if (currState === states.INFECTED) {
      const temp = xDir;
      xDir = -yDir;
      yDir = temp;
    } else if (currState === states.FLAGGED) {
      xDir = -xDir;
      yDir = -yDir;
    }

    const nextValue =
      currState === states.CLEAN && states.WEAKENED
        || (currState === states.WEAKENED && states.INFECTED)
        || (currState === states.INFECTED && states.FLAGGED)
        || (currState === states.FLAGGED && states.CLEAN);

    setValue(x, y, nextValue);

    x += xDir;
    y += yDir;

    if (nextValue === states.INFECTED) {
      part2solution++;
    }
  }

  return [part1solution, part2solution];
}