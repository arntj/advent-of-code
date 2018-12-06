from helpers import find_manhattan_distance

file = open("input.txt", "r")
lines = file.readlines()

# parse coordinates to tuples
# (x, y, count_locations, is_outside)
coordinates = [ (int(line.split(",")[0]), int(line.split(",")[1]), 0, False) for line in lines]

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

# iterate over all locations
for curr_x in range(min_x, max_x + 1):
  for curr_y in range(min_y, max_y + 1):
    # find nearest coordinate
    nearest_index = 0
    nearest_dist = find_manhattan_distance(curr_x, curr_y, coordinates[0][0], coordinates[0][1])
    multiple_nearest = False

    for i in range(1, len(coordinates)):
      (x, y, count_locations, is_infinite) = coordinates[i]

      dist = find_manhattan_distance(curr_x, curr_y, x, y)

      if dist < nearest_dist:
        nearest_dist = dist
        nearest_index = i
        multiple_nearest = False
      elif dist == nearest_dist:
        multiple_nearest = True

    # avoid incrementing if multiple coordinates owns a location
    if not multiple_nearest:
      (x, y, count_locations, is_infinite) = coordinates[nearest_index]

      # increment
      count_locations += 1
      # find if coordinate is infinite in reach
      is_infinite = is_infinite or (curr_x == min_x or curr_x == max_x or curr_y == min_y or curr_y == max_y)
      # reassign coordinate
      coordinates[nearest_index] = (x, y, count_locations, is_infinite)

# find largest non-infinite coordinate
coord = sorted([ c for c in coordinates if not c[3] ], key=lambda c: c[2], reverse = True)

print(coord[0][2])
