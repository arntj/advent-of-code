import sys

def manhattan_dist(a:tuple, b:tuple):
  return sum((abs(p[0] - p[1]) for p in zip(a, b)))

if len(sys.argv) < 2:
  print("Please give file name as argument")
  quit()

filename = sys.argv[1]

with open(filename, "r", encoding="UTF-8") as file:
  coordinates = [ tuple(map(int, l.split(","))) for l in file.readlines() ]

constellations = []

for coord in coordinates:
  next_constellations = []
  current_constellation = { coord }

  for const in constellations:
    if any((c for c in const if manhattan_dist(coord, iter(c)) <= 3)):
      current_constellation |= const
    else:
      next_constellations.append(const)

  next_constellations.append(current_constellation)
  constellations = next_constellations

result = len(constellations)
print("The number of constellations is:", result)
