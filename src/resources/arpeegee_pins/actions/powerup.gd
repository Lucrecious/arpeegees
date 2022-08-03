extends Node2D

func pin_action() -> PinAction:
	return load('res://src/resources/actions/monk_powerup.tres') as PinAction

func run(actioner: Node2D, object: Object, callback: String) -> void:
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	
	var tween := get_tree().create_tween()
	tween.tween_callback(sprite_switcher, 'change', ['powerup'])
	ActionUtils.add_status_effect(tween, actioner, 'focus_ki_aura')
	tween.tween_interval(1.3)
	tween.tween_callback(sprite_switcher, 'change', ['idle'])
	tween.tween_callback(object, callback)
