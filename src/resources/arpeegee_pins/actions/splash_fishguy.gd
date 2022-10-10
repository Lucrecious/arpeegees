extends Node2D

signal text_triggered(translation)

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/splash_fishguy.tres')

func run(actioner: Node2D, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.5)
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_SPLASH_USE')
	
	animation.tween_callback(object, callback)
