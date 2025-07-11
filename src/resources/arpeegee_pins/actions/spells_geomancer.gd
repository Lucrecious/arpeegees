extends Node2D

signal text_triggered(narration_key)

enum Type {
	RaiseEarth,
	RockWall,
}

export(Type) var type := Type.RaiseEarth

var _is_blocked := false

onready var _raise_drop_rocks := NodE.get_sibling(get_parent(), RaiseDropRocks) as RaiseDropRocks

func is_blocked() -> bool:
	return _is_blocked or (type == Type.RaiseEarth and _raise_drop_rocks.has_rocks())

func pin_action() -> PinAction:
	if type == Type.RaiseEarth:
		return preload('res://src/resources/actions/raise_earth_geomancer.tres')
	elif type == Type.RockWall:
		return preload('res://src/resources/actions/rock_wall_geomancer.tres')
	else:
		assert(false)
		return null

func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.35)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['raise'])
	
	var sounds := NodE.get_child(actioner, SoundsComponent)
	animation.tween_callback(sounds, 'play', ['RaiseEarth'])
	
	if type == Type.RaiseEarth:
		animation.tween_interval(1.0)
		
		animation.tween_callback(_raise_drop_rocks, 'hold_rocks')
		
		var status_effects := NodE.get_child(actioner, StatusEffectsList) as StatusEffectsList
		animation.tween_callback(status_effects, 'add_instance', [_create_raise_earth_status()])
		
		if not _raise_drop_rocks.rocks_lit():
			ActionUtils.add_text_trigger_limited(animation, self, 'NARRATOR_RAISE_EARTH_USE')
		else:
			ActionUtils.add_text_trigger_limited(animation, self, 'NARRATOR_RAISE_EARTH_USE_ON_FIRE')
		
		if status_effects.count_tags(StatusEffectTag.RaiseEarth) > 0:
			ActionUtils.add_text_trigger_limited(animation, self, 'NARRATOR_RAISE_EARTH_USE_USELESS')
	
	elif type == Type.RockWall:
		_is_blocked = true
		
		var rock_wall_animation_player_group := get_tree().get_nodes_in_group('rock_wall_animation_player')
		if not rock_wall_animation_player_group.empty():
			var rock_wall_animation_player := rock_wall_animation_player_group[0] as AnimationPlayer
			animation.tween_callback(rock_wall_animation_player, 'play', ['wall_appear'])
			animation.tween_interval(rock_wall_animation_player.get_animation('wall_appear').length)
			
			animation.tween_callback(self, '_add_rock_wall_defences', [targets])
			
			if targets.size() == 1:
				ActionUtils.add_text_trigger(animation, self, 'NARRATOR_RAISE_WALL_NO_ALLY')
			elif targets.size() > 1:
				ActionUtils.add_text_trigger(animation, self, 'NARRATOR_RAISE_WALL_WITH_ALLY')
		else:
			assert(false)
	else:
		assert(false)
	
	var mesmerizeds := get_tree().get_nodes_in_group('mushboy_mesmerized')
	if type == Type.RaiseEarth and not mesmerizeds.empty():
		for m in mesmerizeds:
			if m.is_mesmerized():
				continue
			animation.tween_callback(m, 'add_mesmerize')
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_MUSHBOY_MESMERIZED_BY_ROCKS')
	
	animation.tween_interval(0.4)
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	animation.tween_callback(object, callback)

func _add_rock_wall_defences(targets: Array) -> void:
	for t in targets:
		var status_effect := StatusEffect.new()
		status_effect.stack_count = 1
		status_effect.tag = StatusEffectTag.RockWall
		status_effect.is_ailment = false
		
		var defence_modifier := StatModifier.new()
		defence_modifier.type = StatModifier.Type.Defence
		defence_modifier.add_amount = 3
		
		status_effect.add_child(defence_modifier)
		
		var list := NodE.get_child(t, StatusEffectsList) as StatusEffectsList
		list.add_instance(status_effect)

func _create_raise_earth_status() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.stack_count = 1
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
