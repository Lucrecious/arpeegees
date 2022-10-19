extends Node2D

signal text_triggered(narration_key)

var _disappeared := false

func is_blocked() -> bool:
	return _disappeared

func reappear() -> void:
	_disappeared = false

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/disappear_koboldio.tres')

func run(actioner: Node2D, object: Object, callback: String) -> void:
	_disappeared = true
	
	var animation := create_tween()
	animation.tween_interval(0.35)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['nervous'])
	
	var root_sprite := Components.root_sprite(actioner)
	animation.tween_property(root_sprite, 'modulate:a', 0.0, 1.0)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	var list := NodE.get_child(actioner, StatusEffectsList) as StatusEffectsList
	animation.tween_callback(list, 'add_instance', [_create_status_effect()])
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_DISAPPEAR_USE')
	
	animation.tween_callback(object, callback)

func _create_status_effect() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.is_ailment = false
	status_effect.stack_count = 1
	status_effect.tag = StatusEffectTag.Disappeared
	
	var modifier := StatModifier.new()
	modifier.type = StatModifier.Type.Evasion
	modifier.add_amount = 6
	
	status_effect.add_child(modifier)
	
	return status_effect
