const splitLines = require('../util/splitLines');

module.exports = (data) => {
  const limit = 10000;

  const lines = splitLines(data);
  const lineRegex = /p=<(-?\d+),(-?\d+),(-?\d+)>, v=<(-?\d+),(-?\d+),(-?\d+)>, a=<(-?\d+),(-?\d+),(-?\d+)>/;

  const particles = lines.map(l => {
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

  const currParticles = [...particles];
  const collisions = currParticles.map(() => false);

  for (let t = 0; t < limit; t++) {
    for (let i = 0; i < currParticles.length; i++) {
      const part = currParticles[i];

      part.v.x += part.a.x;
      part.v.y += part.a.y;
      part.v.z += part.a.z;
      part.p.x += part.v.x;
      part.p.y += part.v.y;
      part.p.z += part.v.z;
    }

    for (let i = 0; i < currParticles.length; i++) {
      if (collisions[i]) {
        continue;
      }

      for (let j = i + 1; j < currParticles.length; j++) {
        if (collisions[j]) {
          continue;
        }

        const iPart = currParticles[i];
        const jPart = currParticles[j];

        if (iPart.p.x === jPart.p.x && iPart.p.y === jPart.p.y && iPart.p.z === jPart.p.z) {
          collisions[i] = true;
          collisions[j] = true;
        }
      }
    }
  }

  let closestDistance = -1;
  let closestParticle = 0;

  for (let i = 0; i < currParticles.length; i++) {
    const part = currParticles[i];
    const dist = Math.abs(part.p.x) + Math.abs(part.p.y) + Math.abs(part.p.z);

    if (dist < closestDistance || closestDistance === -1) {
      closestDistance = dist;
      closestParticle = i;
    }
  }

  const notCollided = collisions.filter(c => !c).length;

  return [closestParticle, notCollided];
}