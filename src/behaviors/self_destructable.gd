extends Node

export var destruct_in_seconds := 3.0

onready var target : Node = get_parent()

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	destruct_in_seconds -= delta
	if destruct_in_seconds < 0.0:
		target.queue_free()
