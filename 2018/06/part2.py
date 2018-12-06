from helpers import find_manhattan_distance

file = open("input.txt", "r")
max_dist = 10000
lines = file.readlines()

# parse coordinates to tuples
# (x, y)
coordinates = [ (int(line.split(",")[0]), int(line.split(",")[1])) for line in lines]

# find min/max coordinates
min_x = coordinates[0][0]
min_y = coordinates[0][1]
max_x = coordinates[0][0]
max_y = coordinates[0][1]

for i in range(1, len(coordinates)):
  x = coordinates[i][0]
  y = coordinates[i][1]

  if x < min_x:
    min_x = x
  elif x > max_x:
    max_x = x

  if y < min_y:
    min_y = y
  elif y > max_y:
    max_y = y

# some extra margin to ensure reliability
min_x -= 5
min_y -= 5
max_x += 5
max_y += 5

region_size = 0

# iterate over all locations
for curr_x in range(min_x, max_x + 1):
  for curr_y in range(min_y, max_y + 1):
    # find total dist to all corrdinates
    total_dist = 0

    for c in coordinates:
      (x, y) = c

      total_dist += find_manhattan_distance(curr_x, curr_y, x, y)

      if total_dist >= max_dist:
        break

    if total_dist < max_dist:
      region_size += 1

print(region_size)
