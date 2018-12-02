file = open("input.txt", "r")
lines = file.read().splitlines()

for line in lines:
  for match in lines:
    if line == match:
      continue
    
    result = ""

    for i in range(len(line)):
      if line[i] == match[i]:
        result += line[i]

    if len(result) == (len(line) - 1):
      print(result)
      quit()
