const parseData = require('./parseData');
const buildTree = require('./buildTree');
const findRoot = require('./findRoot');
const findUnbalanced = require('./findUnbalanced');

module.exports = (data) => {
  const tree = buildTree(parseData(data));
  const root = findRoot(tree);
  const unbalancedResult = findUnbalanced(root);

  return [ root.name, unbalancedResult];
}