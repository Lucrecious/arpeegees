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
	
	var unmodified_stats := modified_stats.duplicate()
	
	var relative_stats := {
		StatModifier.Type.MaxHealth : 0,
		StatModifier.Type.Attack : 0,
		StatModifier.Type.MagicAttack : 0,
		StatModifier.Type.Defence : 0,
		StatModifier.Type.MagicDefence : 0,
		StatModifier.Type.Evasion : 0,
		StatModifier.Type.Critical : 0,
	}
	
	# does not compound, only uses base to calculate increase
	for m in modifiers:
		var base_value := unmodified_stats.get(m.type, 0) as int
		var new_value := m.apply(base_value) as int
		var delta := new_value - base_value
		modified_stats[m.type] = modified_stats[m.type] + delta
		relative_stats[m.type] = modified_stats[m.type] - unmodified_stats[m.type]
	
	var stats_dict := {
		modified = modified_stats,
		relative = relative_stats,
	}
	
	return stats_dict
