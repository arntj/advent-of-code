from parse import parse
from util import step_has_prerequisite, distinct

file = open("input.txt", "r")
lines = file.readlines()

# parse file
instructions = []

for line in lines:
  parsed = parse("Step {step} must be finished before step {next} can begin.", line)
  instructions.append((parsed['step'], parsed['next']))

completed = []

while len(instructions) > 0:
  # find all steps that don't have prerequisites
  start_steps = list(map(lambda i: i[0], [ i for i in instructions if not step_has_prerequisite(i[0], instructions)]))
  start_steps.sort()

  # find the first in alphabetic order
  start = next(s for s in start_steps)

  # remove instructions that start with this step
  remaining_instructions = [ i for i in instructions if i[0] != start]

  instructions = remaining_instructions
  completed.append(start)

  if len(instructions) == 1:
    completed.append(instructions[0][0])
    completed.append(instructions[0][1])
    instructions = []

print("".join(completed))
