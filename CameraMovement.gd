extends Camera2D

export(int) var camera_speed := 300
var zoom_levels := [0.25, 0.5, 0.75, 1, 2, 3]
var current_zoom_level : int = 3


# Called when the node enters the scene tree for the first time.
func _ready():
	$'../Draggable'.connect("drag_release", self, 'reset_offset')
	update_zoom()

func _process(delta):
	var direction := Vector2()
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed('ui_down'):
		direction.y += 1
	if Input.is_action_pressed('ui_left'):
		direction.x -= 1
	if Input.is_action_pressed('ui_right'):
		direction.x += 1
	global_position += ( direction * camera_speed * delta )
	global_position.x = clamp(global_position.x, 0, 10000000)
	global_position.y = clamp(global_position.y, 0, 10000000)

func _unhandled_input(event):
	if event.is_action_pressed('game_zoom_in'):
		zoom_in()
	if event.is_action_pressed('game_zoom_out'):
		zoom_out()

func zoom_in():
	current_zoom_level = clamp(current_zoom_level - 1, 0, zoom_levels.size() - 1)
	update_zoom()

func zoom_out():
	current_zoom_level = clamp(current_zoom_level + 1, 0, zoom_levels.size() - 1)
	update_zoom()

func update_zoom():
	reset_offset()
	$Tween.stop(self, 'zoom')
	$Tween.interpolate_property(self, 'zoom', zoom, Vector2(1,1) * zoom_levels[current_zoom_level], 0.3)
	$Tween.start()

func reset_offset():
	$Tween.interpolate_property(
		self, 'position', position, 
		Vector2(), 0.6, Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	$Tween.start() 
