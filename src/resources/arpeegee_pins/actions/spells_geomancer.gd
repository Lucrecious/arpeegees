extends Node2D

signal text_triggered(narration_key)

enum Type {
	RaiseEarth,
	RockWall,
}

export(Type) var type := Type.RaiseEarth

var _is_blocked := false

func is_blocked() -> bool:
	return _is_blocked

func pin_action() -> PinAction:
	if type == Type.RaiseEarth:
		return preload('res://src/resources/actions/raise_earth_geomancer.tres')
	elif type == Type.RockWall:
		return preload('res://src/resources/actions/rock_wall_geomancer.tres')
	else:
		assert(false)
		return null

var _uses := 0

func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.35)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['raise'])
	
	if type == Type.RaiseEarth:
		var rocks: Node2D = null
		if _uses == 0:
			rocks = get_child(0) as Node2D
			rocks.visible = true
			rocks.modulate.a = 0.0
		elif _uses == 1:
			rocks = get_child(0).duplicate()
			rocks.position = Vector2.ZERO
			rocks.modulate.a = 0.0
			add_child(rocks)
		
		if rocks:
			var y := [-25, -70][_uses] as float
			animation.tween_property(rocks, 'position:y', y, 1.0)
			animation.parallel().tween_property(rocks, 'modulate:a', 1.0, 0.5)
			
			var status_effects := NodE.get_child(actioner, StatusEffectsList) as StatusEffectsList
			animation.tween_callback(status_effects, 'add_instance', [_create_raise_earth_status()])
			
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_RAISE_EARTH_USE')
		else:
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_RAISE_EARTH_USE_NO_MORE_ROCKS')
			
		
	elif type == Type.RockWall:
		pass
		# rock wall
	else:
		assert(false)
	
	_uses += 1
	
	animation.tween_interval(0.4)
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	animation.tween_callback(object, callback)

func _create_raise_earth_status() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.stack_count = 2
	status_effect.tag = StatusEffectTag.RaiseEarth
	status_effect.is_ailment = false
	
	var attack_modifier := StatModifier.new()
	attack_modifier.type = StatModifier.Type.Attack
	attack_modifier.multiplier = 1.5
	
	var magic_attack_modifier := StatModifier.new()
	magic_attack_modifier.type = StatModifier.Type.MagicAttack
	magic_attack_modifier.multiplier = 1.5
	
	NodE.add_children(status_effect, [attack_modifier, magic_attack_modifier])
	
	return status_effect
