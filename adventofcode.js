const fs = require('fs');

const day = Number.parseInt(process.argv[2]);

if (!Number.isInteger(day) || day < 1 || day > 25) {
  console.log('Please give a number between 1 and 25 as the first command line argument.');
  process.exit();
}

const filePath = process.argv[3];

if (!filePath) {
  console.log('Please give input file name as the second command line argument.');
  process.exit();
}

if (!fs.existsSync(filePath)) {
  console.log(`File '${filePath}' not found.`);
  process.exit();
}

const path = (day < 10) ? `./0${day}` : `./${day}`;
const func = require(`${path}`);
const data = fs.readFileSync(filePath, 'utf8');

const result = func(data);
console.log(`Part 1 result: ${result[0]}`);
console.log(`Part 2 result: ${result[1]}`);