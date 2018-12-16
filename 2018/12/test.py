from solver import solve_part1

file = open("test.txt", "r")
input_lines = file.readlines()

print("\nPart 1 result for test data:")
print(solve_part1(input_lines))
print("")
