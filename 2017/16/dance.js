const swap = require('../util/swap');

module.exports = (programs, moves) => {
  for (let move of moves) {
    if (move.startsWith('s')) {
      const num = Number.parseInt(move.slice(1));
      programs = programs.slice(programs.length - num).concat(programs.slice(0, programs.length - num));
    } else if (move.startsWith('x')) {
      const exchange = move.slice(1).split('/');
      const from = Number.parseInt(exchange[0]);
      const to = Number.parseInt(exchange[1]);
      swap(programs, from, to);
    } else if (move.startsWith('p')) {
      const fromProgram = move.substr(1, 1);
      const toProgram = move.substr(3, 1);
      let from = programs.indexOf(fromProgram);
      let to = programs.indexOf(toProgram);
      swap(programs, from, to);
    }
  }
  
  return programs;
}