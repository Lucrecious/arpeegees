class_name Bruiser
extends Node

var _bruise_level := 0

const bruising_sprites := ['idle', 'hurt', 'headbutt', 'shootbanan', 'appealing', 'love']

func bruise() -> void:
	if _bruise_level > 1:
		return
	
	var sprite_switcher := NodE.get_sibling(self, SpriteSwitcher) as SpriteSwitcher
	var effects_list := NodE.get_sibling(self, StatusEffectsList) as StatusEffectsList
	
	for n in bruising_sprites:
		if _bruise_level == 0:
			sprite_switcher.swap_map(n, '%s_bruised' % n)
		elif _bruise_level == 1:
			sprite_switcher.swap_map(n, '%s_fully_bruised' % n)
	
	effects_list.add_instance(_create_bruise_effect())
	Sounds.play('Debuff')
	_bruise_level += 1

func _create_bruise_effect() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.is_ailment = true
	status_effect.stack_count = 2
	status_effect.tag = StatusEffectTag.BananBruised
	
	var defence := StatModifier.new()
	defence.type = StatModifier.Type.Defence
	defence.add_amount = -1
	
	status_effect.add_child(defence)
	
	return status_effect
