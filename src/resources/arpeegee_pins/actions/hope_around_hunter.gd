extends Node2D

signal text_triggered(translation)

var _is_blocked := false
func is_blocked() -> bool:
	return _is_blocked

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/hop_around_hunter.tres') as PinAction

func run(actioner: Node2D, object: Object, callback: String) -> void:
	_is_blocked = true
	
	var animation := create_tween()
	animation.tween_interval(0.35)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['stalk'])
	
	var position1 := actioner.global_position + Vector2.LEFT * 100.0
	var position2 := actioner.global_position + Vector2.RIGHT * 100.0
	
	ActionUtils.add_walk(animation, actioner, actioner.global_position, position1, 50.0, 1, true)
	ActionUtils.add_walk(animation, actioner, position1, position2, 75.0, 2, true)
	ActionUtils.add_walk(animation, actioner, position2, position1, 75.0, 2, true)
	ActionUtils.add_walk(animation, actioner, position1, actioner.global_position, 75.0, 1, true)
	
	var status_effects_list := NodE.get_child(actioner, StatusEffectsList) as StatusEffectsList
	animation.tween_callback(status_effects_list, 'add_instance', [_create_status_effect(actioner)])
	animation.tween_callback(Sounds, 'play', ['BuffAttackCry'])
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_HOP_AROUND_USE')
	
	animation.tween_interval(0.5)
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	animation.tween_callback(object, callback)

func _create_status_effect(actioner: Node2D) -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.stack_count = 1
	status_effect.tag = StatusEffectTag.HopAround
	status_effect.is_ailment = false
	
	var stat_modifier := StatModifier.new()
	stat_modifier.type = StatModifier.Type.Evasion
	
	var base_stats := NodE.get_child(actioner, PinStats) as PinStats
	stat_modifier.add_amount = base_stats.evasion
	
	status_effect.add_child(stat_modifier)
	
	return status_effect
