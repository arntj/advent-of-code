const splitLines = require('../util/splitLines');

module.exports = (data) => {
  const limit = 1000;

  const lines = splitLines(data);
  const lineRegex = /p=<(-?\d+),(-?\d+),(-?\d+)>, v=<(-?\d+),(-?\d+),(-?\d+)>, a=<(-?\d+),(-?\d+),(-?\d+)>/;

  const vectors = lines.map(l => {
    const match = lineRegex.exec(l);

    const p = {
      x: Number.parseInt(match[1]),
      y: Number.parseInt(match[2]),
      z: Number.parseInt(match[3]),
    };

    const v = {
      x: Number.parseInt(match[4]),
      y: Number.parseInt(match[5]),
      z: Number.parseInt(match[6]),
    };

    const a = {
      x: Number.parseInt(match[7]),
      y: Number.parseInt(match[8]),
      z: Number.parseInt(match[9]),
    };

    return { p, v, a };
  });

  let closestDistance = -1;
  let closestDistanceIndexs = [];

  vectors.forEach((v, i) => {
    const finalPos = {
      x: v.p.x + v.v.x * limit + v.a.x * limit * limit / 2,
      y: v.p.y + v.v.y * limit + v.a.y * limit * limit / 2,
      z: v.p.z + v.v.z * limit + v.a.z * limit * limit / 2,
    };

    const dist = Math.abs(finalPos.x) + Math.abs(finalPos.y) + Math.abs(finalPos.z);

    if (dist < closestDistance || closestDistance === -1) {
      closestDistance = dist;
      closestDistanceIndexs = [ i ];
    } else if (dist === closestDistance) {
      closestDistanceIndexs.push(i);
    }
  });

  return [closestDistanceIndexs[0], 0];
}