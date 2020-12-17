extends Object

class_name GroupHelper

static func is_in_any_group(node : Node, groups : Array) -> bool:
	if groups.size() <= 0:
		return false
	for group in groups:
		if node.is_in_group(group):
			return true
	return false