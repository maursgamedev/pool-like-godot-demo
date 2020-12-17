extends Node

export var character_radius := 32.0
export var max_drag_distance := 64.0
export var selection_radius := 10.0
export var original_restoration_time := 0.05
export var starting_speed := 30.0
export var preview_frequency := 0.1

var mouse_was_pressed := false
var mouse_is_pressed := false
var mouse_is_inside := false
var is_dragging := false
var mouse_position := Vector2()
var start_drag_position := Vector2()

var original_polygon := PoolVector2Array([])
var deformation_vector := Vector2()
var restoration_timer := 0.0
var release_global_position := Vector2()
var current_preview_cooldown := preview_frequency
var preview_nodes := []
var source_node_group := 'draggable'
var preview_template = preload('res://TemplateScenes/CollisionPreview.tscn')

onready var border := $'../Border'
onready var camera := $'../Camera2D'
onready var target : KinematicBody2D = get_parent()
onready var collidable : Node = target.get_node('Collidable')


func _ready():
	source_node_group += '_' + String(IdGenerator.get_next_id('draggable'))
	target.input_pickable = true
	target.add_to_group(source_node_group)
	target.connect('mouse_entered', self, 'set_mouse_is_inside', [true])
	target.connect('mouse_exited', self, 'set_mouse_is_inside', [false])
	original_polygon = border.polygon

func set_mouse_is_inside(inside):
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

func _process(delta):
	if mouse_is_inside && mouse_is_pressed && !mouse_was_pressed:
		start_drag_position = mouse_position
		is_dragging = true
	if mouse_is_pressed && mouse_was_pressed && is_dragging:
		deformation_vector = -(start_drag_position - mouse_position).clamped(max_drag_distance)
		border.polygon = deformed_polygon(deformation_vector)
		produce_preview(delta, (-deformation_vector.normalized()) * (starting_speed / 3) )
	if mouse_was_pressed && !mouse_is_pressed && is_dragging:
		collidable.current_velocity = (-deformation_vector / max_drag_distance) * starting_speed
		restoration_timer = original_restoration_time
		is_dragging = false
		remove_all_preview_nodes()
	if restoration_timer > -0.01 && !is_dragging:
		border.polygon = deformed_polygon(
			deformation_vector * (restoration_timer / original_restoration_time)
		)
		restoration_timer -= delta
	mouse_was_pressed = mouse_is_pressed


func produce_preview(delta, preview_speed):
	current_preview_cooldown -= delta
	if current_preview_cooldown < 0.0:
		current_preview_cooldown = preview_frequency
		# prepare
		var preview_node = preview_template.instance()
		preview_node.position = preview_speed.normalized() * (character_radius *1.5)
		preview_node.get_node("Collidable").current_velocity = preview_speed
		preview_node.get_node("Collidable").ignore_groups.append(source_node_group)
		# add to scene
		target.add_child(preview_node)
		preview_nodes.append(preview_node)

func remove_all_preview_nodes():
	for node in preview_nodes:
		if node:
			node.queue_free()
	preview_nodes = []
