class_name WontAttackPaladin
extends Node

func add_post_hit(animation: SceneTreeTween, narrator_caller: Object) -> void:
	var sprite_switcher := NodE.get_sibling(self, SpriteSwitcher) as SpriteSwitcher
	
	animation.tween_callback(sprite_switcher, 'swap_map', ['idle', 'sad'])
	
	ActionUtils.add_text_trigger(animation, narrator_caller, 'NARRATOR_KOBOLDIO_NOT_FRIENDLY_PALADIN_ANYMORE')
	animation.tween_interval(0.5)
	
	var effects_list := NodE.get_sibling(self, StatusEffectsList) as StatusEffectsList
	animation.tween_callback(effects_list, 'add_instance', [_create_sad_effect()])
	
	animation.tween_callback(self, 'queue_free')

func _create_sad_effect() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.is_ailment = false
	status_effect.stack_count = 1
	status_effect.tag = StatusEffectTag.HeartbrokenKoboldio
	
	var attack := StatModifier.new()
	attack.type = StatModifier.Type.Attack
	attack.multiplier = 1.5
	
	status_effect.add_child(attack)
	
	return status_effect
	
