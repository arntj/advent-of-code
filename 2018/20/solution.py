import sys

if len(sys.argv) < 2:
  print("Please give file name as argument")
  quit()

filename = sys.argv[1]

with open(filename, "r", encoding="UTF-8") as file:
  text = file.read()

path = text[1:text.index("$")]

south_doors = set()
east_doors = set()

curr_room = (0,0)
room_stack = []

# map out all doors
for c in path:
  (x,y) = curr_room

  if c == "N":
    curr_room = (x,y-1)
    south_doors.add(curr_room)
  elif c == "S":
    south_doors.add(curr_room)
    curr_room = (x,y+1)
  elif c == "E":
    east_doors.add(curr_room)
    curr_room = (x+1,y)
  elif c == "W":
    curr_room = (x-1,y)
    east_doors.add(curr_room)
  elif c == "(":
    room_stack.append(curr_room)
  elif c == "|":
    curr_room = room_stack[-1]
  elif c == ")":
    curr_room = room_stack.pop()

# explore all rooms
explored = { (0,0) }
current = [ (0,0) ]
longest_path = -1
over_thousand = 0

while len(current) > 0:
  next_current = []

  for room in current:
    (x,y) = room
    (n, w, e, s) = [(x,y-1), (x-1,y), (x+1,y), (x,y+1)]
    
    if n not in explored and n in south_doors:
      explored.add(n)
      next_current.append(n)
    if s not in explored and room in south_doors:
      explored.add(s)
      next_current.append(s)
    if w not in explored and w in east_doors:
      explored.add(w)
      next_current.append(w)
    if e not in explored and room in east_doors:
      explored.add(e)
      next_current.append(e)

  longest_path += 1

  if longest_path >= 1000:
    over_thousand += len(current)

  current = next_current

print("Solution to part 1:", longest_path)
print("Solution to part 2:", over_thousand)
