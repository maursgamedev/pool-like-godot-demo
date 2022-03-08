extends Polygon2D


func _ready():
	pass # Replace with function body.

func fade_in():
	if $Tween.is_active() || modulate == Color.white:
		return
	$Tween.interpolate_property(self, 'modulate', Color.transparent, Color.white, 0.3)
	$Tween.start()
	
func fade_out():
	if $Tween.is_active() || modulate == Color.transparent:
		return
	$Tween.interpolate_property(self, 'modulate', Color.white, Color.transparent, 0.1)
	$Tween.start()
