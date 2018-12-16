def addr(r:list, A:int, B:int, C:int):
  r[C] = r[A] + r[B]

def addi(r:list, A:int, B:int, C:int):
  r[C] = r[A] + B

def mulr(r:list, A:int, B:int, C:int):
  r[C] = r[A] * r[B]

def muli(r:list, A:int, B:int, C:int):
  r[C] = r[A] * B

def banr(r:list, A:int, B:int, C:int):
  r[C] = r[A] & r[B]

def bani(r:list, A:int, B:int, C:int):
  r[C] = r[A] & B

def borr(r:list, A:int, B:int, C:int):
  r[C] = r[A] | r[B]

def bori(r:list, A:int, B:int, C:int):
  r[C] = r[A] | B

def setr(r:list, A:int, B:int, C:int):
  r[C] = r[A]

def seti(r:list, A:int, B:int, C:int):
  r[C] = A

def gtir(r:list, A:int, B:int, C:int):
  r[C] = 1 if A > r[B] else 0

def gtri(r:list, A:int, B:int, C:int):
  r[C] = 1 if r[A] > B else 0

def gtrr(r:list, A:int, B:int, C:int):
  r[C] = 1 if r[A] > r[B] else 0

def eqir(r:list, A:int, B:int, C:int):
  r[C] = 1 if A == r[B] else 0

def eqri(r:list, A:int, B:int, C:int):
  r[C] = 1 if r[A] == B else 0

def eqrr(r:list, A:int, B:int, C:int):
  r[C] = 1 if r[A] == r[B] else 0

operators = [
  addr,
  addi,
  mulr,
  muli,
  banr,
  bani,
  borr,
  bori,
  setr,
  seti,
  gtir,
  gtri,
  gtrr,
  eqir,
  eqri,
  eqrr
]