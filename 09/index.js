module.exports = (data) => {
  const input = data.trim();

  let garbage = false;
  let level = 0;
  let sum = 0;
  let garbageCount = 0;

  for (let i = 0; i < input.length; i++) {
    let curr = input[i];
    
    if (curr === '!') {
      i++;
      continue;
    }

    if (garbage) {
      if (curr === '>')
        garbage = false;
      else
        garbageCount++;
      continue;
    }

    if (curr === '<') {
      garbage = true;
      continue;
    }  

    if (curr === '{') {
      level++;
      sum += level;
      continue;
    }

    if (curr === '}') {
      level--;
      continue;
    }

    if (curr !== ',') {
      throw 'WTF';
    }
  }

  return [sum, garbageCount];
}