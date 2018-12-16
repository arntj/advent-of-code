from copy import deepcopy

def generate_grid(serial_number: int):
  grid = [ [ 0 for y in range(300) ] for x in range(300)]

  for x in range(1, 301):
    for y in range(1, 301):
      rack_id = x + 10
      power_level = rack_id * y
      power_level += serial_number
      power_level *= rack_id
      power_level = (power_level // 100) % 10
      power_level -= 5
      grid[x - 1][y - 1] = power_level

  return grid

def create_summed_grid(grid:list):
  summed_grid = deepcopy(grid)
  n = len(grid)

  for i in range(1, n):
    summed_grid[0][i] += summed_grid[0][i - 1]
    summed_grid[i][0] += summed_grid[i - 1][0]

  for x in range(2, n + 1):
    for y in range(2, n + 1):
      summed_grid[x - 1][y - 1] = summed_grid[x - 1][y - 1] + summed_grid[x - 2][y - 1] + summed_grid[x - 1][y - 2] - summed_grid[x - 2][y - 2]

  return summed_grid

def find_subgrid_sum(summed_grid: list, x0:int, y0:int, x1:int, y1:int):
  result = summed_grid[x1 - 1][y1 - 1]

  if x0 > 1 and y0 > 1:
    result += summed_grid[x0 - 2][y0 - 2]
  if x0 > 1:
    result -= summed_grid[x0 - 2][y1 - 1]
  if y0 > 1:
    result -= summed_grid[x1 - 1][y0 - 2]

  return result

def find_max_coordinates(grid: list):
  max_sum_global = result_global = max_sum_threes = result_threes = None
  n = len(grid)

  summed_grid = create_summed_grid(grid)

  for x in range(1, n + 1):
    for y in range(1, n + 1):
      i = 1

      while x + i - 1 <= n and y + i - 1 <= n:
        curr_sum = find_subgrid_sum(summed_grid, x, y, x + i - 1, y + i - 1)
        if max_sum_global == None or curr_sum > max_sum_global:
          max_sum_global = curr_sum
          result_global = (x, y, i)

        if i == 3 and (max_sum_threes == None or curr_sum > max_sum_threes):
          max_sum_threes = curr_sum
          result_threes = (x, y)
        
        i += 1

  return (result_threes, result_global)

def solve(serial_number: int):
  grid = generate_grid(serial_number)
  (part1, part2) = find_max_coordinates(grid)

  return (part1, part2)
