from enum import Enum
from time import sleep
from sys import stdout
from random import choice
from tkinter import Tk, Canvas, PhotoImage
from typing import List

def parse_input(input_lines:list):
  result = []

  for line in input_lines:
    parts = line.split(",")
    left_parts = parts[0].split("=")
    left_symbol = left_parts[0]
    left_value = int(left_parts[1])
    right_parts = parts[1].split("=")
    right_symbol = right_parts[0].strip()
    right_range = right_parts[1].split("..")
    right_start = int(right_range[0])
    right_end = int(right_range[1])
    line_parsed = ((left_symbol, left_value), (right_symbol, right_start, right_end))
    result.append(line_parsed)

  return result

def find_min_max_values(lines:list):
  min_x = None
  min_y = None
  max_x = None
  max_y = None

  # find max/min values
  for line in lines:
    ((left_symbol, left_value), (right_symbol, right_start, right_end)) = line

    if left_symbol == "x" and (min_x == None or min_x > left_value):
      min_x = left_value
    if left_symbol == "x" and (max_x == None or max_x < left_value):
      max_x = left_value
    if left_symbol == "y" and (min_y == None or min_y > left_value):
      min_y = left_value
    if left_symbol == "y" and (max_y == None or max_y < left_value):
      max_y = left_value

    if right_symbol == "x" and (min_x == None or min_x > right_start):
      min_x = right_start
    if right_symbol == "x" and (max_x == None or max_x < right_end):
      max_x = right_end
    if right_symbol == "y" and (min_y == None or min_y > right_start):
      min_y = right_start
    if right_symbol == "y" and (max_y == None or max_y < right_end):
      max_y = right_end

  return ((min_x, min_y), (max_x, max_y))

class Tile(Enum):
  SAND = 1
  CLAY = 2
  WATER = 3
  DRIED = 4
  SPRING = 5

class WaterDirection(Enum):
  DOWN = 1
  LEFT = 2
  RIGHT = 3

tile_colors = {
  Tile.SAND: "#efc640",
  Tile.CLAY: "#a09e95",
  Tile.WATER: "#0f4bff",
  Tile.DRIED: "#ffffff",
  Tile.SPRING: "#96cdf7"
}

scale_factor = 4

def generate_tiles(lines:list):
  ((min_x, min_y), (max_x, max_y)) = find_min_max_values(lines)
  min_x -= 5
  max_x += 5
  tiles = [ [ Tile.SAND for x in range(min_x, max_x + 1) ] for y in range(max_y + 1) ]

  for line in lines:
    ((left_symbol, left_value), (_right_symbol, right_start, right_end)) = line

    for i in range(right_start, right_end + 1):
      x = left_value if left_symbol == "x" else i
      y = left_value if left_symbol == "y" else i

      tiles[y][x - min_x] = Tile.CLAY

  spring_x = 500 - min_x
  spring_y = 0
  tiles[spring_y][spring_x] = Tile.SPRING

  return (tiles, (spring_x, spring_y), min_y)

def tick(tiles: list, water_fronts: set, highest_y: int, image: PhotoImage = None):
  max_y = len(tiles) - 1
  next_water_fronts = set()
  for wf in water_fronts:
    # moving down
    (x, y) = wf
    if y == max_y:
      # moving out of map
      continue
    elif tiles[y + 1][x] == Tile.DRIED:
      # another water front was here already
      continue
    elif tiles[y + 1][x] == Tile.SAND:
      # continue moving down
      tiles[y + 1][x] = Tile.DRIED
      next_water_fronts.add((x, y + 1))
      highest_y = max(highest_y, y + 1)
      if image:
        draw(image, (x, y + 1), Tile.DRIED)
    else:
      # hit something hard, start moving out to the sides
      left_x = right_x = x      
      while True:
        left_can_move_down = tiles[y + 1][left_x] == Tile.SAND or tiles[y + 1][left_x] == Tile.DRIED
        left_can_move_left = tiles[y][left_x - 1] == Tile.SAND or tiles[y][left_x - 1] == Tile.DRIED
        right_can_move_down = tiles[y + 1][right_x] == Tile.SAND or tiles[y + 1][right_x] == Tile.DRIED
        right_can_move_right = tiles[y][right_x + 1] == Tile.SAND or tiles[y][right_x + 1] == Tile.DRIED

        if (left_can_move_down or not left_can_move_left) and (right_can_move_down or not right_can_move_right):
          # both left and right end has reached the end
          for curr_x in range(left_x, right_x + 1):
            curr_tile = Tile.DRIED if (left_can_move_down or right_can_move_down) else Tile.WATER
            tiles[y][curr_x] = curr_tile
            if image:
              draw(image, (curr_x, y), curr_tile)
          if right_can_move_down:
            next_water_fronts.add((right_x, y))
            highest_y = max(highest_y, y)
          if left_can_move_down:
            next_water_fronts.add((left_x, y))
            highest_y = max(highest_y, y)
          if not (left_can_move_down or right_can_move_down):
            # backtrack one up
            next_water_fronts.add((x, y - 1))
          break

        if left_can_move_left and not left_can_move_down:
          left_x -= 1

        if right_can_move_right and not right_can_move_down:
          right_x += 1

  return (next_water_fronts, highest_y)

def calculate_score(tiles: list, include_dried: bool):
  score = 0
  for row in tiles:
    for c in row:
      if c == Tile.WATER or (include_dried and c == Tile.DRIED):
        score += 1

  return score

def draw(image: PhotoImage, to: tuple, tile: Tile):
  draw_row(image, to, [ tile ])

def draw_row(image: PhotoImage, to: tuple, tiles: List[Tile]):
  (x, y) = to
  colors = " ".join((" ".join([tile_colors[t]] * scale_factor) for t in tiles))
  row = "{ " + colors + " }"
  for i in range(scale_factor):
    image.put(row, to=(x*scale_factor+1, y*scale_factor+i+1))

def create_canvas(tiles:list, canvas_height: int):
  width = len(tiles[0])
  height = len(tiles)
  window = Tk()
  canvas = Canvas(window, width=width*scale_factor - 1, height=canvas_height * scale_factor, bg="#000000")
  canvas.pack()
  image = PhotoImage(width=width*scale_factor, height=height*scale_factor)
  canvas_image = canvas.create_image(1, 1, anchor="nw", image=image)

  return (canvas, image, canvas_image)

def draw_image(tiles: list, canvas: Canvas, image: PhotoImage):
  for y in range(len(tiles)):
    draw_row(image, (0, y), tiles[y])

def refresh_canvas(canvas: Canvas):
  canvas.update_idletasks()
  canvas.update()

def solve(input_lines: list, animate: bool = False):
  lines = parse_input(input_lines)
  (tiles, (spring_x, spring_y), min_y) = generate_tiles(lines)

  canvas = None
  image = None
  canvas_image = None
  draw_height = 100
  y_margin = 10

  (x, y) = spring_x, spring_y + 1
  tiles[y][x] = Tile.DRIED
  water_fronts = { (x, y) }

  if animate:
    (canvas, image, canvas_image) = create_canvas(tiles, draw_height)
    draw_image(tiles, canvas, image)
    refresh_canvas(canvas)
    sleep(0.1)

  latest_drawn_y = 0
  highest_y = y

  while len(water_fronts) > 0:
    (water_fronts, highest_y) = tick(tiles, water_fronts, highest_y, image)

    if animate:
      if highest_y > (latest_drawn_y + draw_height - y_margin):
        next_y = min(highest_y + y_margin - draw_height, len(tiles) - draw_height)
        diff = next_y - latest_drawn_y

        if diff > 0:
          canvas.move(canvas_image, 0, -diff*scale_factor)
          latest_drawn_y = next_y

      refresh_canvas(canvas)
      sleep(0.01)

  result_part1 = calculate_score(tiles[min_y:], True)
  result_part2 = calculate_score(tiles[min_y:], False)

  print("Result for part 1:", result_part1)
  print("Result for part 2:", result_part2)
      