module.exports = (hex) => {
  return hex.split('').map(h => {
    let result = Number.parseInt(h, 16).toString(2);
    while (result.length < 4)
      result = `0${result}`;

    return result;
  }).join('');
}