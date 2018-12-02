module.exports = (array, fromIndex, toIndex) => {
  const temp = array[toIndex];
  array[toIndex] = array[fromIndex];
  array[fromIndex] = temp;
}