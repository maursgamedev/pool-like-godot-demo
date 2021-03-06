extends KinematicBody2D

export var character_radius := 32.0
export var max_drag_distance := 64.0
export var selection_radius := 10.0
export var original_restoration_time := 0.05
export var starting_speed := 30.0

var mouse_was_pressed := false
var mouse_is_pressed := false
var mouse_is_inside := false
var is_dragging := false
var mouse_position := Vector2()
var start_drag_position := Vector2()

var original_polygon := PoolVector2Array([])
var deformation_vector := Vector2()
var restoration_timer := 0.0
var friction := 0.1
var current_velocity := Vector2()
var bounciness := 1.0
var mass := 1.0
var release_global_position := Vector2()

onready var border := $Border
onready var camera := $Camera2D

func _ready():
	input_pickable = true
	connect('mouse_entered', self, 'set_mouse_is_inside', [true])
	connect('mouse_exited', self, 'set_mouse_is_inside', [false])
	original_polygon = border.polygon

func set_mouse_is_inside(inside):
	print('mouse_is_inside')
	print(inside)
	mouse_is_inside = inside

func _unhandled_input(event):
	if event is InputEventMouseButton:
		mouse_is_pressed = event.pressed

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
		var collider := collision.get_collider()
		if collider.has_method('resolve_collision'):
			resolve_collision(collider)
		else:
			current_velocity = current_velocity.bounce(collision.normal)
		if collider is KinematicBody:
			current_velocity = current_velocity.normalized() * clamp(current_velocity.length() + 10.0, 0.0, INF)
	else:
		current_velocity = current_velocity.normalized() * clamp(current_velocity.length() - friction, 0.0, INF)


func resolve_collision(collider):
	var relative_velocity : Vector2 = collider.current_velocity - current_velocity
	var velocity_along_normal := relative_velocity.dot(current_velocity.normalized())
	
	if velocity_along_normal > 0:
		return
	
	var resolution = min(bounciness, collider.bounciness)
	var impulse_escalar : float = - (1 + resolution) * velocity_along_normal
	impulse_escalar = impulse_escalar / (1 / mass + 1 / collider.mass)

	var impulse : Vector2 = current_velocity.normalized() * impulse_escalar
	current_velocity -= 1.0 / mass * impulse
	collider.current_velocity += 1.0 / collider.mass * impulse
		
func _process(delta):
	if mouse_is_inside && mouse_is_pressed && !mouse_was_pressed:
		start_drag_position = mouse_position
		is_dragging = true
	# if start_drag_position.distance_to(mouse_position) < max_drag_distance && :
	if mouse_is_pressed && mouse_was_pressed && is_dragging:
		deformation_vector = -(start_drag_position - mouse_position).clamped(max_drag_distance)
		border.polygon = deformed_polygon(deformation_vector)
	if mouse_was_pressed && !mouse_is_pressed && is_dragging:
		current_velocity = (-deformation_vector / max_drag_distance) * starting_speed
		restoration_timer = original_restoration_time
		is_dragging = false
	if restoration_timer > -0.01 && !is_dragging:
		border.polygon = deformed_polygon(
			deformation_vector * (restoration_timer / original_restoration_time)
		)
		restoration_timer -= delta
	mouse_was_pressed = mouse_is_pressed
