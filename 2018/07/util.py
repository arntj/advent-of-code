def step_has_prerequisite(step, instructions):
  return any(True for i in instructions if i[1] == step)

def distinct(iterable):
  return list(set(iterable))

def has_available_workers(worker_timers):
  return any(True for w in worker_timers if w == 0)

def has_available_work(start_steps, worker_tasks):
  return any(True for s in start_steps if s not in worker_tasks)
