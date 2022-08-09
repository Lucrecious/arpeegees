extends Node2D

signal text_triggered(translation)

export(String) var impact_hint_name := 'ImpactHint'

onready var _impact_hint_node := NodE.get_child_by_name(self, impact_hint_name) as Node2D

var _times_used := 0

func pin_action() -> PinAction:
	return load('res://src/resources/actions/bard_mandolin_swing.tres') as PinAction

func times_used() -> int:
	return _times_used

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	_times_used += 1
	
	var position := actioner.global_position
	var relative := ActionUtils.get_closest_adjecent_position(actioner, target)
	var target_position := position + relative
	
	var side := int(sign(relative.x))
	
	var tween := get_tree().create_tween()
	position = ActionUtils.add_walk(tween, actioner, position, position + relative, 15.0, 7)
	tween.tween_interval(.3)
	position = ActionUtils.add_wind_up(tween, actioner, position, side)
	position = ActionUtils.add_stab(tween, actioner, target_position)
	
	if _times_used < 4:
		ActionUtils.add_text_trigger(tween, self, 'NARRATOR_MANDOLIN_BASH_USE_%d' % [_times_used])
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	tween.tween_callback(sprite_switcher, 'change', ['attack'])
	
	if _impact_hint_node:
		tween.tween_callback(VFX, 'physical_impact', [actioner, _impact_hint_node])
	
	ActionUtils.add_damage(tween, target, 10)
	ActionUtils.add_shake(tween, actioner, position, Vector2(1, 0), 5.0, .35)
	tween.tween_interval(.4)
	tween.tween_callback(sprite_switcher, 'change', ['idle'])
	ActionUtils.add_walk(tween, actioner,
			actioner.global_position + relative, actioner.global_position, 15.0, 7)
	tween.tween_callback(object, callback)
