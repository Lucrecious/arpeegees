class_name ModifiedPinStats
extends Node

signal changed()

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

static func attack_with_critical(amount: int) -> int:
	return int(round(amount * 2.0))

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
	
	max_health = modified_stats.modified[StatModifier.Type.MaxHealth]
	attack = modified_stats.modified[StatModifier.Type.Attack]
	magic_attack = modified_stats.modified[StatModifier.Type.MagicAttack]
	defence = modified_stats.modified[StatModifier.Type.Defence]
	magic_defence = modified_stats.modified[StatModifier.Type.MagicDefence]
	evasion = modified_stats.modified[StatModifier.Type.Evasion]
	critical = modified_stats.modified[StatModifier.Type.Critical]
	
	emit_signal('changed')
