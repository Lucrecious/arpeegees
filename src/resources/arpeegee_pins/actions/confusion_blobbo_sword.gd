extends Node2D

signal text_triggered(narration_key)

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/confusion_blobbo_sword.tres')

func run(actioner: ArpeegeePinNode, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.3)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['confusion'])
	
	animation.tween_interval(0.5)
	
	var status_effects_list := NodE.get_child(actioner, StatusEffectsList) as StatusEffectsList
	animation.tween_callback(status_effects_list, 'add_instance', [_create_confusion_effect()])
	
	ActionUtils.add_text_trigger_limited(animation, self, 'NARRATOR_CONFUSION_USE')
	
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	animation.tween_callback(object, callback)

func _create_confusion_effect() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.is_ailment = false
	status_effect.tag = StatusEffectTag.ConfusionForSwordBlobbo
	
	var defence_modifier := StatModifier.new()
	defence_modifier.type = StatModifier.Type.Defence
	defence_modifier.add_amount = 1
	
	var magic_defence_modifier := StatModifier.new()
	magic_defence_modifier.type = StatModifier.Type.MagicDefence
	magic_defence_modifier.add_amount = 1
	
	var remove_effect := RemoveConfusionEffect.new()
	
	NodE.add_children(status_effect, [defence_modifier, magic_defence_modifier, remove_effect])
	
	return status_effect

class RemoveConfusionEffect extends Node:
	signal start_turn_effect_finished()
	signal text_triggered(translation_key)
	
	func run_start_turn_effect() -> void:
		var animation := create_tween()
		
		animation.tween_callback(self, 'emit_signal', ['start_turn_effect_finished'])
		animation.tween_callback(get_parent(), 'queue_free')
