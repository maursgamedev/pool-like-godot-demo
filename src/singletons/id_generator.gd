extends Node

var groups := {}

func get_next_id(group:String) -> int:
	if !groups.has(group):
		groups[group] = 0
	groups[group] += 1
	return groups[group]
	