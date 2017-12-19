module.exports = (data) => {
  const numbers = data.trim();
  let nextSum = 0;
  let halfwaySum = 0;

  for (let i = 0; i < numbers.length; i++) {
    const curr = numbers[i];
    const next = numbers[(i+1) % numbers.length];
    const halfwayRound = numbers[(i + numbers.length/2) % numbers.length];

    if (curr === next)
      nextSum += Number.parseInt(curr);

    if (curr === halfwayRound)
      halfwaySum += Number.parseInt(curr);
  }
  return [nextSum, halfwaySum];
}