const Register = require('../util/Register');
const Program = require('./Program');

module.exports = (data) => {
  const program = new Program(0, data);

  while (!program.terminated) {
    program.next();
  }
  
  const lastFrequency = program.queue.pop();

  const program0 = new Program(0, data);
  const program1 = new Program(1, data);
  program0.friend = program1;
  program1.friend = program0;

  while (!(program0.terminated && program1.terminated)) {
    program0.next();
    program1.next();
  }

  return [lastFrequency, program1.sendCount];
}