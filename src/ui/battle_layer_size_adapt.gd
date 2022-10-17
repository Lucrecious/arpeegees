extends MarginContainer


export(int) var width_limit := 1280
export(int) var max_width_limit := 1920
export(float) var move_up_factor := 0.25
export(float) var original_y := 0

func _init() -> void:
	add_to_group('size_adapter')

func adapt(size: float) -> void:
	if size < width_limit:
		rect_position.y = original_y
	elif size < max_width_limit:
		var delta := size - width_limit
		rect_position.y = original_y - (delta * move_up_factor)
	else:
		rect_position.y = original_y - ((max_width_limit - width_limit) * move_up_factor)
