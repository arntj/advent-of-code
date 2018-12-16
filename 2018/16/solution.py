from solver import solve

file = open("input.txt", "r")
input_lines = file.readlines()

(result_part1, result_part2) = solve(input_lines)

print("\nSolution to part 1 is:")
print(result_part1)
print("\nSolution to part 2 is:")
print(result_part2)
print("")
