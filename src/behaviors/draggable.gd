extends Node

export var character_radius := 32.0
export var max_drag_distance := 64.0
export var selection_radius := 10.0
export var original_restoration_time := 0.05
export var starting_speed := 20.0
export var preview_frequency := 0.1
export var angle_change_cooldown_template := 0.2
export var preview_points : int = 10

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
var last_preview_angle = null
var source_node_group := 'draggable'
var preview_template := preload('res://TemplateScenes/CollisionPreview.tscn')
var preview_pellet_template := preload('res://TemplateScenes/PreviewPellet.tscn')
var preview_tracer := preview_template.instance()
var tracer_collidable := preview_tracer.get_node('Collidable')
onready var border := $'../Border'
onready var target : KinematicBody2D = get_parent()
onready var collidable : Node = target.get_node('Collidable')
onready var preview_holder : Node2D = $'../Preview'

signal drag_release
signal drag_start

func _ready():
	source_node_group += '_' + String(IdGenerator.get_next_id('draggable'))
	target.input_pickable = true
	target.add_to_group(source_node_group)
	target.connect('mouse_entered', self, 'set_mouse_is_inside', [true])
	target.connect('mouse_exited', self, 'set_mouse_is_inside', [false])
	original_polygon = border.polygon
	#
	preview_holder.hide()
	border.show()
	
	for point in range(preview_points):
		var pellet := preview_pellet_template.instance()
		pellet.modulate = Color(1.0,1.0,1.0, 1 - float(point)/float(preview_points) )
		preview_holder.add_child(pellet)

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
	if collidable.current_velocity.length() <= 0.04:
		border.fade_in()
	else:
		border.fade_out()
	if _is_starting_dragging():
		start_drag_position = mouse_position
		is_dragging = true
		emit_signal("drag_start")
	if mouse_is_pressed && mouse_was_pressed && is_dragging:
		deformation_vector = -(start_drag_position - mouse_position).clamped(max_drag_distance)
		border.polygon = deformed_polygon(deformation_vector)
		update_preview((-deformation_vector / max_drag_distance) * starting_speed)
	if mouse_was_pressed && !mouse_is_pressed && is_dragging:
		collidable.current_velocity = (-deformation_vector / max_drag_distance) * starting_speed
		restoration_timer = original_restoration_time
		is_dragging = false
		preview_holder.hide()
		emit_signal("drag_release")
	if restoration_timer > -0.01 && !is_dragging:
		border.polygon = deformed_polygon(
			deformation_vector * (restoration_timer / original_restoration_time)
		)
		restoration_timer -= delta
	mouse_was_pressed = mouse_is_pressed


func update_preview(preview_angle : Vector2):
	preview_holder.show()
	if preview_angle != last_preview_angle:
		target.add_child(preview_tracer)
		preview_tracer.position = Vector2()
		tracer_collidable.current_velocity = preview_angle.normalized() * 50.0
		#
		tracer_collidable.physics_step(0.0)
		#
		for pellet in preview_holder.get_children():
			pellet.position = preview_tracer.position
			tracer_collidable.physics_step(0.0)
		target.remove_child(preview_tracer)
	last_preview_angle = preview_angle

func _is_starting_dragging():
	return mouse_is_inside && mouse_is_pressed && !mouse_was_pressed && collidable.current_velocity.length() <= 0.04
