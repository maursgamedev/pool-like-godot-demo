extends Area2D

func _ready():
	connect('body_entered', self, 'apply_friction_modifier')
	connect('body_exited', self, 'remove_friction_modifier')

func apply_friction_modifier(body:Node):
	if body.is_in_group('collidable_behavior'):
		var collidable = body.get_node('Collidable')
		collidable.friction = collidable.friction * 0.1


func remove_friction_modifier(body:Node):
	if body.is_in_group('collidable_behavior'):
		var collidable = body.get_node('Collidable')
		collidable.friction = collidable.friction * 10

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
