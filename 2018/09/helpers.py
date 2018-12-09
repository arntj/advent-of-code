from array import array
from parse import parse

class Marble:
  def __init__(self, value: int, prev: "Marble" = None, next: "Marble" = None):
    self.value = value
    self.prev = prev if prev != None else self
    self.next = next if next != None else self

  def next_n(self, n: int):
    curr_marble = self
    i = n
    while i > 0:
      curr_marble = curr_marble.next
      i -= 1

    return curr_marble

  def prev_n(self, n: int):
    curr_marble = self
    i = n
    while i > 0:
      curr_marble = curr_marble.prev
      i -= 1

    return curr_marble

def marbles_to_list(marble: Marble):
  result = [ marble.value ]
  curr_marble = marble.next

  while curr_marble != marble:
    result.append(curr_marble.value)
    curr_marble = curr_marble.next

  return result

def list_to_marbles(values: list):
  if len(values) == 0:
    return []

  marbles = [ Marble(values[0]) ]

  for v in values[1:]:
    m = Marble(v, prev = marbles[-1])
    marbles.append(m)
  
  marbles[0].prev = marbles[-1]

  for i in range(len(marbles) -1):
    marbles[i].next = marbles[i + 1]

  marbles[-1].next = marbles[0]
  return marbles[0]

def insert_marble_after(existing_marble: Marble, new_marble_value: int):
  new_marble = Marble(new_marble_value)
  before = existing_marble
  after = existing_marble.next

  before.next = new_marble
  new_marble.prev = before
  new_marble.next = after
  after.prev = new_marble

  return new_marble

def remove_marble(marble_to_remove: Marble):
  before = marble_to_remove.prev
  after = marble_to_remove.next
  before.next = after
  after.prev = before

  marble_to_remove.prev = marble_to_remove
  marble_to_remove.next = marble_to_remove

  return marble_to_remove

# returns ( score, current_marble )
def play_round(current_marble: Marble, next_marble_value: int):
  if next_marble_value % 23 == 0:
    new_current_marble = current_marble.prev_n(6)
    removed_marble = remove_marble(new_current_marble.prev)
    score = next_marble_value + removed_marble.value
    return (score, new_current_marble)

  new_marble = insert_marble_after(current_marble.next, next_marble_value)

  return (0, new_marble)

def play_marbles(players, last_marble):
  scores = [ 0 ] * players
  current_marble = Marble(0)

  for i in range(last_marble):
    next_marble_value = i + 1
    current_player_index = i % players
    (score, current_marble) = play_round(current_marble, next_marble_value)
    scores[current_player_index] += score

  return max(scores)

def parse_game(game_text):
  result = parse("{:d} players; last marble is worth {:d} points", game_text)

  return (result[0], result[1])
