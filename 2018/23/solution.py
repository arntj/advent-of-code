import sys
from math import ceil

if len(sys.argv) < 2:
  print("Please give file name as argument")
  quit()

filename = sys.argv[1]

with open(filename, "r", encoding="UTF-8") as file:
  lines = file.readlines()

nanobots = dict()

for line in lines:
  positions = line[5:line.index(">")]
  radius = line[line.index("r=")+2:]

  pos = tuple((int(c) for c in positions.split(",")))
  r = int(radius)

  nanobots[pos] = r

max_r = None

for bot in nanobots.items():
  (pos, r) = bot
  if max_r == None or r > max_r:
    strongest_bot_position = pos
    max_r = r

def calc_dist(a:tuple, b:tuple):
  return sum(( abs(x[0] - x[1]) for x in zip(a, b) ))

in_range = 0

for bot_pos in nanobots.keys():
  if calc_dist(strongest_bot_position, bot_pos) <= max_r:
    in_range += 1

print("The solution for part 1 is:", in_range)

min_pos = next(iter(nanobots.keys()))
max_pos = min_pos

for bot in nanobots.items():
  (pos, r) = bot
  min_pos = tuple(( min(pos[i] - r, min_pos[i]) for i in range(3) ))
  max_pos = tuple(( max(pos[i] + r, max_pos[i]) for i in range(3) ))

length = max(( abs(x[0] - x[1]) for x in zip(min_pos, max_pos) ))

def intersect(cube:tuple, bot:tuple):
  dist = 0
  (c_coord, length) = cube
  (b_coord, r) = bot
  for d in zip(c_coord, b_coord):
    (c,b) = d
    if b < c:
      dist += c - b
    elif b > (c + length-0.5):
      dist += b - (c + length-0.5)

  return dist < r

def get_intersect(cube:tuple, nanobots:set):
  return set(( bot for bot in nanobots if intersect(cube, bot) ))

search_cubes = [
  (min_pos, length, nanobots.items())
]
current_length = length

while current_length > 1:
  new_search_cubes = []
  current_length = ceil(current_length / 2)
  max_n = 0
  for sc in search_cubes:
    ((x,y,z), _length, curr_bots) = sc
    next_search_cubes = [
      ((x,y,z), current_length),
      ((x+current_length,y,z), current_length),
      ((x,y+current_length,z), current_length),
      ((x,y,z+current_length), current_length),
      ((x+current_length,y+current_length,z), current_length),
      ((x+current_length,y,z+current_length), current_length),
      ((x,y+current_length,z+current_length), current_length),
      ((x+current_length,y+current_length,z+current_length), current_length)
    ]
    for c in next_search_cubes:
      (pos, c_l) = c
      i_bots = get_intersect(c, curr_bots)
      n = len(i_bots)
      c = (pos, c_l, i_bots)
      if n > max_n:
        new_search_cubes = [ c ]
        max_n = n
      elif n == max_n:
        new_search_cubes.append(c)
  
  search_cubes = new_search_cubes

min_dist = None

for c in search_cubes:
  (coord, _length, _bots) = c
  dist = sum(coord)
  if min_dist == None or dist < min_dist:
    min_dist = dist

print("The solution for part 2 is:", min_dist)
