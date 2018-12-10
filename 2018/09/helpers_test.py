import unittest
from helpers import (
  Marble,
  marbles_to_list,
  list_to_marbles,
  insert_marble_after,
  remove_marble,
  play_round,
  play_marbles,
  parse_game
)

class HelpersTests(unittest.TestCase):
  def test_marbles_to_list_single(self):
    # arrange
    marble = Marble(3)

    # act
    result = marbles_to_list(marble)

    # assert
    self.assertEqual(result, [ 3 ])

  def test_marbles_to_list_multiple(self):
    # arrange
    marbles = [ Marble(4), Marble(2), Marble(37) ]
    marbles[0].prev = marbles[2]
    marbles[0].next = marbles[1]
    marbles[1].prev = marbles[0]
    marbles[1].next = marbles[2]
    marbles[2].prev = marbles[1]
    marbles[2].next = marbles[0]

    # act
    result = marbles_to_list(marbles[0])

    # assert
    self.assertEqual(result, [ 4, 2, 37 ])

  def test_list_to_marbles(self):
    # arrange
    test_list = [ 3, 77, 9, 8 ]

    # act
    result = marbles_to_list(list_to_marbles(test_list))

    # assert
    self.assertEqual(result, test_list)

  def test_insert_marble_after(self):
    # arrange
    test_list = [ 4, 7, 88, 9, 11 ]
    first_marble = list_to_marbles(test_list)
    marble = first_marble.next_n(2)

    # act
    insert_marble_after(marble, 5)

    # assert
    result = marbles_to_list(first_marble)
    self.assertEqual(result, [ 4, 7, 88, 5, 9, 11 ])

  def test_remove_marble_returns_marble(self):
    # arrange
    test_list = [ 4, 7, 88, 9, 11 ]
    first_marble = list_to_marbles(test_list)
    marble = first_marble.next_n(2)

    # act
    result = remove_marble(marble)

    # assert
    self.assertEqual(result, marble)
    self.assertEqual(result.next, result)
    self.assertEqual(result.prev, result)

  def test_remove_marble_removes_marble(self):
    # arrange
    test_list = [ 4, 7, 88, 9, 11 ]
    first_marble = list_to_marbles(test_list)
    marble = first_marble.next_n(2)

    # act
    remove_marble(marble)

    # assert
    result = marbles_to_list(first_marble)
    self.assertEqual(result, [ 4, 7, 9, 11 ])

  def test_play_round_first(self):
    # arrange
    marbles_list = [ 0 ]
    marble = list_to_marbles(marbles_list)
    next_marble_value = 1

    # act
    (score, current_marble) = play_round(marble, next_marble_value)

    # assert
    marbles_list = marbles_to_list(marble)
    self.assertEqual(marbles_list, [ 0, 1 ])
    self.assertEqual(score, 0)
    self.assertEqual(current_marble.value, 1)

  def test_play_round_second(self):
    # arrange
    marbles_list = [ 0, 1 ]
    marble = list_to_marbles(marbles_list)
    current_marble = marble.next
    next_marble_value = 2

    # act
    (score, current_marble) = play_round(current_marble, next_marble_value)

    # assert
    result = marbles_to_list(marble)
    self.assertEqual(result, [ 0, 2, 1 ])
    self.assertEqual(score, 0)
    self.assertEqual(current_marble.value, 2)

  def test_play_round_typical_round(self):
    # arrange
    marbles_list = [ 0, 8, 4, 9, 2, 10, 5, 1, 6, 3, 7 ]
    marble = list_to_marbles(marbles_list)
    current_marble = marble.next_n(5)
    next_marble_value = 11

    # act
    (score, current_marble) = play_round(current_marble, next_marble_value)

    # assert
    result = marbles_to_list(marble)
    self.assertEqual(result, [ 0, 8, 4, 9, 2, 10, 5, 11, 1, 6, 3, 7 ])
    self.assertEqual(score, 0)
    self.assertEqual(current_marble.value, 11)

  def test_play_round_special_round(self):
    # arrange
    marbles_list = [ 0, 16, 8, 17, 4, 18, 9, 19, 2, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15 ]
    marble = list_to_marbles(marbles_list)
    current_marble = marble.next_n(13)
    next_marble_value = 23

    # act
    (score, current_marble) = play_round(current_marble, next_marble_value)

    # assert
    result = marbles_to_list(marble)
    self.assertEqual(result, [ 0, 16, 8, 17, 4, 18, 19, 2, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15 ])
    self.assertEqual(score, 32)
    self.assertEqual(current_marble.value, 19)

  def test_play_marbles(self):
    # arrange
    games = [
      (10, 1618, 8317),   # 10 players; last marble is worth 1618 points: high score is 8317
      (13, 7999, 146373), # 13 players; last marble is worth 7999 points: high score is 146373
      (17, 1104, 2764),   # 17 players; last marble is worth 1104 points: high score is 2764
      (21, 6111, 54718),  # 21 players; last marble is worth 6111 points: high score is 54718
      (30, 5807, 37305)   # 30 players; last marble is worth 5807 points: high score is 37305
    ]

    # act
    actual_scores = [ play_marbles(i[0], i[1]) for i in games ]

    # assert
    for i in range(len(games)):
      self.assertEqual(games[i][2], actual_scores[i])

  def test_parse_game(self):
    # arrange
    game_text = "19 players; last marble is worth 443 points"

    # act
    (players, points) = parse_game(game_text)

    # assert
    self.assertEqual(players, 19)
    self.assertEqual(points, 443)

if __name__ == '__main__':
    unittest.main()
