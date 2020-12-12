extends KinematicBody2D

export var character_radius := 32.0
export var max_drag_distance := 64.0
export var selection_radius := 10.0
export var original_restoration_time := 0.05
export var starting_speed := 30.0

var mouse_was_pressed := false
var mouse_is_pressed := false
var mouse_position := Vector2()
var start_drag_position := Vector2()

var original_polygon := PoolVector2Array([])
var deformation_vector := Vector2()
var restoration_timer := 0.0
var friction := 0.1
var current_velocity := Vector2()
var release_global_position := Vector2()

onready var border := $Border

func _ready():
	original_polygon = border.polygon

func _unhandled_input(event):
	if event is InputEventMouseButton:
		mouse_is_pressed = event.pressed
		if event.pressed:
			start_drag_position = event.position
		else:
			restoration_timer = original_restoration_time

	if event is InputEventMouseMotion:
		mouse_position = event.position

func deformed_polygon(drag_vector: Vector2) -> PoolVector2Array:
	var result := PoolVector2Array()
	for point in original_polygon:
		if point.distance_to(drag_vector.normalized() * character_radius) < selection_radius:
			result.append(point + drag_vector/2)
		else:
			result.append(point)
	return result

func _physics_process(_delta):
	var collision := move_and_collide(current_velocity)
	if collision != null:
		current_velocity = current_velocity.bounce(collision.normal)
	if collision != null && collision.get_collider() is KinematicBody:
		current_velocity = current_velocity.normalized() * clamp(current_velocity.length() + 10.0, 0.0, INF)
	else:
		current_velocity = current_velocity.normalized() * clamp(current_velocity.length() - friction, 0.0, INF)

func _process(delta):
	if global_position.distance_to(start_drag_position) < character_radius:
		if mouse_is_pressed:
			deformation_vector = -(global_position - mouse_position).clamped(max_drag_distance)
			border.polygon = deformed_polygon(deformation_vector)
		if mouse_was_pressed && !mouse_is_pressed:
			current_velocity = (-deformation_vector / max_drag_distance) * starting_speed
			release_global_position = global_position
	if restoration_timer > -0.01 && release_global_position.distance_to(start_drag_position) < character_radius:
		border.polygon = deformed_polygon(
			deformation_vector * (restoration_timer / original_restoration_time)
		)
		restoration_timer -= delta
	mouse_was_pressed = mouse_is_pressed
