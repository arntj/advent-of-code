from helpers import parse_node, sum_metadata

file = open("input.txt", "r")
values = [ int(i) for i in file.read().strip().split(" ")]

tree = parse_node(values)[0]

print(sum_metadata(tree))
