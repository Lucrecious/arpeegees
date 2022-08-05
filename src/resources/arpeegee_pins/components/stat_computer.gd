class_name StatComputer
extends Reference

static func get_modified_stats(pin: ArpeegeePinNode) -> Dictionary:
	var stats := NodE.get_child(pin, PinStats) as PinStats
	if not stats:
		assert(false)
		return {}
	
	var health := NodE.get_child(pin, Health) as Health
	if not health:
		assert(false)
		return {}
	
	var status_effects_list := NodE.get_child(pin, StatusEffectsList) as StatusEffectsList
	if not status_effects_list:
		assert(false)
		return {}
	
	var modifiers := []
	var status_effects := NodE.get_children(status_effects_list, StatusEffect)
	for s in status_effects:
		modifiers += s.get_modifiers()
	
	var modified_stats := {
		StatModifier.Type.MaxHealth : health.max_points,
		StatModifier.Type.Attack : stats.attack,
		StatModifier.Type.MagicAttack : stats.magic_attack,
		StatModifier.Type.Defence : stats.defence,
		StatModifier.Type.MagicDefence : stats.magic_defence,
		StatModifier.Type.Evasion : stats.evasion,
		StatModifier.Type.Critical : stats.critical,
	}
	
	for m in modifiers:
		var value := modified_stats.get(m.type, 0) as int
		modified_stats[m.type] = m.apply(value)
	
	return modified_stats
