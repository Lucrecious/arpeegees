extends Node2D

signal text_triggered(narration_key)

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/is_this_food_koboldio.tres')

func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	var animation := create_tween()
	animation.tween_interval(0.35)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['isthisfood'])
	
	var sounds := NodE.get_child(actioner, SoundsComponent)
	animation.tween_callback(sounds, 'play', ['Break'])
	
	ActionUtils.add_text_trigger_limited(animation, self, 'NARRATOR_IS_THIS_FOOD_USE')
	
	for t in targets:
		if t.filename.get_file() != 'bard_no_mandolin.tscn':
			continue
		
		var actions := NodE.get_child(t, PinActions) as PinActions
		for action in actions.get_children():
			assert('is_this_food' in action)
			action.is_this_food = true
		break
	
	animation.tween_interval(1.0)
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	animation.tween_callback(object, callback)
