from helpers import parse_game, play_marbles

file = open("input.txt", "r")
game_text = file.read()

(players, points) = parse_game(game_text)
result = play_marbles(players, points * 100)

print(result)
