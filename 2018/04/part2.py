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

number_of_sleeps = 0
sleepiest_guard_id = 0
sleepiest_minute = 0

for minute in range(60):
  for guard_id in guards:
    guard = guards[guard_id]
    guard_sleeps = [y for x in guard.values() for y in x]
    sleeps_for_guard = 0
    for sleep in guard_sleeps:
      start = sleep[0]
      end = sleep[1]

      if start.timetuple()[4] <= minute and end.timetuple()[4] > minute:
        sleeps_for_guard += 1

    if sleeps_for_guard > number_of_sleeps:
      number_of_sleeps = sleeps_for_guard
      sleepiest_guard_id = guard_id
      sleepiest_minute = minute

print(sleepiest_guard_id * sleepiest_minute)
