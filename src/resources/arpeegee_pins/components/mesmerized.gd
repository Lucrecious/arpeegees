class_name Mesmerized
extends Node

var _is_mesmerized := false

func is_mesmerized() -> bool:
	return _is_mesmerized

func add_mesmerize() -> void:
	if _is_mesmerized:
		return
	
	_is_mesmerized = true
	var sprite_switcher := NodE.get_sibling(self, SpriteSwitcher) as SpriteSwitcher
	sprite_switcher.swap_map('idle', 'mesmerized')

func remove_mesmerize() -> void:
	if not _is_mesmerized:
		return
	
	_is_mesmerized = false
	
	var _sprite_switcher := NodE.get_sibling(self, SpriteSwitcher) as SpriteSwitcher
	_sprite_switcher.swap_map('idle', 'mesmerized')
	
	var effects_list := NodE.get_sibling(self, StatusEffectsList) as StatusEffectsList
	effects_list.add_instance(_create_post_mesmerized_effect())
	
	queue_free()


func _create_post_mesmerized_effect() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.tag = StatusEffectTag.MushboyPostMesmerized
	status_effect.is_ailment = false
	status_effect.stack_count = 1
	
	var attack := StatModifier.new()
	attack.type = StatModifier.Type.Attack
	attack.multiplier = 1.5
	
	status_effect.add_child(attack)
	
	return status_effect
