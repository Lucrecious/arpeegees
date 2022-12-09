extends Node2D

signal text_triggered(translation)

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/splash_fishguy.tres')

func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.5)
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_SPLASH_USE')
	
	for t in targets:
		if t.filename.get_file() != 'hunter.tscn':
			continue
		
		var gooer := NodE.get_child(t, HunterGooedUp) as HunterGooedUp
		animation.tween_callback(gooer, 'disable_goo')
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_HUNTER_CLEANED_UP_BY_FISHGUY')
	
	
	
	animation.tween_callback(object, callback)
