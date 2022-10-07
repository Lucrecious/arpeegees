extends Node2D

signal text_triggered(translation)

const MAX_USES := 3

var _uses := MAX_USES
var _blocked := false

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/crustify_blobbo.tres')

func is_blocked() -> bool:
	return _blocked

func run(actioner: Node2D, object: Object, callback: String) -> void:
	_uses -= 1
	
	if _uses <= 0:
		_blocked = true
	
	var animation := create_tween()
	
	animation.tween_interval(0.5)
	
	var status_effects := NodE.get_child(actioner, StatusEffectsList) as StatusEffectsList
	var status_effect := _create_defence_modifier()
	animation.tween_callback(status_effects, 'add_instance', [status_effect])
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_CRUSTIFY_USE')
	
	animation.tween_callback(object, callback)

func _create_defence_modifier() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.tag = StatusEffectTag.Crustify
	status_effect.stack_count = MAX_USES
	
	var defense_modifier := StatModifier.new()
	defense_modifier.type = StatModifier.Type.Defence
	defense_modifier.add_amount = 2
	
	status_effect.add_child(defense_modifier)
	
	return status_effect
