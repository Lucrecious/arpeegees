class_name ModifiedPinStats
extends Node

signal changed()
signal changed_relatives(relatives)

const CRITICAL_MAX := 10
const EVASION_MAX := 10

var max_health := 0
var attack := 0
var magic_attack := 0
var defence := 0
var magic_defence := 0
var evasion := 0
var critical := 0

onready var _status_effects := NodE.get_sibling(self, StatusEffectsList) as StatusEffectsList
onready var _health := NodE.get_sibling(self, Health) as Health
onready var _health_initial_max := _health.current


static func attack_with_critical(amount: int) -> int:
	return int(ceil(amount * 2.5))

func _ready() -> void:
	_status_effects.connect('effect_added_or_removed', self, '_on_effect_added_or_removed')
	_on_effect_added_or_removed()

func _on_effect_added_or_removed() -> void:
	_update_cache()

func _update_cache() -> void:
	var modified_stats := StatComputer.get_modified_stats(get_parent())
	if modified_stats.empty():
		assert(false)
		return
	
	var new_max_health := modified_stats.modified[StatModifier.Type.MaxHealth] as int
	var new_attack := modified_stats.modified[StatModifier.Type.Attack] as int
	var new_magic_attack := modified_stats.modified[StatModifier.Type.MagicAttack] as int
	var new_defence = modified_stats.modified[StatModifier.Type.Defence] as int
	var new_magic_defence = modified_stats.modified[StatModifier.Type.MagicDefence] as int
	var new_evasion = modified_stats.modified[StatModifier.Type.Evasion] as int
	var new_critical = modified_stats.modified[StatModifier.Type.Critical] as int
	
	var relatives := {
		StatModifier.Type.MaxHealth : new_max_health - max_health,
		StatModifier.Type.Attack : new_attack - attack,
		StatModifier.Type.MagicAttack : new_magic_attack - magic_attack,
		StatModifier.Type.Defence : new_defence - defence,
		StatModifier.Type.MagicDefence : new_magic_defence - magic_defence,
		StatModifier.Type.Evasion : new_evasion - evasion,
		StatModifier.Type.Critical : new_critical - critical,
	}
	
	max_health = new_max_health
	attack = new_attack
	magic_attack = new_magic_attack
	defence = new_defence
	magic_defence = new_magic_defence
	evasion = new_evasion
	critical = new_critical
	
	emit_signal('changed')
	emit_signal('changed_relatives', relatives)
