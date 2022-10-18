class_name SituationalDialog
extends Node

export(NodePath) var _turn_manager_path := NodePath()

onready var _turn_manager := NodE.get_node(self, _turn_manager_path, TurnManager) as TurnManager

func get_overall_turn_started_dialog(pin_type: int) -> PoolStringArray:
	var keys := PoolStringArray()
	var translation_key := _dancing_status_effect(pin_type)
	if not translation_key.empty():
		keys.push_back(translation_key)
	
	translation_key = _goo_trapped_key(pin_type)
	if not translation_key.empty():
		keys.push_back(translation_key)
	
	return keys

var _turns_dancing := {
	ArpeegeePin.Type.NPC : 0,
	ArpeegeePin.Type.Player : 0,
}
func _dancing_status_effect(pin_type: int) -> String:
	var translation_key := ''
	
	if _any_pin_has_status_effect(pin_type, StatusEffectTag.HeckinGoodSong):
		_turns_dancing[pin_type] += 1
		if _turns_dancing[pin_type] > 1:
			translation_key = 'NARRATOR_HECKIN_GOOD_SONG_MONSTERS_DANCING'
	elif _any_pin_has_status_effect(pin_type, StatusEffectTag.AnOkaySong):
		_turns_dancing[pin_type] += 1
		if _turns_dancing[pin_type] > 1:
			translation_key = 'NARRATOR_AN_OKAY_SONG_MAYBE_DISTRACTED'
	else:
		_turns_dancing[pin_type] = 0
	return translation_key

var _goo_trapped := {
	ArpeegeePin.Type.NPC : 0,
	ArpeegeePin.Type.Player : 0,
}
func _goo_trapped_key(pin_type: int) -> String:
	if _any_pin_has_status_effect(pin_type, StatusEffectTag.GooTrap):
		_goo_trapped[pin_type] += 1
		if _goo_trapped[pin_type] > GooShotTrapAction.GooTrapEffect.RUNS_ALIVE:
			_goo_trapped[pin_type] = 0
			return 'NARRATOR_GOO_TRAP_DISSOLVES'
		else:
			return 'NARRATOR_GOO_TRAP_CANNOT_MOVE'
	elif _goo_trapped[pin_type]:
		_goo_trapped[pin_type] = 0
	return ''

func _any_pin_has_status_effect(pin_type: int, tag: int) -> bool:
	var pins := _get_pins(pin_type)
	for p in pins:
		var status_effects := NodE.get_child(p, StatusEffectsList) as StatusEffectsList
		var has_effect := status_effects.count_tags(tag) > 0
		if not has_effect:
			continue
		return true
	return false

func _get_pins(pin_type: int) -> Array:
	var pins := []
	if pin_type == ArpeegeePin.Type.NPC:
		pins = _turn_manager.get_npcs()
	elif pin_type == ArpeegeePin.Type.Player:
		pins = _turn_manager.get_players()
	else:
		assert(false)
	
	return pins
