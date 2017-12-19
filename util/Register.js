class Register {
  constructor(init) {
    this._register = [];

    if (init) {
      for (let name in init) {
        this._register[name] = init[name];
      }
    }
  }

  set(name, value) {
    this._register[name] = value;
  }

  get(name) {
    if (typeof this._register[name] === 'undefined')
      return 0;

    return this._register[name];
  }

  add(name, value = 1) {
    const newValue = this.get(name) + value;
    this.set(name, newValue);
    return newValue;
  }

  sub(name, value = 1) {
    return this.add(name, -value);
  }

  mul(name, value) {
    const newValue = this.get(name) * value;
    this.set(name, newValue);
    return newValue;
  }

  mod(name, value) {
    const newValue = this.get(name) % value;
    this.set(name, newValue);
    return newValue;
  }

  toArray() {
    return this._register;
  }

  get values() {
    return Object.values(this._register);
  }
}

module.exports = Register;