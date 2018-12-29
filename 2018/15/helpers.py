# example of state:
# walls = { (0, 0), (0, 1) }
# elf = ("E", 200, 3)
# goblin = ("G", 200, 3)
# units = { (1,1): elf, (1,2): goblin }
# state = (walls, units)

def parse_map(text:str, elf_hitpoints:int = 3):
  walls = set()
  units = dict()

  x = 0
  y = 0

  for c in text:
    if c == "#":
      walls.add((x, y))
    elif c == "E" or c == "G":
      hitpoints = elf_hitpoints if c == "E" else 3
      units[(x, y)] = (c, 200, hitpoints)
    
    if c == "\n":
      x = 0
      y += 1
    else:
      x += 1

  return (walls, units)

def find_attackable_position(units:dict, current_position:tuple):
  (x, y) = current_position
  (unit_type, _hitpoints, _attack_power) = units[current_position]

  coords_in_range = [ c for c in [(x, y-1), (x-1, y), (x+1, y), (x, y+1)] if c in units and units[c][0] != unit_type ]

  if len(coords_in_range) == 0:
    return None

  # sort by hit points first, then by coordinates in reading order
  sorted_coords = sorted(coords_in_range, key=lambda c:(units[c][1], c[1], c[0]))

  return sorted_coords[0]

def attack(state:tuple, current_position:tuple):
  (walls, units) = state
  unit = units[current_position]
  
  coords_to_attack = find_attackable_position(units, current_position)

  if coords_to_attack == None:
    return (False, state, None)
    
  next_units = units.copy()
  unit_to_attack = next_units.pop(coords_to_attack)  
  attacked_unit = (unit_to_attack[0], unit_to_attack[1] - unit[2], *unit_to_attack[2:])

  killed_unit = None

  if attacked_unit[1] > 0:
    next_units[coords_to_attack] = attacked_unit
  else:
    killed_unit = coords_to_attack

  next_state = (walls, next_units)
  return (True, next_state, killed_unit)

def find_all_attack_positions(state:tuple, current_position:tuple):
  result = set()

  (walls, units) = state
  unit_type = units[current_position][0]

  for pos in units.keys():
    if pos == current_position or units[pos][0] == unit_type:
      continue
    (x, y) = pos
    for attack_position in [ (x,y-1), (x-1,y), (x+1,y), (x,y+1) ]:
      if attack_position not in walls and attack_position not in units:
        result.add(attack_position)

  return result

# finds the shortest path to an attack position and calculate the next step to take
# finds the shortest path to an attack position and calculate the next step to take
def move(state:tuple, current_position:tuple):
  (walls, units) = state
  
  attack_positions = find_all_attack_positions(state, current_position)

  if len(attack_positions) == 0:
    return (False, state, current_position)

  # places we're currently searching
  current_searches = set()
  # memoisation of places we've already visited
  searched = { current_position }
  # when we find complete paths, the first and last move is stored in this set
  found_first_moves = set()

  (x, y) = current_position
  for pos in [ (x, y-1), (x-1, y), (x+1, y), (x, y+1) ]:
    if pos not in walls and pos not in units:
      # the tuple contains the same position twice, as it represents both
      # the first move from the starting position, and the current square
      # being searched
      current_searches.add((pos, pos))
      searched.add(pos)
    if pos in attack_positions:
      found_first_moves.add((pos, pos))

  # do search
  while len(found_first_moves) == 0 and len(current_searches) > 0:
    next_searches = set()
    new_searched = set()

    for search in current_searches:
      (first_move, (x, y)) = search
      for pos in [ (x, y-1), (x-1, y), (x+1, y), (x, y+1) ]:
        if pos not in walls and pos not in units and pos not in searched:
          next_searches.add((first_move, pos))
          new_searched.add(pos)
          if pos in attack_positions:
            found_first_moves.add((first_move, pos))

    current_searches = next_searches
    searched |= new_searched

  if len(found_first_moves) == 0:
    return (False, state, current_position)

  next_move = next(iter(sorted(found_first_moves, key=lambda x:(x[1][::-1],x[0][::-1]))))[0]

  next_units = units.copy()
  unit = next_units.pop(current_position)
  next_units[next_move] = unit
  next_state = (walls, next_units)
  
  return (True, next_state, next_move)

def tick(state:tuple):
  (_walls, units) = state
  available_pos = set(units.keys())

  while len(available_pos) > 0:
    next_pos = next(iter(sorted(available_pos, key=lambda x:x[::-1])), None)

    units = state[1]
    unit = units[next_pos]

    if not any(( u for u in units.keys() if units[u][0] != unit[0])):
      return (False, state)

    (did_attack, state, killed_unit) = attack(state, next_pos)

    if not did_attack:
      (did_move, state, moved_pos) = move(state, next_pos)

      if did_move:
        (did_attack, state, killed_unit) = attack(state, moved_pos)
    
    if killed_unit and killed_unit in available_pos:
      available_pos.remove(killed_unit)
    
    available_pos.remove(next_pos)
  
  return (True, state)

def is_over(state:tuple):
  has_elf = False
  has_gnome = False
  (_walls, units) = state

  for unit in units.values():
    if unit[0] == "E":
      if has_gnome:
        return False
      has_elf = True

    if unit[0] == "G":
      if has_elf:
        return False
      has_gnome = True

  return True

def sum_hitpoints(state:tuple):
  (_walls, units) = state

  score = 0

  for unit in units.values():
    score += unit[1]

  return score

def combat_part1(text:str):
  state = parse_map(text)

  rounds = 0

  while True:
    (remaining_enemies, state) = tick(state)

    if not remaining_enemies:
      break
    
    rounds += 1

  print(sum_hitpoints(state), rounds)
  return sum_hitpoints(state) * rounds

def combat_part2(text:str):
  elf_hitpoints = 4

  while True:
    state = parse_map(text, elf_hitpoints)
    initial_elf_count = len([ e for e in state[1].values() if e[0] == "E"])

    rounds = 0
    killed_elf = False

    while True:
      (remaining_enemies, state) = tick(state)

      if len([ e for e in state[1].values() if e[0] == "E"]) != initial_elf_count:
        killed_elf = True
        break

      if not remaining_enemies:
        break
      
      rounds += 1

    if killed_elf:
      elf_hitpoints += 1
      continue

    return sum_hitpoints(state) * rounds
