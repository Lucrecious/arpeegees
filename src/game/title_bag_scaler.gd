extends CenterContainer

func _init().():
	add_to_group('size_adapter')

var minimum_height_stretch := 720.0
var maximum_height_stretch := 1700.0

func adapt(_size: float) -> void:
	var size := get_viewport_rect().size.y
	var weight := inverse_lerp(minimum_height_stretch, maximum_height_stretch, size)
	rect_scale = Vector2.ONE * lerp(1.0, 2.0, weight)
