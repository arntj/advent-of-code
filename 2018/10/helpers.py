from parse import parse
from sys import stdout

def parse_point(point_text: str):
  parsed = parse("position=<{px:>6d}, {py:>6d}> velocity=<{vx:>2d}, {vy:>2d}>", point_text)
  return ((parsed['px'], parsed['py']), (parsed['vx'], parsed['vy']))

def draw_points(points: list):
  xs = [ p[0] for p in points ]
  ys = [ p[1] for p in points ]
  min_x = min(xs)
  max_x = max(xs)
  min_y = min(ys)
  max_y = max(ys)

  width = max_x - min_x + 1
  height = max_y - min_y + 1

  if (height > 50):
    return False

  drawing = [ [ False for x in range(width) ] for y in range(height) ]

  for p in points:
    x = p[0]
    y = p[1]
    drawing[y - min_y][x - min_x] = True

  for row in drawing:
    row_str = "".join(("*" if x else " " for x in row))

    print(row_str)

  return True

def tick(points: list, velocities: list):
  for i in range(len(points)):
    p = points[i]
    v = velocities[i]
    points[i] = (p[0] + v[0], p[1] + v[1])

def solve(input_lines):
  points = []
  velocities = []

  for p in (parse_point(p) for p in input_lines):
    points.append(p[0])
    velocities.append(p[1])

  t = 0

  while True:
    if draw_points(points):
      input("t={}, press enter for next".format(t))

    t += 1
    tick(points, velocities)
