tool
extends Polygon2D

export var do_thingy = false setget set_dothingy

func _ready():
	pass

func set_dothingy(thingy):
	do_thingy = thingy
	var resulting_polygon = []
	var original_vector = Vector2(0, -1)
	for point_index in range(polygon.size()):
		resulting_polygon.append(
			original_vector.rotated((float(point_index) / float(polygon.size())) * PI * 2.0) * 32
		)
	polygon = PoolVector2Array(resulting_polygon)
