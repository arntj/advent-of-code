const Register = require('./Register');
const splitLines = require('./splitLines');

class Program {
  constructor(id, instructions, initRegister) {
    this._register = new Register(initRegister);
    this._id = id;
    this._instructions = splitLines(instructions);
    this._i = 0;
    this._queue = [];
    this._friend = null;
    this._terminated = false;
    this._waiting = false;
    this._sendCount = 0;
    this._mulCount = 0;
  }

  get terminated() {
    return this._terminated;
  }

  get queue() {
    return [...this._queue];
  }

  get sendCount() {
    return this._sendCount;
  }

  get waiting() {
    return this._waiting;
  }

  get friend() {
    return this._friend;
  }

  set friend(program) {
    this._friend = program;
  }

  get mulCount() {
    return this._mulCount;
  }

  receive(value) {
    this._queue.push(value);
  }

  getRegisterValue(name) {
    return this._register.get(name);
  }

  next() {
    if (this._terminated) {
      return;
    }
    if (this._i >= this._instructions.length) {
      this._terminated = true;
      this._waiting = false;
      return;
    }

    const parts = this._instructions[this._i].split(' ');
    const cmd = parts[0];
    const x = parts[1];
    let yVal = null;
    if (typeof parts[2] !== 'undefined') {
      if (/[a-z]/.test(parts[2])) {
        yVal = this._register.get(parts[2]);
      } else {
        yVal = Number.parseInt(parts[2]);
      }
    }
    const y = yVal;

    if (cmd === 'snd') {
      const value = this._register.get(x);
      if (this._friend) {
        this._friend.receive(value);
      } else {
        this.receive(value);
      }
      this._sendCount++;
    }
    if (cmd === 'set') {
      this._register.set(x, y);
    }
    if (cmd === 'add') {
      this._register.add(x, y);
    }
    if (cmd === 'sub') {
      this._register.sub(x, y);
    }
    if (cmd === 'mul') {
      this._register.mul(x, y);
      this._mulCount++;
    }
    if (cmd === 'mod') {
      this._register.mod(x, y);
    }
    if (cmd === 'jgz') {
      let xVal = 0;
      if (/^-?\d+$/.test(x))
        xVal = parseInt(x);
      else
        xVal = this._register.get(x);

      if (xVal > 0)
        this._i += y - 1;
    }
    if (cmd === 'jnz') {
      let xVal = 0;
      if (/^-?\d+$/.test(x))
        xVal = parseInt(x);
      else
        xVal = this._register.get(x);

      if (xVal !== 0)
        this._i += y - 1;
    }
    if (cmd === 'rcv') {
      if (!this._friend) {
        if (this._register.get(x) > 0) {
          this._terminated = true;
          this._waiting = false
          return;
        }
      } else {
        if (this._queue.length === 0) {
          if (this._friend.waiting || this._friend.terminated) {
            this._terminated = true;
            this._waiting = false
          } else {
            this._waiting = true;
          }
          return;
        }
        this._register.set(x, this._queue.shift());
        this._waiting = false;
      }
    }
    this._i++;
  }

  runToEnd() {
    while (!this._terminated) {
      this.next();
    }
  }
}

module.exports = Program;