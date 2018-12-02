file = open("input.txt", "r")
lines = file.readlines()

sum = 0

for num in lines:
  sum += int(num)

print(sum)