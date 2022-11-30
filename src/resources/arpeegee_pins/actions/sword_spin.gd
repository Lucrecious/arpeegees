extends Node2D

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/sword_spin_blobbo.tres') as PinAction

func run(actioner: Node2D, target: ArpeegeePinNode, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.3)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['spin'])
	
	var target_position := ActionUtils.get_closest_adjecent_position(actioner, target) + actioner.global_position
	
	ActionUtils.add_wind_up(animation, actioner, actioner.global_position, -1)
	
	ActionUtils.add_stab(animation, actioner, target_position)
	
	if target.filename.get_file() == 'paladin_no_sword.tscn' and randf() < 0.1:
		var paladin_root_sprite := Components.root_sprite(target)
		
		animation.tween_callback(sprite_switcher, 'change', ['stuckswordpaladin'])
		animation.tween_callback(paladin_root_sprite, 'set', ['visible', false])
		
		animation.tween_interval(0.5)

		var blobbo_transformer := NodE.get_child(actioner, Transformer) as Transformer
		blobbo_transformer.transform_scene = load('res://src/resources/arpeegee_pins/blobbo.tscn')

		var paladin_transformer := NodE.get_child(target, Transformer) as Transformer
		paladin_transformer.transform_scene = load('res://src/resources/arpeegee_pins/paladin.tscn')

		animation.tween_callback(blobbo_transformer, 'request_transform')
		animation.tween_callback(paladin_transformer, 'request_transform')

		var paladin_sprite_switcher := NodE.get_child(target, SpriteSwitcher) as SpriteSwitcher
		animation.tween_callback(paladin_sprite_switcher, 'change', ['idlesword'])
		animation.tween_callback(paladin_root_sprite, 'set', ['visible', true])
		animation.tween_callback(sprite_switcher, 'change', ['idlenosword'])
		
		ActionUtils.add_walk(animation, actioner, target_position, actioner.global_position, 15, 5)
	else:
		var stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
		ActionUtils.add_attack(animation, actioner, target, stats.attack)
		animation.tween_callback(VFX, 'physical_impactv', [target, target.global_position])
		
		var after_winddown := ActionUtils.add_wind_up(animation, actioner, target.global_position, -1)
		
		animation.tween_callback(sprite_switcher, 'change', ['idle'])
		
		ActionUtils.add_walk(animation, actioner, after_winddown, actioner.global_position, 15, 5)
	
	
	animation.tween_callback(object, callback)
