module.exports = (data) => {
  const aStart = Number.parseInt(/Generator A starts with (\d+)/.exec(data)[1]);
  const bStart = Number.parseInt(/Generator B starts with (\d+)/.exec(data)[1]);

  const aFactor = 16807;
  const bFactor = 48271;

  const div = 2147483647;
  const mask = Math.pow(2, 16) - 1;

  let a = aStart;
  let b = bStart;
  let sameCount = 0;

  for (let i = 0; i < 40000000; i++) {
    a = (a * aFactor) % div;
    b = (b * bFactor) % div;

    if (!((a ^ b) & mask))
      sameCount++;
  }

  a = aStart;
  b = bStart;
  let pickySameCount = 0;

  for (let i = 0; i < 5000000; i++) {
    do {
      a = (a * aFactor) % div;
    } while (a & 3)

    do {
      b = (b * bFactor) % div;
    } while (b & 7)

    if (!((a ^ b) & mask))
      pickySameCount++;
  }

  return [sameCount, pickySameCount];
}