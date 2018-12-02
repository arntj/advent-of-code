const isLetter = (char) => {
  return char >= 'A' && char <= 'Z';
}

module.exports = (data) => {
  const rows = data.split('\n');
  const startX = rows[0].indexOf('|');
  const letters = [];

  let x = startX;
  let y = 0;

  let xDir = 0;
  let yDir = 1;
  let count = 1;

  while(true) {
    x += xDir;
    y += yDir;
    curr = rows[y] ? rows[y][x] : null;

    if (isLetter(curr)) {
      letters.push(curr);
    } else if (curr === '+') {
      if (yDir !== 0) {
        yDir = 0;

        if (rows[y][x-1] === '-' || isLetter(rows[y][x-1]))
          xDir = -1;
        else
          xDir = 1;
      } else {
        xDir = 0;

        if (rows[y-1] && (rows[y-1][x] === '|' || isLetter(rows[y-1][x])))
          yDir = -1;
        else
          yDir = 1;
      }
    } else if (curr === ' ' || curr === null) {
      break;
    }
    count++;
  }

  return [letters.join(''), count];
}