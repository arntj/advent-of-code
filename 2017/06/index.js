const seenBefore = require('../util/seenBefore');

module.exports = (data) => {
  const initial = data.trim().split(/\s+/).map(n => Number.parseInt(n));

  const states = [];

  let currState = [...initial];
  let part1result = 0;
  
  while (!seenBefore(states, currState)) {
    part1result++;
    states.push([...currState]);

    let i = currState.indexOf(Math.max(...currState));
    let v = currState[i];
    currState[i] = 0;

    while (v > 0) {
      i = (i + 1) % currState.length;
      currState[i]++;
      v--;
    }
  }

  const repeatedState = [...currState];
  let part2result = 0;
  do {
    part2result++;

    let i = currState.indexOf(Math.max(...currState));
    let v = currState[i];
    currState[i] = 0;

    while (v > 0) {
      i = (i + 1) % currState.length;
      currState[i]++;
      v--;
    }
  } while (!seenBefore([ repeatedState ], currState))

  return [part1result, part2result];
}