file = open("input.txt", "r")
numbers = [ int(x) for x in file.read().splitlines() ]

frequencies = set()
index = 0
currFreq = 0

while currFreq not in frequencies:
  frequencies.add(currFreq)

  if index == len(numbers):
    index = 0
  
  currFreq += numbers[index]
  index += 1

print(currFreq)