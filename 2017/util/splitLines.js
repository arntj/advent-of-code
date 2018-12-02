module.exports = (data) => {
  return data.split('\n').map(line => line.trim()).filter(line => line);
}