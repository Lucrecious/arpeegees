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


export(Type) var type := Type.MaxHealth
export(float) var multiplier := 1.0

func apply(value: int) -> int:
	return int(round(value * multiplier))
