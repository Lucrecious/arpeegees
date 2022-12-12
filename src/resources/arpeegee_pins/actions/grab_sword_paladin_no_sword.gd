extends Node2D

signal text_triggered(narration_key)

func is_blocked() -> bool:
	var blobbo_sword_group := get_tree().get_nodes_in_group('blobbo_sword')
	if blobbo_sword_group.empty():
		return true
	
	var blobbo_sword := blobbo_sword_group[0] as ArpeegeePinNode
	var health := NodE.get_child(blobbo_sword, Health) as Health
	return health.current <= 0

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/grab_sword_paladin_no_sword.tres')

func run(actioner: ArpeegeePinNode, object: Object, callback: String) -> void:
	var blobbo_sword_group := get_tree().get_nodes_in_group('blobbo_sword')
	
	var target := blobbo_sword_group[0] as ArpeegeePinNode
	
	var animation := create_tween()
	
	animation.tween_interval(0.3)
	
	var target_relative := ActionUtils.get_closest_adjecent_position(actioner, target)
	var side := sign(target_relative.x)
	var target_position := actioner.global_position + target_relative
	ActionUtils.add_walk(animation, actioner, actioner.global_position, target_position, 15, 5)
	
	ActionUtils.add_wind_up(animation, actioner, target_position, side)
	
	ActionUtils.add_stab(animation, actioner, target_position)
	
	var root_sprite := Components.root_sprite(actioner)
	animation.tween_callback(root_sprite, 'set', ['visible', false])
	
	var blobbo_sprite_switcher := NodE.get_child(target, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(blobbo_sprite_switcher, 'change', ['stuckswordpaladin'])
	
	animation.tween_interval(0.5)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	
	var probability := randf()
	Logger.info('roll to take out sword (must be less than 0.25 to succeed): %f' % probability)
	var succeed := probability < 0.25
	if succeed:
		var hurt_sword := blobbo_sprite_switcher.sprite('hurt')
		var hurt_no_sword := blobbo_sprite_switcher.sprite('hurtnosword')
		hurt_sword.name = 'Hurt_'
		hurt_no_sword.name = 'Hurt'
		
		var hard_coded_paladin_regular_attack := 3
		animation.tween_callback(sprite_switcher, 'change', ['idlesword'])
		animation.tween_callback(root_sprite, 'set', ['visible', true])
		
		ActionUtils.add_attack_no_evade(animation, actioner, target, hard_coded_paladin_regular_attack * 3.0)
		
		var sounds := NodE.get_child(actioner, SoundsComponent)
		animation.tween_callback(sounds, 'play', ['GooeyHit'])
		
		var paladin_transformer := NodE.get_child(actioner, Transformer) as Transformer
		paladin_transformer.transform_scene = load('res://src/resources/arpeegee_pins/paladin.tscn')
		
		var blobbo_transformer := NodE.get_child(target, Transformer) as Transformer
		blobbo_transformer.transform_scene = load('res://src/resources/arpeegee_pins/blobbo.tscn')
		
		animation.tween_callback(paladin_transformer, 'request_transform')
		animation.tween_callback(blobbo_transformer, 'request_transform')
	else:
		animation.tween_callback(sprite_switcher, 'change', ['idle'])
		animation.tween_callback(root_sprite, 'set', ['visible', true])
		
		animation.tween_callback(blobbo_sprite_switcher, 'change', ['idle'])
	
	ActionUtils.add_walk(animation, actioner, target_position, actioner.global_position, 15, 5)
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_SWORD_IN_THE_GOO_USE')
	if succeed:
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_SWORD_IN_THE_GOO_USE_SUCCEED')
	else:
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_SWORD_IN_THE_GOO_USE_FAIL')
	
	animation.tween_callback(object, callback)
