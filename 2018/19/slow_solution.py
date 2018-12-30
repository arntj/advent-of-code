import sys
from operators import operators

def execute_program(program:list, ip_reg:int, registers:list):
  ip = 0

  while 0 <= ip < len(program):
    (instruction, *values) = program[ip]
    operators[instruction](registers, *values)
    ip = registers[ip_reg] = registers[ip_reg] + 1

if len(sys.argv) < 2:
  print("Please give file name as argument")
  quit()

filename = sys.argv[1]

with open(filename, "r", encoding="UTF-8") as file:
  lines = file.readlines()

ip_instruction = lines[0].split(" ")
program = [ (i[0], *(int(x) for x in i[1:] )) for i in (l.split(" ") for l in lines[1:]) ]

ip_reg = int(ip_instruction[1])
registers = [ 0, 0, 0, 0, 0, 0 ]

execute_program(program, ip_reg, registers)

print("Solution to part 1:", registers[0])
