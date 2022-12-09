class_name HunterGooedUp
extends Node

var _is_gooed := false

func is_gooed() -> bool:
	return _is_gooed

var _goo_sprites := ['idle', 'pounce', 'hurt', 'stalk', 'stab1', 'stab2', 'dead', 'win']
func enable_goo() -> void:
	if _is_gooed:
		return
	_is_gooed = true
	
	var sprite_switcher := NodE.get_sibling(self, SpriteSwitcher) as SpriteSwitcher
	for s in _goo_sprites:
		sprite_switcher.swap_map(s, '%s_Goo' % s)
	
	var status_effects_list := NodE.get_sibling(self, StatusEffectsList) as StatusEffectsList
	status_effects_list.add_instance(_create_gooed_up_status_effect())

func disable_goo() -> void:
	if not _is_gooed:
		return
	_is_gooed = false
	
	var sprite_switcher := NodE.get_sibling(self, SpriteSwitcher) as SpriteSwitcher
	for s in _goo_sprites:
		sprite_switcher.swap_map(s, '%s_Goo' % s)
	
	var status_effects_list := NodE.get_sibling(self, StatusEffectsList) as StatusEffectsList
	var effects := status_effects_list.get_from_tag(StatusEffectTag.HunterGooedUp)
	for e in effects:
		e.queue_free()

func _create_gooed_up_status_effect() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.is_ailment = false # because it can only be removed from fishguy splash
	status_effect.stack_count = 1
	status_effect.tag = StatusEffectTag.HunterGooedUp
	
	var evasion := StatModifier.new()
	evasion.type = StatModifier.Type.Evasion
	evasion.multiplier = 0.0
	
	status_effect.add_child(evasion)
	
	return status_effect
