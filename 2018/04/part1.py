from parse import parse
from datetime import timedelta
import calendar

file = open("input.txt", "r")
lines = file.readlines()

guards = {}
events = []

for x in [ parse("[{time:ti}] {event}", x) for x in lines ]:
  time = x['time']
  event = x['event']

  if event.startswith('Guard'):
    id = parse("Guard #{:d} begins shift", event)[0]
    if id not in guards:
      guards[id] = {}

    start = (time + timedelta(hours=1)).date()
    guards[id][start] = []
  else:
    events.append((event, time))

events = sorted(events, key=lambda event: event[1])
sleeps = []

for i in range(0, len(events), 2):
  sleeps.append((events[i][1], events[i + 1][1]))

for sleep in sleeps:
  date = sleep[0].date()
  guard = next(g for g in guards.values() if date in g)
  guard[date].append(sleep)

def sum_guard_sleep(guard_id):
  guard = guards[guard_id]
  time_asleep = 0
  
  for shift in guard.values():
    for sleep in shift:
      start = calendar.timegm(sleep[0].timetuple())
      end = calendar.timegm(sleep[1].timetuple())

      time_asleep += (end - start) // 60
  
  return time_asleep

sleepy_guard_id = sorted(guards, key=sum_guard_sleep)[-1]
sleepy_guard = guards[sleepy_guard_id]

max_sleeps = 0
max_sleeps_minute = -1
sleeps = [y for x in sleepy_guard.values() for y in x]

for m in range(60):
  count_sleep = 0

  for sleep in sleeps:
    start = sleep[0]
    end = sleep[1]

    if start.timetuple()[4] <= m and end.timetuple()[4] > m:
      count_sleep += 1

  if count_sleep > max_sleeps:
    max_sleeps = count_sleep
    max_sleeps_minute = m

print(sleepy_guard_id * max_sleeps_minute)
