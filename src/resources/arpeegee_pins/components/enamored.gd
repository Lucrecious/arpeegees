class_name Enamored
extends Node

var _is_enamored := false

func is_enamored() -> bool:
	return _is_enamored

func enamore() -> void:
	if _is_enamored:
		return
	_is_enamored = true
	
	var sprite_switcher := NodE.get_sibling(self, SpriteSwitcher) as SpriteSwitcher
	sprite_switcher.swap_map('idle', 'enamored')
	
	var effects_list := NodE.get_sibling(self, StatusEffectsList) as StatusEffectsList
	effects_list.add_instance(_create_enamored_effect())

func _create_enamored_effect() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.is_ailment = false # can only be cured by calling ruin_enamor
	status_effect.stack_count = 1
	status_effect.tag = StatusEffectTag.HarpyEnamored
	
	var defence := StatModifier.new()
	defence.type = StatModifier.Type.Defence
	defence.add_amount = -1
	
	status_effect.add_child(defence)
	
	return status_effect

func ruin_enamore() -> void:
	if not _is_enamored:
		return
	_is_enamored = false
	queue_free()
	
	var sprite_switcher := NodE.get_sibling(self, SpriteSwitcher) as SpriteSwitcher
	sprite_switcher.swap_map('idle', 'sad')
	
	var effects_list := NodE.get_sibling(self, StatusEffectsList) as StatusEffectsList
	var effects := effects_list.get_from_tag(StatusEffectTag.HarpyEnamored)
	for e in effects:
		e.queue_free()
	
	for s in get_tree().get_nodes_in_group('sparkle_ability'):
		assert(s.has_method('block'))
		s.block()
