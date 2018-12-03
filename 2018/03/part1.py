from parse import parse

fabric_height = 1000
fabric_width = 1000

file = open("input.txt", "r")
lines = file.readlines()

claims = [ parse("#{id} @ {x:d},{y:d}: {w:d}x{h:d}", x) for x in lines ]

fabric = [ [ 0 for y in range(fabric_height) ] for x in range(fabric_width) ]
overlaps = 0

for claim in claims:
  x = claim['x']
  y = claim['y']
  for curr_x in range(claim['w']):
    for curr_y in range(claim['h']):
      fabric[x + curr_x][y + curr_y] += 1
      if fabric[x + curr_x][y + curr_y] == 2:
        overlaps += 1

print(overlaps)
