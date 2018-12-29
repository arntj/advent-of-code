import unittest
from helpers import (
  parse_map,
  find_attackable_position,
  attack,
  find_all_attack_positions,
  move
)

class HelpersTests(unittest.TestCase):
  def test_parse_map_parses_wall(self):
    # arrange
    test_map = (
      "###\n"
      "###\n"
    )

    # act
    actual = parse_map(test_map)

    # assert
    expected_walls = { (0,0), (1,0), (2,0), (0,1), (1,1), (2,1) }
    expected_units = dict()
    expected_state = (expected_walls, expected_units)
    self.assertEqual(actual, expected_state)

  def test_parse_map_skips_empty(self):
    # arrange
    test_map = (
      "#..\n"
      "###\n"
    )

    # act
    actual = parse_map(test_map)

    # assert
    expected_walls = { (0,0), (0,1), (1,1), (2,1) }
    expected_units = dict()
    expected_state = (expected_walls, expected_units)
    self.assertEqual(actual, expected_state)

  def test_parse_map_parses_elves(self):
    # arrange
    test_map = (
      "..E\n"
      ".E.\n"
    )

    # act
    actual = parse_map(test_map)

    # assert
    expected_walls = set()
    expected_units = { (2,0): ("E", 200, 3), (1,1): ("E", 200, 3) }
    expected_state = (expected_walls, expected_units)
    self.assertEqual(actual, expected_state)

  def test_parse_map_parses_goblins(self):
    # arrange
    test_map = (
      "..GG\n"
      "....\n"
    )

    # act
    actual = parse_map(test_map)

    # assert
    expected_walls = set()
    expected_units = { (2,0): ("G", 200, 3), (3,0): ("G", 200, 3) }
    expected_state = (expected_walls, expected_units)
    self.assertEqual(actual, expected_state)
  
  def test_find_attackable_position_none(self):
    # arrange
    test_map = (
      "G.G\n"
      ".E.\n"
      "G.G\n"
    )
    (_walls, test_units) = parse_map(test_map)

    # act
    actual = find_attackable_position(test_units, (1, 1))

    # assert
    self.assertEqual(actual, None)

  def test_find_attackable_position(self):
    # arrange
    test_units = {
      (0,0): ("G", 200, 3),
      (1,0): ("E", 200, 3)
    }

    # act
    actual = find_attackable_position(test_units, (0, 0))

    # assert
    self.assertEqual(actual, (1,0))

  def test_find_attackable_position_must_be_different_unit_type(self):
    # arrange
    test_units = {
      (0,0): ("G", 200, 3),
      (1,0): ("G", 200, 3)
    }

    # act
    actual = find_attackable_position(test_units, (0, 0))

    # assert
    self.assertEqual(actual, None)

  def test_find_attackable_position_reading_order(self):
    # arrange
    test_units = {
      (1,0): ("G", 200, 3),
      (0,1): ("G", 200, 3),
      (1,1): ("E", 200, 3)
    }

    # act
    actual = find_attackable_position(test_units, (1, 1))

    # assert
    self.assertEqual(actual, (1,0))

  def test_find_attackable_position_weakest_first(self):
    # arrange
    test_units = {
      (1,0): ("G", 200, 3),
      (0,1): ("G", 150, 3),
      (1,1): ("E", 200, 3)
    }

    # act
    actual = find_attackable_position(test_units, (1, 1))

    # assert
    self.assertEqual(actual, (0,1))

  def test_attack_dont_attack_if_none_in_range(self):
    # arrange
    test_map = (
      "G.G\n"
      ".E.\n"
      "G.G\n"
    )
    (test_state) = parse_map(test_map)

    # act
    actual = attack(test_state, (1, 1))

    # assert
    expected = (False, test_state, None)
    self.assertEqual(actual, expected)

  def test_attack_if_in_range(self):
    # arrange
    test_units = {
      (0,0): ("G", 200, 3),
      (1,0): ("E", 200, 3)
    }
    test_state = (set(), test_units)

    # act
    actual = attack(test_state, (0, 0))

    # assert
    expected_units = {
      (0,0): ("G", 200, 3),
      (1,0): ("E", 197, 3)
    }
    expected_state = (set(), expected_units)
    expected = (True, expected_state, None)
    self.assertEqual(actual, expected)

  def test_attack_kill_unit(self):
    # arrange
    test_units = {
      (0,0): ("G", 2, 3),
      (1,0): ("E", 200, 3)
    }
    test_state = (set(), test_units)

    # act
    actual = attack(test_state, (1, 0))

    # assert
    expected_units = {
      (1,0): ("E", 200, 3)
    }
    expected_state = (set(), expected_units)
    expected = (True, expected_state, (0,0))
    self.assertEqual(actual, expected)

  def test_find_all_attack_positions(self):
    # arrange
    test_map = (
      "G....\n"
      ".E.E.\n"
      ".....\n"
    )
    test_state = parse_map(test_map)

    # act
    actual = find_all_attack_positions(test_state, (0,0))

    # assert
    expected = { (1,0), (3,0), (0,1), (2,1), (4,1), (1,2), (3,2) }
    self.assertEqual(actual, expected)

  def test_find_all_attack_positions_ignore_similar(self):
    # arrange
    test_map = (
      "G....\n"
      ".G.G.\n"
      ".....\n"
    )
    test_state = parse_map(test_map)

    # act
    actual = find_all_attack_positions(test_state, (0,0))

    # assert
    expected = set()
    self.assertEqual(actual, expected)

  def test_find_all_attack_positions_ignore_occupied(self):
    # arrange
    test_map = (
      "G....\n"
      ".EGE.\n"
      ".....\n"
    )
    test_state = parse_map(test_map)

    # act
    actual = find_all_attack_positions(test_state, (0,0))

    # assert
    expected = { (1,0), (3,0), (0,1), (4,1), (1,2), (3,2) }
    self.assertEqual(actual, expected)

  def test_find_all_attack_positions_ignore_walls(self):
    # arrange
    test_map = (
      "G....\n"
      ".E#E.\n"
      ".....\n"
    )
    test_state = parse_map(test_map)

    # act
    actual = find_all_attack_positions(test_state, (0,0))

    # assert
    expected = { (1,0), (3,0), (0,1), (4,1), (1,2), (3,2) }
    self.assertEqual(actual, expected)

  def test_move_no_other_units(self):
    # arrange
    test_walls = {}
    test_units = {
      (0,0): ("E", 200, 3)
    }
    test_state = (test_walls, test_units)

    # act
    actual = move(test_state, (0,0))

    # assert
    expected = (False, test_state, (0,0))
    self.assertEqual(actual, expected)

  def test_move_ignore_similar_units(self):
    # arrange
    test_walls = {}
    test_units = {
      (0,0): ("E", 200, 3),
      (2,2): ("E", 200, 3),
    }
    test_state = (test_walls, test_units)

    # act
    actual = move(test_state, (0,0))

    # assert
    expected = (False, test_state, (0,0))
    self.assertEqual(actual, expected)

  def test_move_toward_enemy_straight_line(self):
    # arrange
    test_units = {
      (0,0): ("E", 200, 3),
      (2,0): ("G", 200, 3),
    }
    test_state = (set(), test_units)

    # act
    actual = move(test_state, (0,0))

    # assert
    expected_units = {
      (1,0): ("E", 200, 3),
      (2,0): ("G", 200, 3),
    }
    expected_state = (set(), expected_units)
    expected = (True, expected_state, (1,0))
    self.assertEqual(actual, expected)

  def test_move_toward_enemy_manhattan_distance(self):
    # arrange
    test_units = {
      (0,0): ("E", 200, 3),
      (2,2): ("G", 200, 3),
    }
    test_state = (set(), test_units)

    # act
    actual = move(test_state, (0,0))

    # assert
    expected_units = {
      (1,0): ("E", 200, 3),
      (2,2): ("G", 200, 3),
    }
    expected_state = (set(), expected_units)
    expected = (True, expected_state, (1,0))
    self.assertEqual(actual, expected)

  def test_move_toward_nearest_enemy(self):
    # arrange
    test_units = {
      (0,0): ("E", 200, 3),
      (5,1): ("G", 200, 3),
      (11,2): ("E", 200, 3),
    }
    test_state = (set(), test_units)

    # act
    actual = move(test_state, (5,1))

    # assert
    expected_units = {
      (0,0): ("E", 200, 3),
      (5,0): ("G", 200, 3),
      (11,2): ("E", 200, 3),
    }
    expected_state = (set(), expected_units)
    expected = (True, expected_state, (5,0))
    self.assertEqual(actual, expected)

  def test_move_around_wall(self):
    # arrange
    test_map = (
      "##########\n"
      "#.G#E....#\n"
      "#.##.....#\n"
      "#........#\n"
      "##########\n"
    )
    test_state = parse_map(test_map)

    # act
    (actual_did_move, actual_state, actual_new_pos) = move(test_state, (2,1))
    (_walls, actual_units) = actual_state

    # assert
    expected_goblin_position = (1,1)
    expected_elf_position = (4,1)

    self.assertTrue(expected_goblin_position in actual_units)
    self.assertTrue(actual_units[expected_goblin_position][0] == "G")

    self.assertTrue(expected_elf_position in actual_units)
    self.assertTrue(actual_units[expected_elf_position][0] == "E")

    self.assertTrue(actual_did_move)
    self.assertEqual(actual_new_pos, expected_goblin_position)

if __name__ == '__main__':
    unittest.main()
