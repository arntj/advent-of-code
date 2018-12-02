module.exports = (tree) => {
  let curr = tree[0];

  while (curr.parent) curr = curr.parent;

  return curr;
}