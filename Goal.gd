extends Node2D

onready var area = $Area2D
onready var tween = $Tween 
func _ready():
	area.connect("body_entered", self, "on_body_enter")

func on_body_enter(body):
	tween.interpolate_property(body, 'modulate', body.modulate, Color.transparent, 0.5)
	tween.interpolate_property(body, 'scale', body.scale, Vector2(0.5, 0.5), 0.5)
	tween.interpolate_property(body, 'position', body.position, position, 0.5)
	tween.start()
	yield(tween, "tween_all_completed")
	body.queue_free()
