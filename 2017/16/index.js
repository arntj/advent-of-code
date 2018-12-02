const dance = require('./dance');
const seenBefore = require('../util/seenBefore');

module.exports = (data) => {
  let programs = [];

  for (let i = 0; i < 16; i++)
    programs.push(String.fromCharCode('a'.charCodeAt(0) + i));

  const moves = data.trim().split(',');

  // part 1 is simple, just do the dance once.
  const part1result = dance([...programs], moves);

  let states = [];
  let currState = [...programs];

  // dance until we arrive at a permutation we've seen before.
  while (!seenBefore(states, currState)) {
    states.push([...currState]);
    currState = dance(currState, moves);
  }

  // find index of the first time this permutation occurred
  const firstIndex = states.findIndex(s => 
    s.length === currState.length 
    && s.every((v, i) => v === currState[i])
  );

  // calculate the cycle length
  const cycleLength = states.length - firstIndex;

  // calculate how many more times we have to do the dance to get at the final result.
  const remainingCycles = (1000000000 - firstIndex) % cycleLength;

  // dance baby dance
  for (let i = 0; i < remainingCycles; i++) {
    currState = dance(currState, moves);
  }

  const part2result = currState;

  return [part1result.join(''), part2result.join('')];
}