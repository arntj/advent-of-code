file = open("input.txt", "r")
lines = file.readlines()

twos = 0
threes = 0

for line in lines:
  counts = {}

  for ch in line:
    if ch in counts:
      counts[ch] += 1
    else:
      counts[ch] = 1

  if 2 in counts.values():
    twos += 1
  if 3 in counts.values():
    threes += 1

print(twos * threes)