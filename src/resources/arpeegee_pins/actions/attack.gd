extends Node2D

func pin_action() -> PinAction:
	return load('res://src/resources/actions/bard_mandolin_swing.tres') as PinAction

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	var relative := ActionUtils.get_closest_adjecent_position(actioner, target)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	
	var tween := get_tree().create_tween()
	tween.tween_property(actioner, 'global_position', actioner.global_position + relative, .3)
	tween.tween_interval(.3)
	tween.tween_callback(sprite_switcher, 'change', ['attack'])
	ActionUtils.add_damage(tween, target, 5)
	tween.tween_interval(.4)
	tween.tween_callback(sprite_switcher, 'change', ['idle'])
	tween.tween_property(actioner, 'global_position', actioner.global_position, .3)
	tween.tween_callback(object, callback)
