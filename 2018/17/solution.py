import sys
from helpers import solve

if len(sys.argv) < 2:
  print("Please give file name as argument")
  quit()

filename = sys.argv[1]

with open(filename, "r", encoding="UTF-8") as file:
  input_lines = file.readlines()
  
solve(input_lines)
