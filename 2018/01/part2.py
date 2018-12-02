file = open("input.txt", "r")
numbers = file.readlines()

frequencies = []
count = 0
currFreq = 0

while True:
  if currFreq in frequencies:
    break

  frequencies.append(currFreq)

  index = count % len(numbers)
  val = int(numbers[index])
  currFreq += val
  count += 1

print(currFreq)