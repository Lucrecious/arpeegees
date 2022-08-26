extends Sprite

func start() -> void:
	visible = true
	
	var animation := create_tween()
	animation.set_loops()
	
	var start_scale := scale
	var end_scale := scale * 1.5
	animation.tween_property(self, 'scale', start_scale, 1.0)\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	animation.tween_property(self, 'scale', end_scale, 1.0)\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	
	
	
