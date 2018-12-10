from parse import parse
from util import step_has_prerequisite, distinct, has_available_workers, has_available_work

file = open("input.txt", "r")
lines = file.readlines()

# initialize workers
init_time = 60
number_of_workers = 5
worker_tasks = [ None for i in range(number_of_workers) ]
worker_timers = [ 0 for i in range(number_of_workers) ]

# parse file
instructions = []

for line in lines:
  parsed = parse("Step {step} must be finished before step {next} can begin.", line)
  instructions.append((parsed['step'], parsed['next']))

available_tasks = sorted(distinct([ i[0] for i in instructions ] + [ i[1] for i in instructions ]))

time = 0

while len(available_tasks) > 0:
  # cleanup finished tasks
  for w in range(number_of_workers):
    if worker_timers[w] == 0 and worker_tasks[w] != None:
      if worker_tasks[w] in available_tasks:
        available_tasks.remove(worker_tasks[w])
      worker_tasks[w] = None

  unfinished_tasks = sorted(available_tasks + [ s for s in worker_tasks if not s == None ])

  # find all tasks that don't have prerequisites
  ready_tasks = [ t for t in available_tasks if (not t in worker_tasks) and not any(u for u in instructions if u[1] == t and u[0] in unfinished_tasks) ]

  for t in ready_tasks:
    if not has_available_workers(worker_timers):
      break

    available_worker_index = worker_timers.index(0)
    worker_tasks[available_worker_index] = t
    worker_timers[available_worker_index] = init_time + (ord(t) - 64)
  
  # increment time
  time += 1

  # decrement worker times
  worker_timers = [ max(0, wt - 1) for wt in worker_timers ]

# calculate remaining time
time += max(worker_timers)
  
print(time - 1)
