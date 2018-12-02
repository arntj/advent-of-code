const splitLines = require('../util/splitLines');

module.exports = (data) => {
  let validRepeated = 0;
  let validAnagram = 0;

  splitLines(data).map(line => line.split(' ')).forEach(words => {
    const foundRepeated = words.some((w, i, a) => a.indexOf(w) !== i);

    if (!foundRepeated)
      validRepeated++;

    const anagrams = [];
    let foundAnagram = words.some(w => {
      const sorted = w.split('').sort().join('');

      if (anagrams.some(a => a === sorted))
        return true;

      anagrams.push(sorted);
      return false;
    });

    if (!foundAnagram)
      validAnagram++;
  });

  return [validRepeated, validAnagram];
}