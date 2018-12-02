module.exports = (data) => {
  const result = data.map(n => {
    const parent = data.find(nn => nn.children.includes(n.name));
    const parentName = parent ? parent.name : null;

    return {
      name: n.name,
      weight: n.weight,
      parent: parentName,
      children: n.children,
    };
  });

  result.forEach(r => {
    if (r.parent) r.parent = result.find(rr => rr.name === r.parent);
    r.children = r.children.map(c => result.find(rr => rr.name === c));
  });

  return result;
}