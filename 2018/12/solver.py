def parse_initial_state(input_lines:list):
  initial_state = input_lines[0][15:].strip()
  return { i: True if initial_state[i] == "#" else False for i in range(len(initial_state)) }

def parse_notes(input_lines:list):
  notes = {}
  for line in input_lines[2:]:
    from_state = tuple((True if c == "#" else False for c in line[:5]))
    to_state = True if line[9:10] == "#" else False
    notes[from_state] = to_state

  return notes

def get_value(state:dict, i:int):
  if i in state:
    return state[i]

  return False

def tick(state:dict, notes:list):
  min_val = min(state.keys())
  max_val = max(state.keys())
  next_state = state.copy()

  for i in range(min_val - 5, max_val + 6):
    curr_state = tuple(( get_value(state, x) for x in range(i - 2, i + 3) ))
    if curr_state in notes:
      next_state[i] = notes[curr_state]
    else:
      next_state[i] = False

  return next_state

def get_score(state:dict):
  min_val = min(state.keys())
  max_val = max(state.keys())

  return sum([ i if get_value(state, i) else 0 for i in range (min_val, max_val + 1)])

def solve_part1(input_lines):
  state = parse_initial_state(input_lines)
  notes = parse_notes(input_lines)

  for _ in range(20):
    state = tick(state, notes)

  return get_score(state)

def solve_part2(input_lines):
  state = parse_initial_state(input_lines)
  notes = parse_notes(input_lines)

  for _ in range(100):
    state = tick(state, notes)

  a = get_score(state)
  state = tick(state, notes)
  b = get_score(state)
  
  diff = b - a

  result = a + (50000000000 - 100) * diff
  return result
