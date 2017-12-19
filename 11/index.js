const calculateDist = (coord) => {
  if (Math.sign(coord.x) === Math.sign(coord.y))
    return Math.abs(coord.x + coord.y);
  else
    return Math.max(Math.abs(coord.x), Math.abs(coord.y));
}

module.exports = (data) => {
  const path = data.trim().split(',');

  const dirs = path.map(p => {
    switch (p) {
      case 'n':
        return {
          x: -1,
          y: 1,
        };
      case 'ne':
        return {
          x: 0,
          y: 1,
        };
      case 'se':
        return {
          x: 1,
          y: 0,
        };
      case 's':
        return {
          x: 1,
          y: -1,
        };
      case 'sw':
        return {
          x: 0,
          y: -1,
        };
      case 'nw':
        return {
          x: -1,
          y: 0,
        };
      default:
        throw `Unknown direction '${p}'`
    }
  });

  let maxDist = 0;

  const dir = dirs.reduce((prev, curr) => {
    const next = {
      x: prev.x + curr.x,
      y: prev.y + curr.y,
    };
    const nextDist = calculateDist(next);

    if (nextDist > maxDist)
      maxDist = nextDist;

    return next;
  }, { x: 0, y: 0});

  return [calculateDist(dir), maxDist];
}