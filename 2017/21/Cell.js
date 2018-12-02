const _data = Symbol();

class Cell {
  constructor(data) {
    if (typeof data === 'string') {
      this.initString(data);
    } else if (Array.isArray(data) && Array.isArray(data[0]) && data[0][0].constructor.name === Cell.name) {
      this.initCellArray(data);
    } else if (Array.isArray(data) && Array.isArray(data[0]) && typeof data[0][0] === 'boolean') {
      this.initRawData(data);
    }
  }
  initString(data) {
    this[_data] = data.split('/').map(line => line.split('').map(c => c === '#'));
  }
  initCellArray(data) {
    const dim = data[0].length;
    const cellDim = data[0][0].rawData()[0].length;
    const result = [];
  
    for (let row = 0; row < dim; row++) {
      for (let cellRow = 0; cellRow < cellDim; cellRow++) {
        const currRow = [].concat(...data[row].map(c => c.rawData()[cellRow]));
        result.push(currRow);
      }
    }
    this[_data] = result;
  }
  initRawData(data) {
    this[_data] = data;
  }
  rawData() {
    if (this[_data]) {
      return this[_data].map(line => [...line]);
    }
    return undefined;
  }
  splitCells() {
    const data = this[_data];
    const size = data.length;
    const cellSize = (data.length & 1) ? 3 : 2;
    const result = [];

    for (let row = 0; row < (size / cellSize); row++) {
      const currCellRow = [];
      for (let col = 0; col < (size / cellSize); col++) {
        const currCellData = [];
        for (let cellRow = 0; cellRow < cellSize; cellRow++) {
          const currRow = row * cellSize + cellRow;
          const currCol = col * cellSize;
          currCellData.push(data[currRow].slice(currCol, currCol + cellSize));
        }
        currCellRow.push(new Cell(currCellData));
      }
      result.push(currCellRow);
    }
    
    return result;
  }
  toString() {
    if (!this[_data]) {
      return '';
    }
    return this[_data].map(line => line.map(v => v ? '#' : '.').join('')).join('/');
  }
  toStringPretty() {
    if (!this[_data]) {
      return '';
    }
    return this[_data].map(line => line.map(v => v ? '#' : '.').join('  ')).join('\n');;
  }
  rotateRight() {
    const data = this.rawData().reverse();
    const result = [];
    const dim = data.length;
    for (let col = 0; col < dim; col++) {
      const currRow = data.map(row => row[col]);
      result.push(currRow);
    }
    return new Cell(result);
  }
  rotateLeft() {
    const data = this[_data].map(r => [...r].reverse())
    const result = [];
    const dim = data.length;
    for (let col = 0; col < dim; col++) {
      const currRow = data.map(row => row[col]);
      result.push(currRow);
    }
    return new Cell(result);
  }
  flipHorizontal() {
    const data = this[_data].map(r => [...r].reverse());
    return new Cell(data);
  }
  flipVertical() {
    const data = this[_data].map(r => [...r]).reverse();
    return new Cell(data);
  }
  flipBoth() {
    const data = this[_data].map(r => [...r].reverse()).reverse();
    return new Cell(data);
  }
  match(pattern) {
    const data = this[_data];
    let i = 0;

    let matchNoTransform = true;
    let matchRotateL = true;
    let matchRotateR = true;
    let matchFlipH = true;
    let matchFlipV = true;
    let matchFlipB = true;
    let matchFlipHRotateL = true;
    let matchFlipHRotateR = true;

    for (let row = 0; row < data.length; row++) {
      const reverseRow = (data.length - 1) - row;
      for (let col = 0; col < data.length; col++) {
        const on = pattern[i] === '#';
        const off = pattern[i] === '.';
        if (!(on || off)) {
          return false;
        }
        const reverseCol = (data.length - 1) - col;
        matchNoTransform = matchNoTransform && (data[row][col] === on);
        matchRotateL = matchRotateL && (data[col][reverseRow] === on);
        matchRotateR = matchRotateR && (data[reverseCol][row] === on);
        matchFlipH = matchFlipH && (data[row][reverseCol] === on);
        matchFlipV = matchFlipV && (data[reverseRow][col] === on);
        matchFlipB = matchFlipB && (data[reverseRow][reverseCol] === on);
        matchFlipHRotateL = matchFlipHRotateL && (data[col][row] === on);
        matchFlipHRotateR = matchFlipHRotateR && (data[reverseCol][reverseRow] === on);
        i++;
      }
      if (row < (data.length - 1) && pattern[i] !== '/') {
        return false;
      }
      i++;
    }
    let match = matchNoTransform;
    match = match || matchRotateL;
    match = match || matchRotateR;
    match = match || matchFlipH;
    match = match || matchFlipV;
    match = match || matchFlipB;
    match = match || matchFlipHRotateL;
    match = match || matchFlipHRotateR;
    return match && i === pattern.length + 1;
  }
  transform(rules) {
    for (let rule of rules) {
      if (this.match(rule[0])) {
        return new Cell(rule[1]);
      }
    }
    return null;
  }
  onCount() {
    return this[_data].map(row => row.reduce((prev, curr) => prev + (curr ? 1 : 0), 0)).reduce((prev, curr) => prev + curr, 0);
  }
}

module.exports = Cell;