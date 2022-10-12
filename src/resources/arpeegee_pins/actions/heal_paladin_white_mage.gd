extends Node2D

signal text_triggered(narration_key)

enum Type {
	Paladin,
	WhiteMage,
}

export(Type) var type := Type.Paladin
export(String) var frame := ''

func pin_action() -> PinAction:
	if type == Type.Paladin:
		return preload('res://src/resources/actions/holy_sparkles_paladin.tres') as PinAction
	elif type == Type.WhiteMage:
		return preload('res://src/resources/actions/heal3_white_mage.tres') as PinAction
	else:
		assert(false)
		return null

func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.5)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', [frame])
	
	for t in targets:
		var box := NodE.get_child(t, REferenceRect) as REferenceRect
		var hearts := VFX.heart_explosion()
		animation.tween_callback(NodE, 'add_children', [t, hearts])
		if type == Type.WhiteMage:
			var root_sprite := NodE.get_child(t, RootSprite) as RootSprite
			var material := root_sprite.material as ShaderMaterial
			ActionUtils.add_shader_param_interpolation(animation, material,
					'color_mix', 0.0, 0.8, 0.75)\
					.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			ActionUtils.add_shader_param_interpolation(animation, material,
					'color_mix', 0.8, 0.0, 0.75)\
					.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		
	animation.tween_callback(self, '_heal_targets', [targets])
	
	animation.tween_interval(0.75)
	
	animation.tween_callback(sprite_switcher, 'change', ['Idle'])
	
	var narrator_use_no_ally := 'NARRATOR_HOLY_SPARKLES_USE_NO_ALLY'
	var narrator_use_with_ally := 'NARRATOR_HOLY_SPARKLES_USE_WITH_ALLY'
	var narrator_use_dead_ally := 'NARRATOR_HOLY_SPARKLES_USE_DEAD_ALLY'
	if type == Type.WhiteMage:
		narrator_use_no_ally = 'NARRATOR_HEAL3_USE_NO_ALLY'
		narrator_use_with_ally = 'NARRATOR_HEAL3_USE_WITH_ALLY'
		narrator_use_dead_ally = 'NARRATOR_HEAL3_USE_DEAD_ALLY'
	
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
	
	animation.tween_callback(object, callback)

func _heal_targets(targets: Array) -> void:
	var percent_to_heal := 0.0
	if type == Type.Paladin:
		percent_to_heal = 0.2
	elif type == Type.WhiteMage:
		percent_to_heal = 0.5
	else:
		assert(false)
	
	for t in targets:
		var health := NodE.get_child(t, Health) as Health
		var new_points := health.current + (health.max_points * percent_to_heal)
		health.current_set(min(new_points, health.max_points))
