from helpers import parse_node, calculate_node_value

file = open("input.txt", "r")
values = [ int(i) for i in file.read().strip().split(" ")]

tree = parse_node(values)[0]

print(calculate_node_value(tree))
