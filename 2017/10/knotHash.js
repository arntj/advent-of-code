const knot = require('./knot');
const hash = require('./hash');

module.exports = (data) => {
  const lengthsData = data.split('').map(c => c.charCodeAt(0));
  const lengths = lengthsData.concat([ 17, 31, 73, 47, 23 ]);
  const knotResult = knot(lengths, 64);
  const hashResult = hash(knotResult);

  return hashResult;
}