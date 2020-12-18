extends Node

export var original_fadeout_time := 1.0
var fadeout_time := original_fadeout_time

onready var target : Node2D = get_parent()

func _ready():
	pass # Replace with function body.


func _process(delta):
	fadeout_time -= delta
	if fadeout_time > 0.0:
		target.modulate = Color(1.0,1.0,1.0, fadeout_time / original_fadeout_time)
