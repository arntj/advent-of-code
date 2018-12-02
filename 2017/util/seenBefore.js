module.exports = (allStates, state) => {
  return allStates.some(s => s.length === state.length && s.every((v, i) => v === state[i]));
}