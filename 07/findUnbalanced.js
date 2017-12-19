const findWeight = (n) => {
  return n.weight + n.children.reduce((sum, curr) => sum + findWeight(curr), 0);
};

const childrenAreBalanced = (children) => {
  if (children.length <= 1)
    return true;

  const weights = children.map(findWeight);

  return !weights.some((w, i, a) => w !== a[0]);
}

module.exports = (root) => {
  let curr = root;

  while (!childrenAreBalanced(curr.children)) {
    if (curr.children.length === 2) {
      return curr.children.find(c => !childrenAreBalanced(c.children)) || curr.children[0];
    }
    const weights = curr.children.map(findWeight);

    curr = curr.children.find((c, i, a) => {
      const nextWeight = weights[(i + 1) % a.length];
      const overnextWeight = weights[(i + 2) % a.length];
      return weights[i] !== nextWeight && weights[i] !== overnextWeight;
    });
  }

  const currWeight = findWeight(curr);
  const siblingWeight = findWeight(curr.parent.children.filter(c => c !== curr)[0]);
  const diff = currWeight - siblingWeight;

  return curr.weight - diff;
}