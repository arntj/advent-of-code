const test = require('tape');
const Cell = require('../Cell');

const compareRaw = (a, b) => {
  return a.every((v, i) => v === b[i]);
}

test('init Cell from string', t => {
  const string = '#./..';
  const cell = new Cell(string);
  const expected = [ [true, false], [false, false] ];  
  const actual = cell.rawData();
  t.deepEqual(actual, expected);
  t.end();
});

test('toString', t => {
  const string = '#./..';
  const cell = new Cell(string);
  const expected = '#./..';
  const actual = cell.toString();
  t.equal(actual, expected);
  t.end();
});

test('toStringPretty', t => {
  const string = '#../.#./..#';
  const cell = new Cell(string);
  const expected =
    '#  .  .\n' +
    '.  #  .\n' +
    '.  .  #';
  const actual = cell.toStringPretty();
  t.equal(actual, expected);
  t.end();
});

test('init Cell from array of array of Cells', t => {
  const cells = [
    [ new Cell('#./..'), new Cell('.#/..') ],
    [ new Cell('../#.'), new Cell('../.#') ],
  ];
  const cell = new Cell(cells);
  const expected = '#..#/..../..../#..#';
  const actual = cell.toString();
  t.equal(actual, expected);
  t.end();
});

test('init Cell from array of array of boolean', t => {
  const cells = [
    [ true,  false, false, true ],
    [ false, false, false, false ],
    [ false, false, false, false ],
    [ true,  false, false, true ],
  ];
  const cell = new Cell(cells);
  const expected = '#..#/..../..../#..#';
  const actual = cell.toString();
  t.equal(actual, expected);
  t.end();
});

test('split in 2x2 cells', t => {
  const cell = new Cell('#..#/..../..../#..#');
  const expected = [
    [ '#./..', '.#/..' ],
    [ '../#.', '../.#' ],
  ];
  const actual = cell.splitCells().map(line => line.map(c => c.toString()));
  t.deepEqual(actual, expected);
  t.end();
});

test('split in 3x3 cells', t => {
  const cell = new Cell(
    '#...#...#/' +
    '........./' +
    '........./' +
    '........./' +
    '#...#...#/' +
    '........./' +
    '........./' +
    '........./' +
    '#...#...#'
  );
  const expected = [
    [ '#../.../...', '.#./.../...', '..#/.../...' ],
    [ '.../#../...', '.../.#./...', '.../..#/...' ],
    [ '.../.../#..', '.../.../.#.', '.../.../..#' ],
  ];
  const actual = cell.splitCells().map(line => line.map(c => c.toString()));
  t.deepEqual(actual, expected);
  t.end();
});

test('rotateRight', t => {
  const cell = new Cell(
    '###/' +
    '.../' +
    '#..'
  );
  const expected =
    '#.#/' +
    '..#/' +
    '..#';
  const actual = cell.rotateRight().toString();
  t.deepEqual(actual, expected);
  t.end();
});

test('rotateLeft', t => {
  const cell = new Cell(
    '###/' +
    '.../' +
    '#..'
  );
  const expected =
    '#../' +
    '#../' +
    '#.#';
  const actual = cell.rotateLeft().toString();
  t.deepEqual(actual, expected);
  t.end();
});

test('flipHorizontal', t => {
  const cell = new Cell(
    '##./' +
    '.../' +
    '#..'
  );
  const expected =
    '.##/' +
    '.../' +
    '..#';
  const actual = cell.flipHorizontal().toString();
  t.deepEqual(actual, expected);
  t.end();
});

test('flipVertical', t => {
  const cell = new Cell(
    '##./' +
    '.../' +
    '#..'
  );
  const expected =
    '#../' +
    '.../' +
    '##.';
  const actual = cell.flipVertical().toString();
  t.deepEqual(actual, expected);
  t.end();
});

test('flipBoth', t => {
  const cell = new Cell(
    '##./' +
    '.../' +
    '#..'
  );
  const expected =
    '..#/' +
    '.../' +
    '.##';
  const actual = cell.flipBoth().toString();
  t.deepEqual(actual, expected);
  t.end();
});

test('match', t => {
  const cell = new Cell(
    '##./' +
    '.../' +
    '#..'
  );
  const pattern =
    '##./' +
    '.../' +
    '#..';
  t.true(cell.match(pattern));
  t.end();
});

test('no match', t => {
  const cell = new Cell(
    '##./' +
    '.../' +
    '#..'
  );
  const pattern =
    '##./' +
    '.../' +
    '.#.';
  t.false(cell.match(pattern));
  t.end();
});

test('match wrong dim', t => {
  const cell = new Cell(
    '##./' +
    '.../' +
    '#..'
  );
  const pattern =
    '##../' +
    '..../' +
    '#.../' +
    '....';
  t.false(cell.match(pattern));
  t.end();
});

test('match rotate right', t => {
  const cell = new Cell(
    '##./' +
    '.../' +
    '#..'
  );
  const pattern =
    '#.#/' +
    '..#/' +
    '...';
  t.true(cell.match(pattern));
  t.end();
});

test('match rotate left', t => {
  const cell = new Cell(
    '##./' +
    '.../' +
    '#..'
  );
  const pattern =
    '.../' +
    '#../' +
    '#.#';
  t.true(cell.match(pattern));
  t.end();
});

test('match flip horizontal', t => {
  const cell = new Cell(
    '##./' +
    '.../' +
    '#..'
  );
  const pattern =
    '.##/' +
    '.../' +
    '..#';
  t.true(cell.match(pattern));
  t.end();
});

test('match flip vertical', t => {
  const cell = new Cell(
    '##./' +
    '.../' +
    '#..'
  );
  const pattern =
    '#../' +
    '.../' +
    '##.';
  t.true(cell.match(pattern));
  t.end();
});

test('match flip both', t => {
  const cell = new Cell(
    '##./' +
    '.../' +
    '#..'
  );
  const pattern =
    '..#/' +
    '.../' +
    '.##';
  t.true(cell.match(pattern));
  t.end();
});

test('match flip horizontal then rotate left', t => {
  const cell = new Cell(
    '##./' +
    '.../' +
    '#..'
  );
  const pattern =
    '#.#/' +
    '#../' +
    '...';
  t.true(cell.match(pattern));
  t.end();
});

test('match flip horizontal then rotate right', t => {
  const cell = new Cell(
    '##./' +
    '.../' +
    '#..'
  );
  const pattern =
    '.../' +
    '..#/' +
    '#.#';
  t.true(cell.match(pattern));
  t.end();
});