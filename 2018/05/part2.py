from retractPolymer import fullyRetractPolymer
from string import ascii_lowercase

file = open("input.txt", "r")
input_polymer = file.read().strip()
retracted_polymer = fullyRetractPolymer(input_polymer)

best = -1
best_letter = ""

for letter in ascii_lowercase:
  polymer = fullyRetractPolymer([ x for x in retracted_polymer if x.upper() != letter.upper()])  

  if best == -1 or len(polymer) < best:
    best = len(polymer)
    best_letter = letter

print(best)
