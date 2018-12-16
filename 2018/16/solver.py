from operators import operators

def parse_instructions(input_lines):
  instructions_with_reg = []

  i = 0
  while i < len(input_lines) - 3:
    if input_lines[i].strip() == "":
      break

    reg_before_str = input_lines[i][9:-2]
    instruction_str = input_lines[i + 1]
    reg_after_str = input_lines[i + 2][9:-2]

    reg_before = [ int(x) for x in reg_before_str.split(", ") ]
    instruction = tuple((int(x) for x in instruction_str.split(" ")))
    reg_after = [ int(x) for x in reg_after_str.split(", ") ]

    instructions_with_reg.append((instruction, reg_before, reg_after))

    i += 4

  instructions = []
  while input_lines[i].strip() == "":
    i += 1

  while i < len(input_lines):
    instructions.append(tuple(( int(x) for x in input_lines[i].split(" "))))
    i += 1

  return (instructions_with_reg, instructions)

def test_instruction(instruction):
  result = []

  ((_opcode, A, B, C), reg_before, reg_after) = instruction

  for i in range(len(operators)):
    op = operators[i]

    reg = reg_before.copy()
    op(reg, A, B, C)

    if reg == reg_after:
      result.append(i)

  return result

def find_distinct_operators(opcode_index):
  while len([x for x in opcode_index.values() if len(x) > 1]) > 0:
    singles_sets = [ x for x in opcode_index.values() if len(x) == 1 ]
    singles = set.union(*singles_sets)

    for opcode, operators in opcode_index.items():
      if len(operators) > 1:
        opcode_index[opcode] = operators - singles

def flatten_opcode_index(opcode_index):
  for opcode in opcode_index:
    opcode_index[opcode] = next(iter(opcode_index[opcode]))

def execute_instruction(instruction, reg, opcode_index):
  (op, A, B, C) = instruction
  operator = operators[opcode_index[op]]
  operator(reg, A, B, C)

def solve(input_lines):
  (instructions_with_reg, instructions) = parse_instructions(input_lines)

  result_part1 = 0
  opcode_index = {}

  for i in instructions_with_reg:
    result = test_instruction(i)
    if len(result) >= 3:
      result_part1 += 1

    opcode = i[0][0]
    if opcode in opcode_index:
      opcode_index[opcode] = set(result) & opcode_index[opcode]
    else:
      opcode_index[opcode] = set(result)

  find_distinct_operators(opcode_index)
  flatten_opcode_index(opcode_index)

  reg = [0, 0, 0, 0]

  for instr in instructions:
    execute_instruction(instr, reg, opcode_index)

  result_part2 = reg[0]

  return (result_part1, result_part2)
    