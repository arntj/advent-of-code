def retractPolymer(polymer):
  nextPolymer = []
  prev = polymer[0]
  i = 1

  while i < len(polymer):
    p = polymer[i]
    prev = polymer[i - 1]

    if prev != p and prev.upper() == p.upper():
      i += 1
    else:
      nextPolymer.append(prev)

    if i == len(polymer) - 1:
      nextPolymer.append(p)

    i += 1

  return nextPolymer

def fullyRetractPolymer(polymer):
  nextPolymer = polymer
  currPolymer = []

  while len(nextPolymer) > 0 and len(nextPolymer) != len(currPolymer):
    currPolymer = nextPolymer
    nextPolymer = retractPolymer(currPolymer)

  return nextPolymer
