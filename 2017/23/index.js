const Program = require('../util/Program');
const isPrime = require('../util/isPrime');

module.exports = (data) => {
  const program = new Program(0, data);
  program.runToEnd();
  const part1solution = program.mulCount;

  const bMatch = /^set b (-?\d+)/.exec(data);
  let b = Number.parseInt(bMatch[1]);
  let c = 0;
  let h = 0;
    
  b = b * 100 + 100000;
  c = b + 17000;

  do {
    if (!isPrime(b)) {
      h++;
    }
    b += 17;
  } while (b <= c)

  return [ part1solution, h];
}