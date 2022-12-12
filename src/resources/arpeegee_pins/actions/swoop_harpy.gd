extends Node2D

signal text_triggered(translation_key)

func pin_action() -> PinAction:
	return load('res://src/resources/actions/swoop_harpy.tres') as PinAction

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	var relative := ActionUtils.get_closest_adjecent_position(actioner, target)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	var sounds := NodE.get_child(actioner, SoundsComponent) as SoundsComponent
	
	var divehead_sprite := sprite_switcher.sprite('divehead')
	assert(divehead_sprite)
	
	var squisher := NodE.get_child(actioner, Squisher) as Squisher
	
	var tween := get_tree().create_tween()
	
	tween.tween_callback(sounds, 'play', ['Squish'])
	
	tween.tween_property(squisher, 'height_factor', .3, .5)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	
	tween.parallel().tween_property(squisher, 'squish_factor', .5, .5)
	tween.tween_interval(.5)
	tween.tween_callback(sounds, 'play', ['Ascend'])
	tween.tween_callback(sprite_switcher, 'change', ['diveup'])
	tween.tween_property(squisher, 'height_factor', 1.7, .2)
	
	tween.tween_property(actioner, 'global_position', actioner.global_position + Vector2.UP * 1000.0, 0.3)
	
	tween.tween_callback(squisher, 'set', ['height_factor', 1.0])
	tween.tween_callback(squisher, 'set', ['squish_factor', 1.0])
	tween.tween_callback(sprite_switcher, 'change', ['diveclaws'])
	tween.tween_interval(.7)
	
	tween.tween_callback(sounds, 'play', ['Descend'])
	var actioner_position := actioner.global_position + relative + Vector2.UP * 50.0
	tween.tween_property(actioner, 'global_position', actioner_position, .2)
	
	tween.tween_callback(sounds, 'play', ['ScoopAttach'])
	
	var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	var is_evading := FairRandom.is_evading(modified_stats.evasion)
	
	var attacked := false
	
	if is_evading:
		ActionUtils.add_miss(tween, target)
		tween.tween_interval(0.5)
	else:
		tween.tween_interval(0.5)
		
		actioner_position += Vector2.UP * 300.0
		
		tween.tween_callback(sounds, 'play', ['Scoop'])
		tween.tween_property(actioner, 'global_position', actioner_position, 0.5)\
				.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(target, 'global_position', target.global_position + Vector2.UP * 300.0, 0.5)\
				.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		
		tween.tween_interval(1.0)
		
		tween.tween_property(target, 'global_position', target.global_position, 0.2)\
				.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
		
		tween.tween_callback(sounds, 'play', ['Drop'])
		
		if modified_stats:
			var attack_amount := ActionUtils.damage_with_factor(modified_stats.attack, 0.5)
			ActionUtils.add_attack_no_evade(tween, actioner, target, attack_amount)
			attacked = true
		else:
			assert(false)
		
		tween.tween_interval(.5)
	
	ActionUtils.add_text_trigger(tween, self, 'NARRATOR_SWOOP_USE')
	
	tween.tween_callback(sprite_switcher, 'change', ['idle'])
	tween.tween_property(actioner, 'global_position', actioner.global_position, .3)
	
	if attacked and randf() < 0.25:
		var list := NodE.get_child(actioner, StatusEffectsList) as StatusEffectsList
		tween.tween_callback(list, 'add_instance', [_create_status_effect()])
		tween.tween_callback(Sounds, 'play', ['BuffAttackCry'])
	
	tween.tween_callback(object, callback)

func _create_status_effect() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.stack_count = 3
	status_effect.tag = StatusEffectTag.Swoop
	status_effect.is_ailment = false
	
	var stat_modifier := StatModifier.new()
	stat_modifier.type = StatModifier.Type.Evasion
	stat_modifier.add_amount = 1
	
	status_effect.add_child(stat_modifier)
	
	return status_effect
