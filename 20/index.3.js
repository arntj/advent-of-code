const splitLines = require('../util/splitLines');

const solveQuadratic = (a, b, c) => {
  if (b*b < 4*a*c) {
    return [];
  }

  if (b*b === 4*a*c) {
    return [ -b / (2 * a) ];
  }

  const root = Math.sqrt(b*b - 4*a*c);

  const sol1 = (-b + root)/(2*a);
  const sol2 = (-b - root)/(2*a);

  return [ sol1, sol2 ];
}

const get1DPositionAtTime = (p, v, a, t) => {
  return p + v*t + a*t*t/2;
}

const getPositionAtTime = (particle, time) => {
  return {
    x: get1DPositionAtTime(particle.p.x, particle.v.x, particle.a.x, time),
    y: get1DPositionAtTime(particle.p.y, particle.v.y, particle.a.y, time),
    z: get1DPositionAtTime(particle.p.z, particle.v.z, particle.a.z, time),
  }
}

const findCollision = (part1, part2) => {
  const a = (part1.a.x + part1.a.y + part1.a.z - part2.a.x - part2.a.y - part2.a.z)/2;
  const b = (part1.v.x + part1.v.y + part1.v.z - part2.v.x - part2.v.y - part2.v.z);
  const c = (part1.p.x + part1.p.y + part1.p.z - part2.p.x - part2.p.y - part2.p.z);

  const potentialCollisions = solveQuadratic(a, b, c).filter(c => c > 0).sort();

  if (potentialCollisions.length === 0) {
    return null;
  }

  for (let c of potentialCollisions) {
    if (!Number.isFinite(c))
      continue;

    const rounded = Math.round(c);
    const pos1 = getPositionAtTime(part1, rounded);
    const pos2 = getPositionAtTime(part2, rounded);

    if (rounded === c) {
      console.log(part1, part2)
      console.log (rounded, pos1, pos2)
    }

    if (pos1.x === pos2.x && pos1.y === pos2.y && pos1.z === pos2.z) {
      return rounded;
    }
  };

  return null;
}

module.exports = (data) => {
  const limit = 1000;

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

  let closestDistance = -1;
  let closestDistanceIndexs = [];

  particles.forEach((v, i) => {
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

  const collisions = [];

  for (let i = 0; i < particles.length; i++) {
    for (let j = i + 1; j < particles.length; j++) {
      const p1 = particles[i];
      const p2 = particles[j];

      const t = findCollision(p1, p2);

      if (t) {
        collisions.push({ t, p1, p2 });
      }
    }
  }

  collisions.sort((c1, c2) => {
    return c1.t - c2.t;
  });

  console.log(collisions);

  return [0, 0];
}