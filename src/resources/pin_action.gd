class_name PinAction
extends Resource

enum TargetType {
	Self,
	Single,
	AllEnemies,
	AllAllies,
	Heal3,
}

enum AttackType {
	Normal,
	Magic
}

export(String) var nice_name := 'Action'
export(String, MULTILINE) var description := ''
export(TargetType) var target_type := TargetType.Single
export(bool) var is_special := false
