const splitLines = require('../util/splitLines');

module.exports = (data) => {
  return splitLines(data).map(l => {
    const match = /^([a-z]+) \((\d+)\)/.exec(l);
    const name = match[1];
    const weight = Number.parseInt(match[2]);
    
    let children = [];
    const matchChildren = /-> ([a-z,\s]+)$/.exec(l);
    if (matchChildren) {
      children = matchChildren[1].split(',').map(k => k.trim());
    }

    return { name, weight, children };
  });
}