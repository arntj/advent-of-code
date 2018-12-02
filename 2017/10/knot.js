module.exports = (lengths, rounds) => {
  const len = 256;
  const generator = function*(len) {
    let i = 0;
  
    while (i < len)
      yield(i++);
  }
  
  const list = Array.from(generator(len));

  let i = 0;
  let skip = 0;

  for (let r = 0; r < rounds; r++) {
    for (let l of lengths) {
      let elements = list.slice(i, Math.min(list.length, i + l)).concat(list.slice(0, Math.max(0, i + l - list.length)));
      for (let j = 0; j < l; j ++) {
        list[(i + j) % list.length] = elements[elements.length - j - 1];
      }
      i = (i + l + skip) % list.length;
      skip++;
    }
  }

  return list;
}