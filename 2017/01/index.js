module.exports = (data) => {
  let sumNext = 0;
  let sumHalfway = 0

  for (i = 0; i < data.length; i++) {
    if (data[i] == data[(i + 1) % data.length]) {
      sumNext += Number.parseInt(data[i]);
    }
    if (data[i] == data[(i + data.length / 2) % data.length]) {
      sumHalfway += Number.parseInt(data[i]);
    }
  }

  return [sumNext, sumHalfway];
}