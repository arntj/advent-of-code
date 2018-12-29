import sys
from re import compile
from json import dumps
from enum import Enum
from math import ceil

if len(sys.argv) < 2:
  print("Please give file name as argument")
  quit()

filename = sys.argv[1]

with open(filename, "r", encoding="UTF-8") as file:
  lines = [ l.strip() for l in file.readlines() ]

class Faction(Enum):
  ImmuneSystem = 0
  Infection = 1

class Group:
  id = 0
  faction = Faction.ImmuneSystem
  initial_units = 0
  units = 0
  hitpoints = 0
  weaknesses = tuple()
  immunities = tuple()
  attack = 0
  attack_type = ""
  initiative = 0
  boost = 0

  def effective_power(self):
    return self.units * (self.attack + self.boost)

  def calculate_attack_damage(self, attacker):
    if attacker.attack_type in self.immunities:
      return 0
    elif attacker.attack_type in self.weaknesses:
      return 2 * attacker.effective_power()
    else:
      return attacker.effective_power()

  def was_attacked(self, attacker):
    damage = self.calculate_attack_damage(attacker)
    total_hitpoints = self.hitpoints * self.units
    self.units = max(0, ceil((total_hitpoints - damage) / self.hitpoints))

  def __hash__(self):
    return hash(
      (
        self.id,
        self.faction
      )
    )

groups = []
group_id = 1
is_infection = False
unit_regex = compile(r"(\d+) units each with (\d+) hit points .*with an attack that does (\d+) (.*) damage at initiative (\d+)")
weaknesses_regex = compile(r"weak to ([^\);]+)")
immunity_regex = compile(r"immune to ([^\);]+)")

for line in lines:
  if line == "Infection:":
    is_infection = True
    group_id = 1
    continue

  match = unit_regex.match(line)

  if match == None:
    continue

  match_groups = match.groups()

  group = Group()
  group.id = group_id
  group.faction = Faction.Infection if is_infection else Faction.ImmuneSystem
  group.initial_units = int(match_groups[0])
  group.hitpoints = int(match_groups[1])
  group.attack = int(match_groups[2])
  group.attack_type = match_groups[3]
  group.initiative = int(match_groups[4])

  immunity_match = immunity_regex.search(line)
  weaknesses_match = weaknesses_regex.search(line)

  if immunity_match != None:
    group.immunities = tuple(immunity_match.groups()[0].split(", "))

  if weaknesses_match != None:
    group.weaknesses = tuple(weaknesses_match.groups()[0].split(", "))

  groups.append(group)
  group_id += 1

def calculate_score(groups:list):
  return sum(iter(( g.units for g in groups )))

def fight(groups:list, boost:int = 0):
  curr_groups = groups.copy()

  for g in curr_groups:
    g.units = g.initial_units
    
    if g.faction == Faction.ImmuneSystem:
      g.boost = boost

  prev_points = calculate_score(curr_groups)

  while len(list(( g for g in curr_groups if g.faction == Faction.ImmuneSystem ))) > 0 \
        and len(list(( g for g in curr_groups if g.faction == Faction.Infection ))) > 0:  
    fights = dict()
    sorted_groups = sorted(curr_groups, key = lambda g:(g.effective_power(),g.initiative), reverse = True)

    for attacker in sorted_groups:
      target = next(iter(sorted((g for g in curr_groups if g.faction != attacker.faction and g.calculate_attack_damage(attacker) > 0 and g not in fights.values()),
        key = lambda g:(g.calculate_attack_damage(attacker), g.effective_power(), g.initiative),
        reverse = True )), None)

      if target != None:
        fights[attacker] = target

    for pair in sorted(fights.items(), key=lambda p:p[0].initiative, reverse=True):
      (attacker, target) = pair
      target.was_attacked(attacker)
      if target.units == 0:
        curr_groups.remove(target)

    curr_points = calculate_score(curr_groups)
    if curr_points == prev_points:
      # draw
      break
    prev_points = curr_points
  
  result = calculate_score(curr_groups)
  immune_won = not any(( g for g in curr_groups if g.faction == Faction.Infection ))

  return (result, immune_won)

part_1_result, _immune_won = fight(groups)

print("Part 1 result is:", part_1_result)

curr_boost = 1
result = 0
immune_won = False

while not immune_won:
  (result, immune_won) = fight(groups, curr_boost)
  curr_boost += 1

print("Part 2 result is:", result)
