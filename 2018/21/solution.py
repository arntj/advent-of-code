import sys

r0 = int(sys.argv[1])

r1 = r2 = r3 = r4 = r5 = 0
first = True
seen = set()
prev = 0

while r5 != r0 or first:
  r3 = r5 | 65536
  r5 = 7586220
  while True:
    r1 = r3 & 255
    r5 += r1
    r5 &= 16777215
    r5 *= 65899
    r5 &= 16777215
    if r3 < 256:
      break
    
    r1 = 0
    while True:
      r4 = r1 + 1
      r4 *= 256
      if r4 > r3:
        r3 = r1
        break
      r1 += 1
  
  if first:
    print("Part 1 solution:", r5)
  elif r5 in seen:
    print("Part 2 solution:", prev)
    break

  first = False
  seen.add(r5)
  prev = r5
  