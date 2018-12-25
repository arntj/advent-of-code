import sys

if len(sys.argv) < 4:
  print("Please give depth, target x and target y as three separate command line arguments.")
  quit()

def calculate_values(erosion_levels_lookup:dict, x:int, y:int):
  if (x,y) == (0,0) or (x,y) == (t_x,t_y):
    geologic_index = 0
  elif x == 0:
    geologic_index = y * 48271
  elif y == 0:
    geologic_index = x * 16807
  else:
    geologic_index = erosion_levels_lookup[(x-1,y)] * erosion_levels_lookup[(x,y-1)]

  erosion_level = (geologic_index + depth) % 20183
  
  return erosion_level

depth = int(sys.argv[1])
t_x = int(sys.argv[2])
t_y = int(sys.argv[3])
target = (t_x,t_y)

print("Calculating for depth {0}, target coordinates ({1},{2}).".format(depth, t_x, t_y))

risk_level = 0
erosion_levels_lookup = dict()
region_types_lookup = dict()

max_x = t_x + 100
max_y = t_y + 100

for x in range(0, max_x + 1):
  for y in range(0, max_y + 1):
    erosion_level = calculate_values(erosion_levels_lookup, x, y)
    erosion_levels_lookup[(x,y)] = erosion_level

    region_type = erosion_level % 3
    region_types_lookup[(x,y)] = region_type
    
    if x <= t_x and y <= t_y:
      risk_level += region_type

print("The solution for part 1 is:", risk_level)

# creating a hypothetical route as an upper bound to start out finding the fastest time
manhattan_distance = t_x + t_y
fastest_time = manhattan_distance * 8

# explore different routes and equipment, starting from target position
times_torch = {
  (0,0): 0
}
times_climbing = {
  (0,0): 7
}
times_neither = dict()

exploring = { (0,0) }

while len(exploring) > 0:
  next_exploring = set()
  for pos in exploring:
    (x,y) = pos

    for next_pos in [ (x,y-1), (x-1,y), (x+1,y), (x,y+1) ]:
      (next_x, next_y) = next_pos
      if next_x < 0 or next_x > max_x or next_y < 0 or next_y > max_y:
        continue
      
      region_type = region_types_lookup[next_pos]
      can_use_torch = region_type == 0 or region_type == 2
      can_use_climbing = region_type == 0 or region_type == 1
      can_use_neither = region_type == 1 or region_type == 2

      improved_times = False

      if can_use_torch:
        times = []
        if pos in times_torch:
          times.append(times_torch[pos] + 1)
        if can_use_climbing and pos in times_climbing:
          times.append(times_climbing[pos] + 8)
        if can_use_neither and pos in times_neither:
          times.append(times_neither[pos] + 8)
        if len(times) > 0:
          new_time = min(times)
          if new_time < fastest_time and (next_pos not in times_torch or new_time < times_torch[next_pos]):
            times_torch[next_pos] = new_time
            improved_times = True
            if next_pos == target:
              fastest_time = min(fastest_time, times_torch[target])

      if can_use_climbing:
        times = []
        if can_use_torch and pos in times_torch:
          times.append(times_torch[pos] + 8)
        if pos in times_climbing:
          times.append(times_climbing[pos] + 1)
        if can_use_neither and pos in times_neither:
          times.append(times_neither[pos] + 8)
        if len(times) > 0:
          new_time = min(times)
          if new_time < fastest_time and (next_pos not in times_climbing or new_time < times_climbing[next_pos]):
            times_climbing[next_pos] = new_time
            improved_times = True

      if can_use_neither:
        times = []
        if can_use_torch and pos in times_torch:
          times.append(times_torch[pos] + 8)
        if can_use_climbing and pos in times_climbing:
          times.append(times_climbing[pos] + 8)
        if pos in times_neither:
          times.append(times_neither[pos] + 1)
        if len(times) > 0:
          new_time = min(times)
          if new_time < fastest_time and (next_pos not in times_neither or new_time < times_neither[next_pos]):
            times_neither[next_pos] = new_time
            improved_times = True
      
      if improved_times:
        next_exploring.add(next_pos)
  
  exploring = next_exploring

print("The solution for part 2 is:", fastest_time)
