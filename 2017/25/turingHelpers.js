const splitLines = require('../util/splitLines');

const buildRulebook = (data) => {
  const valueRules = {};
  const stepRules = {};
  const stateRules = {};

  const lines = splitLines(data);
  let i = 0;

  while (i < lines.length) {
    const stateRegex = /In state (.)/;
    let match = null;

    while (!match) {
      match = stateRegex.exec(lines[i]);
      i++;
    }

    const currState = match[1];

    const valueRegex = /Write the value (\d)\./;
    const stepRegex = /Move one slot to the ([a-z]+)\./;
    const nextStateRegex = /Continue with state ([A-Z])\./;

    for (let j = 0; j <= 1; j++) {
      i++;

      match = valueRegex.exec(lines[i]);
      const value = Number.parseInt(match[1]);
      if (!valueRules[currState])
        valueRules[currState] = {};
      valueRules[currState][j] = value;
      i++;

      match = stepRegex.exec(lines[i]);
      const step = match[1] === 'right' ? 1 : -1;
      if (!stepRules[currState])
        stepRules[currState] = {};
      stepRules[currState][j] = step;
      i++;

      match = nextStateRegex.exec(lines[i]);
      const nextState = match[1];
      if (!stateRules[currState])
        stateRules[currState] = {};
      stateRules[currState][j] = nextState;
      i++;      
    }
  }
  const ruleBook = {
    nextValue: (state, value) => valueRules[state][value],
    nextStep: (state, value) => stepRules[state][value],
    nextState: (state, value) => stateRules[state][value],
  }

  return ruleBook;
}

module.exports = { buildRulebook };