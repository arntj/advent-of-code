const Register = require('../util/Register');
const splitLines = require('../util/splitLines');

module.exports = (data) => {
  const lines = splitLines(data);

  const register = new Register();

  let maxValue = 0;

  lines.forEach(line => {
    const match = /^([a-z]+) ([a-z]+) (-?\d+) if ([a-z]+) ([=<>!]+) (-?\d+)$/.exec(line);
    const staReg = match[1];
    const staOp = match[2];
    const staVal = Number.parseInt(match[3]);

    const condReg = match[4];
    const condOp = match[5];
    const condVal = Number.parseInt(match[6]);

    const condRegVal = register.get(condReg);
    let executeInstruction = false;

    switch (condOp) {
      case '>':
        executeInstruction = condRegVal > condVal;
        break;
      case '<':
        executeInstruction = condRegVal < condVal;
        break;
      case '>=':
        executeInstruction = condRegVal >= condVal;
        break;
      case '<=':
        executeInstruction = condRegVal <= condVal;
        break;
      case '==':
        executeInstruction = condRegVal === condVal;
        break;
      case '!=':
        executeInstruction = condRegVal !== condVal;
    }
    
    if (executeInstruction) {
      let incByValue = staVal;

      if (staOp === 'dec')
        incByValue = -incByValue;

      const newValue = register.add(staReg, incByValue);

      if (newValue > maxValue)
        maxValue = newValue;
    }
  });
    
  const finalMax = Math.max(...register.values);

  return [finalMax, maxValue];
}