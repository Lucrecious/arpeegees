extends Node2D

signal text_triggered(narration_key)

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/is_this_food_koboldio.tres')

func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	var animation := create_tween()
	animation.tween_interval(0.35)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['isthisfood'])
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_IS_THIS_FOOD_USE')
	
	animation.tween_interval(1.0)
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	animation.tween_callback(object, callback)
