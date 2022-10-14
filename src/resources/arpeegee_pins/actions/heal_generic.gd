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
	
	if type == Type.Heal3 or type == Type.HolySparkles or type == Type.ForestLove:
		for t in targets:
			var hearts := VFX.heart_explosion()
			animation.tween_callback(NodE, 'add_children', [t, hearts])
			if type == Type.Heal3 or type == Type.ForestLove:
				var root_sprite := NodE.get_child(t, RootSprite) as RootSprite
				var material := root_sprite.material as ShaderMaterial
				
				if type == Type.ForestLove:
					animation.tween_callback(material, 'set_shader_param', ['fill_color', Color.forestgreen])
				
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
	else:
		assert(false)
	
	
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
	
	animation.tween_callback(object, callback)

func _heal_targets(targets: Array) -> void:
	var percent_to_heal := 0.0
	if type == Type.HolySparkles:
		percent_to_heal = 0.2
	elif type == Type.Heal3:
		percent_to_heal = 0.5
	elif type == Type.ForestLove:
		percent_to_heal = 0.2
	else:
		assert(false)
	
	for t in targets:
		var health := NodE.get_child(t, Health) as Health
		var new_points := health.current + (health.max_points * percent_to_heal)
		health.current_set(min(new_points, health.max_points))

func _heal_status_ailments(targets: Array) -> void:
	for t in targets:
		var status_effects := NodE.get_child(t, StatusEffectsList) as StatusEffectsList
		for effect in status_effects.get_all():
			StatusEffect.queue_free_leave_particles_until_dead(effect)
