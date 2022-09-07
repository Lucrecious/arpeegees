class_name StatModifier
extends Node

enum Type {
	MaxHealth,
	Attack,
	MagicAttack,
	Defence,
	MagicDefence,
	Evasion,
	Critical,
}

static func type_to_string(type: int) -> String:
	match type:
		Type.MaxHealth: return 'Max Health'
		Type.Attack: return 'Attack'
		Type.MagicAttack: return 'Magic Attack'
		Type.Defence: return 'Defence'
		Type.MagicDefence: return 'Magic Defence'
		Type.Evasion: return 'Evasion'
		Type.Critical: return 'Critical'
	
	assert(false)
	return ''

export(Type) var type := Type.MaxHealth
export(float) var multiplier := 1.0

func apply(value: int) -> int:
	return int(round(value * multiplier))
