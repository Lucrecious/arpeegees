extends Node

const TOTAL_UP_DOWN_SEC := 3.0

func start() -> void:
	var animation := create_tween()
	
	animation.tween_property(self, 'position:y', 7.5, TOTAL_UP_DOWN_SEC / 2.0).as_relative()\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
			
	animation.tween_property(self, 'position:y', -7.5, TOTAL_UP_DOWN_SEC / 2.0).as_relative()\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	
	animation.set_loops()
	animation.custom_step(randf() * TOTAL_UP_DOWN_SEC)
