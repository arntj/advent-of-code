from solver import solve_part1, solve_part2

file = open("input.txt", "r")
input_lines = file.readlines()

print("\nPart 1 result:")
print(solve_part1(input_lines))
print("\nPart 2 result:")
print(solve_part2(input_lines))
print("")
