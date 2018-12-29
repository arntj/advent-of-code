import sys
from helpers import combat_part1, combat_part2

if len(sys.argv) < 2:
  print("Please give file name as argument")
  quit()

filename = sys.argv[1]

with open(filename, "r", encoding="UTF-8") as file:
  text = file.read()
  
score_part1 = combat_part1(text)
print("Score for part 1 is:", score_part1)

score_part2 = combat_part2(text)
print("Score for part 2 is:", score_part2)
