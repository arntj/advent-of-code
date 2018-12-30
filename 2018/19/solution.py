import sys

def execute_program(r0:int):
  if r0 == 0:
    n = 1018
  elif r0 == 1:
    n = 10551418

  total = 0

  for a in range(1, n + 1):
    if n % a == 0:
      total += a
    
  return total

print("Solution to part 1:", execute_program(0))
print("Solution to part 2:", execute_program(1))
