const splitLines = require('../util/splitLines');

module.exports = (data) => {
  let diffSum = 0;
  let divisibleSum = 0;

  splitLines(data).forEach(line => {
    const numbers = line.trim().split(/\s+/).map(item => Number.parseInt(item));
    diffSum += Math.max(...numbers) - Math.min(...numbers);

    for (let i = 0; i < numbers.length - 1; i++) {
      const a = numbers[i];
      let currDivisibleSum = 0;
      for (let j = i + 1; j < numbers.length; j++) {
        const b = numbers[j];
        if (a % b === 0) {
          currDivisibleSum = a / b;
          break;
        }
        if (b % a === 0) {
          currDivisibleSum = b / a;
          break;
        }
      }
      if (currDivisibleSum > 0) {
        divisibleSum += currDivisibleSum;
        break;
      }
    }
  });

  return [diffSum, divisibleSum];
}