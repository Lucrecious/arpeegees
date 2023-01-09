extends Node2D

signal text_triggered(narration_key)

func block() -> void:
	_is_blocked = true

func unblock() -> void:
	_is_blocked = false

var _is_blocked := false
func is_blocked() -> bool:
	return _is_blocked

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/sparkles_blobbo_sparkling.tres') as PinAction

func run(actioner: Node2D, object: Object, callback: String) -> void:
	_is_blocked = true
	
	var animation := create_tween()
	animation.tween_interval(0.35)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['win'])
	var sounds := NodE.get_child(actioner, SoundsComponent)
	animation.tween_callback(sounds, 'play', ['Sparkles'])
	
	var list := NodE.get_child(actioner, StatusEffectsList) as StatusEffectsList
	animation.tween_callback(list, 'add_instance', [_create_status_effect(self)])
	
	var sparkles := VFX.sparkle_explosions()
	animation.tween_callback(NodE, 'add_children', [actioner, sparkles])
	
	ActionUtils.add_text_trigger_limited(animation, self, 'NARRATOR_SPARKLES_USE')
	
	animation.tween_interval(1.5)
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	animation.tween_callback(object, callback)

func _create_status_effect(action_node: Node) -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.stack_count = 1
	status_effect.is_ailment = false
	status_effect.tag = StatusEffectTag.Sparkles
	
	var remove_after_three_turns := RemoveAfterThree.new(action_node)
	status_effect.add_child(remove_after_three_turns)
	
	var attack_up := StatModifier.new()
	attack_up.type = StatModifier.Type.Attack
	attack_up.add_amount = 3
	status_effect.add_child(attack_up)
	
	return status_effect

class RemoveAfterThree extends Node:
	signal start_turn_effect_finished()
	
	var _turns := 0
	var _action_node: Node
	
	func _init(action_node: Node) -> void:
		_action_node = action_node

	func run_start_turn_effect() -> void:
		var tween := create_tween()
		tween.tween_callback(self, 'emit_signal', ['start_turn_effect_finished'])
		
		_turns += 1
		if _turns <= 2:
			return
		
		if _action_node.has_method('unblock'):
			_action_node.unblock()
		
		tween.tween_callback(get_parent(), 'queue_free')
		
