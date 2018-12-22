from enum import Enum
import sys

if len(sys.argv) < 2:
  print("Please give file name as argument")
  quit()

filename = sys.argv[1]

with open(filename, "r") as file:
  data = file.read()

directions = ("N", "E", "S", "W")
turns = ("L", "S", "R")

sets = {
  "-": set(),
  "|": set(),
  "\\": set(),
  "/": set(),
  "+": set()
}

trains = set()

x = 0
y = 0
for c in data:
  if c in sets.keys():
    sets[c].add((x, y))
  elif c == "^":
    sets["|"].add((x, y))
    trains.add((x, y, directions.index("N"), turns.index("L")))
  elif c == "v":
    sets["|"].add((x, y))
    trains.add((x, y, directions.index("S"), turns.index("L")))
  elif c == ">":
    sets["-"].add((x, y))
    trains.add((x, y, directions.index("E"), turns.index("L")))
  elif c == "<":
    sets["-"].add((x, y))
    trains.add((x, y, directions.index("W"), turns.index("L")))
  elif c == "\n":
    x = -1
    y += 1
  x += 1

part_1_solution = None
i = 0

while len(trains) > 1 or i < 1:
  collisions = set()
  for train in sorted(trains):
    if train in trains:
      trains.remove(train)
    (x, y, direction, turn) = train
    pos = (x, y)

    if pos in collisions:
      continue

    # find next position
    x += -1 if direction == directions.index("W") else 1 if direction == directions.index("E") else 0
    y += -1 if direction == directions.index("N") else 1 if direction == directions.index("S") else 0
    next_pos = (x, y)

    # find if train is already in that position
    collided_trains = set()
    for other_train in trains:
      (other_x, other_y, _other_direction, _other_turn) = other_train
      if (other_x, other_y) == (x, y):
        collided_trains.add(other_train)
        if not (x, y) in collisions:
          collisions.add((x, y))
        if part_1_solution == None:
          part_1_solution = (x, y)
    
    if len(collided_trains) > 0:
      trains -= collided_trains
      continue

    # find next direction
    if next_pos in sets["\\"]:
      if direction == directions.index("E") or direction == directions.index("W"):
        direction = (direction + 1) % 4
      else:
        direction = (direction - 1) % 4
    elif next_pos in sets["/"]:
      if direction == directions.index("N") or direction == directions.index("S"):
        direction = (direction + 1) % 4
      else:
        direction = (direction - 1) % 4
    elif next_pos in sets["+"]:
      if turns[turn] == "L":
        direction = (direction - 1) % 4
      elif turns[turn] == "R":
        direction = (direction + 1) % 4
      turn = (turn + 1) % len(turns)

    trains.add((x, y, direction, turn))

  if len(trains) <= 1:
    i += 1

print("Solution for part 1: {0},{1}".format(part_1_solution[0], part_1_solution[1]))

if len(trains) > 0:
  (x, y, _direction, _turn) = next(iter(trains))
  print("Solution for part 2: {0},{1}".format(x, y))
