extends Node

var current_velocity := Vector2()
var friction := 0.1
var bounciness := 1.0
var mass := 0.5

onready var target : KinematicBody2D = get_parent()

func _physics_process(_delta):
	var collision := target.move_and_collide(current_velocity)
	if collision != null:
		var collider := collision.get_collider()
		if collider.is_in_group('collidable_behavior'):
			resolve_collision(collider.get_node('Collidable'))
		else:
			current_velocity = current_velocity.bounce(collision.normal)
	current_velocity = current_velocity.normalized() * clamp(current_velocity.length() - friction, 0.0, INF)

func resolve_collision(collider : Node):
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

func _ready():
	assert(target is KinematicBody2D)
	target.add_to_group('collidable_behavior')


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
