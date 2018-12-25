import sys

n = 1000000000

def forest_to_string(forest:list):
  return "\n".join("".join(row) for row in forest)

def calculate_score(forest:list):  
  number_of_wood = sum((row.count("|") for row in forest))
  number_of_lumberyards = sum((row.count("#") for row in forest))
  return number_of_wood * number_of_lumberyards

if len(sys.argv) < 2:
  print("Please give file name as argument")
  quit()

filename = sys.argv[1]

with open(filename, "r", encoding="UTF-8") as file:
  text = file.read()

forest = []

curr_row = []

for c in text:
  if c in ".#|":
    curr_row.append(c)
  elif c == "\n":
    forest.append(curr_row)
    curr_row = []

min_y = 0
max_y = len(forest) - 1
min_x = 0
max_x = len(forest[0]) - 1

history = dict()
cycle_time = None

for i in range(1, n + 1):
  new_forest = []

  for y in range(len(forest)):
    new_row = []

    for x in range(len(forest[y])):
      adjacent = []
      if y > min_y:
        adjacent.extend(forest[y-1][max(min_x, x-1):min(max_x, x+1)+1])
      if x > min_x:
        adjacent.append(forest[y][x-1])
      if x < max_x:
        adjacent.append(forest[y][x+1])
      if y < max_y:
        adjacent.extend(forest[y+1][max(min_x, x-1):min(max_x, x+1)+1])

      c = forest[y][x]

      if c == "." and adjacent.count("|") >= 3:
        new_row.append("|")
      elif c == "|" and adjacent.count("#") >= 3:
        new_row.append("#")
      elif c == "#" and not (adjacent.count("#") > 0 and adjacent.count("|") > 0):
        new_row.append(".")
      else:
        new_row.append(c)
    
    new_forest.append(new_row)

  if i == 10:
    print("Part 1 solution:", calculate_score(new_forest))

  forest = new_forest

  if cycle_time == None:
    forest_str = forest_to_string(forest)
    if forest_str in history:
      previous_time = history[forest_str]
      cycle_time = i - previous_time

  if cycle_time != None and (n - i) % cycle_time == 0:
    break

  history[forest_str] = i

print("Part 2 solution:", calculate_score(forest))
