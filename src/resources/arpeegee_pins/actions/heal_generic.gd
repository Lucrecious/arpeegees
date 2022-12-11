extends Node2D

signal text_triggered(narration_key)

enum Type {
	HolySparkles,
	Heal3,
	MedicinalSparkles,
	ForestLove,
}

export(Type) var type := Type.HolySparkles
export(String) var frame := ''

var _boosted := false
func boost_from_combing() -> void:
	_boosted = true

func block() -> void:
	_is_blocked = true

var _is_blocked := false
func is_blocked() -> bool:
	return _is_blocked

func pin_action() -> PinAction:
	if type == Type.HolySparkles:
		return preload('res://src/resources/actions/holy_sparkles_paladin.tres') as PinAction
	elif type == Type.Heal3:
		return preload('res://src/resources/actions/heal3_white_mage.tres') as PinAction
	elif type == Type.MedicinalSparkles:
		return preload('res://src/resources/actions/medicinal_sparkles_white_mage.tres') as PinAction
	elif type == Type.ForestLove:
		return preload('res://src/resources/actions/forest_love_ranger.tres')
	else:
		assert(false)
		return null

func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.5)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', [frame])
	
	var sounds := NodE.get_child(actioner, SoundsComponent)
	
	if type == Type.Heal3 or type == Type.HolySparkles or type == Type.ForestLove:
		for t in targets:
			var hearts := VFX.heart_explosion()
			animation.tween_callback(NodE, 'add_children', [t, hearts])
			animation.tween_callback(Sounds, 'play', ['GenericHeal'])
			
			if type == Type.Heal3 or type == Type.ForestLove:
				var root_sprite := NodE.get_child(t, RootSprite) as RootSprite
				var material := root_sprite.material as ShaderMaterial
				
				if type == Type.ForestLove:
					var center := NodE.get_child(t, REferenceRect).global_rect().get_center() as Vector2
					animation.tween_callback(material, 'set_shader_param', ['fill_color', Color.forestgreen])
					
					var love_sprite := get_child(0)
					animation.tween_callback(love_sprite, 'set', ['global_position', center])
					animation.tween_callback(love_sprite, 'set', ['modulate', Color.transparent])
					animation.tween_callback(love_sprite, 'set', ['visible', true])
					animation.tween_property(love_sprite, 'modulate:a', 1.0, 0.25)
					animation.tween_interval(0.25)
					animation.tween_property(love_sprite, 'rotation_degrees', 360.0, 1.0)
					animation.tween_interval(0.25)
					animation.tween_property(love_sprite, 'modulate:a', 0.0, 0.25)
					animation.tween_callback(love_sprite, 'set', ['visible', false])
					animation.tween_callback(love_sprite, 'set', ['rotation_degrees', 0])
				
				ActionUtils.add_shader_param_interpolation(animation, material,
						'color_mix', 0.0, 0.8, 0.75)\
						.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
				ActionUtils.add_shader_param_interpolation(animation, material,
						'color_mix', 0.8, 0.0, 0.75)\
						.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
				
				if type == Type.ForestLove:
					animation.tween_callback(material, 'set_shader_param', ['fill_color', Color.white])
		
		animation.tween_callback(self, '_heal_targets', [targets])
	
	elif type == Type.MedicinalSparkles:
		for t in targets:
			var sparkles := VFX.sparkle_explosions()
			animation.tween_callback(NodE, 'add_children', [t, sparkles])
		
		animation.tween_callback(self, '_heal_status_ailments', [targets])
		animation.tween_callback(sounds, 'play', ['MedicinalSparkles'])
	else:
		assert(false)
	
	
	if type == Type.HolySparkles:
		var enamored := get_tree().get_nodes_in_group('harpy_enamored')
		for e in enamored:
			if e.is_enamored():
				continue
			
			animation.tween_callback(e, 'enamore')
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_HARPY_LOVES_SPARKLES')
	
	animation.tween_interval(0.75)
	
	animation.tween_callback(sprite_switcher, 'change', ['Idle'])
	
	if type == Type.Heal3 or type == Type.HolySparkles or type == Type.ForestLove:
		var narrator_use_no_ally := 'NARRATOR_HOLY_SPARKLES_USE_NO_ALLY'
		var narrator_use_with_ally := 'NARRATOR_HOLY_SPARKLES_USE_WITH_ALLY'
		var narrator_use_dead_ally := 'NARRATOR_HOLY_SPARKLES_USE_DEAD_ALLY'
		if type == Type.Heal3:
			narrator_use_no_ally = 'NARRATOR_HEAL3_USE_NO_ALLY'
			narrator_use_with_ally = 'NARRATOR_HEAL3_USE_WITH_ALLY'
			narrator_use_dead_ally = 'NARRATOR_HEAL3_USE_DEAD_ALLY'
		elif type == Type.ForestLove:
			narrator_use_dead_ally = 'NARRATOR_FOREST_LOVE_USE_ALONE'
			narrator_use_with_ally = 'NARRATOR_FOREST_LOVE_USE_WITH_ALLY'
			narrator_use_no_ally = 'NARRATOR_FOREST_LOVE_USE_ALONE'
		
		if targets.size() == 1:
			ActionUtils.add_text_trigger(animation, self, narrator_use_no_ally)
		elif targets.size() > 1:
			var any_dead := false
			for t in targets:
				var health := NodE.get_child(t, Health) as Health
				if health.current > 0:
					continue
				any_dead = true
				break
			
			if not any_dead:
				ActionUtils.add_text_trigger(animation, self, narrator_use_with_ally)
			else:
				ActionUtils.add_text_trigger(animation, self, narrator_use_dead_ally)
	
	elif type == Type.MedicinalSparkles:
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_MEDICINAL_SPARKLES_USE')
	else:
		assert(false)
	
	if type == Type.MedicinalSparkles or type == Type.HolySparkles:
		var blobbo_kiss := get_tree().get_nodes_in_group('blobbo_kiss')
		for b in blobbo_kiss:
			b.add_sparkles_kiss(animation, self, actioner)
	
	if type == Type.Heal3 and not targets.empty() and targets[0].filename.get_file() == 'fishguy.tscn':
		var fishguy := targets[0] as Node
		var fishguy_sprite_switcher := NodE.get_child(fishguy, SpriteSwitcher) as SpriteSwitcher
		animation.tween_callback(fishguy_sprite_switcher, 'change', ['dance'])
		
		animation.tween_interval(1.0)
		
		var health := NodE.get_child(fishguy, Health) as Health
		animation.tween_callback(health, 'set_block_signals', [true])
		animation.tween_callback(health, 'damage', [100_000])
		
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_FISHGUY_HUMBLED_BY_HEAL3')
	
	animation.tween_callback(object, callback)

func _heal_targets(targets: Array) -> void:
	var percent_to_heal := 0.0
	if type == Type.HolySparkles:
		percent_to_heal = 0.2 * (Constants.HAIR_COMB_SPARKLES_BOOST_MULTIPLIER if _boosted else 1.0)
	elif type == Type.Heal3:
		percent_to_heal = 0.5
	elif type == Type.ForestLove:
		percent_to_heal = 0.2
	else:
		assert(false)
	
	for t in targets:
		var health := NodE.get_child(t, Health) as Health
		var pin_stats := NodE.get_child(t, ModifiedPinStats) as ModifiedPinStats
		var new_points := health.current + (pin_stats.max_health * percent_to_heal)
		health.current_set(min(new_points, pin_stats.max_health))

func _heal_status_ailments(targets: Array) -> void:
	for t in targets:
		var status_effects := NodE.get_child(t, StatusEffectsList) as StatusEffectsList
		for effect in status_effects.get_all():
			StatusEffect.queue_free_leave_particles_until_dead(effect)
