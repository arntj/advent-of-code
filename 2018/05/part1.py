from retractPolymer import fullyRetractPolymer

file = open("input.txt", "r")
polymer = file.read().strip()

print(len(fullyRetractPolymer(polymer)))
