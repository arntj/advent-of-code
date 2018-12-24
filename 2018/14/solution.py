import sys

if len(sys.argv) < 2:
  print("Command line argument required: Puzzle input")
  quit()

puzzle_input_str = sys.argv[1].strip()
puzzle_input = list(map(int, puzzle_input_str))
skip = int(puzzle_input_str)
take = 10

recipies = [ 3, 7 ]
elves = [ 0, 1 ]
solved_part_1 = False
solved_part_2 = False
last_checked_index = -1

while not (solved_part_1 and solved_part_2):
  sum_recipies = sum((recipies[e] for e in elves))
  recipies.extend((int(x) for x in str(sum_recipies)))

  for i in range(len(elves)):
    elves[i] = (elves[i] + 1 + recipies[elves[i]]) % len(recipies)

  if not solved_part_1 and len(recipies) >= (skip + take):
    part_1_solution = "".join((str(r) for r in recipies[skip:skip + take]))
    print("Part 1 solution:", part_1_solution)
    solved_part_1 = True

  if not solved_part_2:
    for i in range(last_checked_index + 1, len(recipies) - len(puzzle_input)):
      last_checked_index = max(last_checked_index, i)
      if recipies[i:i+len(puzzle_input)] == puzzle_input:
        part_2_solution = i
        print("Part 2 solution:", part_2_solution)
        solved_part_2 = True
