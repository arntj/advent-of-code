from parse import parse
from copy import copy
from collections import namedtuple

file = open("input.txt", "r")
lines = file.readlines()

claims = [ parse("#{id} @ {x:d},{y:d}: {w:d}x{h:d}", x) for x in lines ]
overlaps = [ False for claim in range(len(claims)) ]

for i in range(len(claims)):
  a = claims[i]
  a_x_0 = a['x']
  a_x_1 = a['x'] + a['w']
  a_y_0 = a['y']
  a_y_1 = a['y'] + a['h']

  for j in range(i + 1, len(claims)):
    b = claims[j]
    b_x_0 = b['x']
    b_x_1 = b['x'] + b['w']
    b_y_0 = b['y']
    b_y_1 = b['y'] + b['h']

    overlap_x = min(a_x_1, b_x_1) - max(a_x_0, b_x_0)
    overlap_y = min(a_y_1, b_y_1) - max(a_y_0, b_y_0)

    if overlap_x > 0 and overlap_y > 0:
      overlaps[i] = True
      overlaps[j] = True
  
for i in range(len(overlaps)):
  if not overlaps[i]:
    print("{} has no overlaps".format(claims[i]['id']))
