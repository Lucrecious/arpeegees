extends Node2D

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/sword_spin_blobbo.tres') as PinAction

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.3)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['spin'])
	
	ActionUtils.add_wind_up(animation, actioner, actioner.global_position, -1)
	
	ActionUtils.add_stab(animation, actioner, target.global_position)
	
	var stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	ActionUtils.add_attack(animation, actioner, target, stats.attack)
	animation.tween_callback(VFX, 'physical_impactv', [target, target.global_position])
	
	var after_winddown := ActionUtils.add_wind_up(animation, actioner, target.global_position, -1)
	
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	ActionUtils.add_walk(animation, actioner, after_winddown, actioner.global_position, 15, 5)
	
	
	animation.tween_callback(object, callback)
