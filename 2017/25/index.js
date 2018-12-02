const turingHelpers = require('./turingHelpers');

const print = (tape, cursor, state) => {
  let stateName = null;

  for (let s in turingHelpers.states) {
    if (turingHelpers.states[s] === state) {
      stateName = s;
      break;
    }
  }

  let output = `state ${stateName}: `;

  for (let j = -3; j <= 3; j++) {
    const currValue = tape[j] === 1 ? 1 : 0;
    const isCursor = j === cursor;

    if (isCursor)
      output += `[${currValue}]`;
    else 
      output += ` ${currValue} `;
  }
  console.log(output);
}

module.exports = (data) => {
  const stateMatch = /Begin in state (.)\./.exec(data);
  const beginInState = stateMatch[1];

  const stepsMatch = /Perform a diagnostic checksum after (\d+) steps\./.exec(data);
  const stepsBeforeChecksum = Number.parseInt(stepsMatch[1]);

  const rulebook = turingHelpers.buildRulebook(data);

  const tape = [];
  let state = beginInState;
  let cursor = 0;
  let checksum = 0;

  for (let i = 0; i < stepsBeforeChecksum; i++) {
    const value = tape[cursor] === 1 ? 1 : 0;
    const nextValue = rulebook.nextValue(state, value);

    if (value === 0 && nextValue === 1)
      checksum++;
    else if (value === 1 && nextValue === 0)
      checksum--;

    tape[cursor] = nextValue;

    cursor += rulebook.nextStep(state, value);
    state = rulebook.nextState(state, value);
  }

  const part1solution = checksum;

  return [part1solution, 0];
}