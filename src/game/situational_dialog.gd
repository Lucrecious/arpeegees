class_name SituationalDialog
extends Node

export(NodePath) var _turn_manager_path := NodePath()

onready var _turn_manager := NodE.get_node(self, _turn_manager_path, TurnManager) as TurnManager

func npc_overall_turn_started_dialog() -> PoolStringArray:
	var keys := PoolStringArray()
	keys.push_back(_dancing_status_effect())
	return keys

var _turns_dancing := 0
func _dancing_status_effect() -> String:
	var translation_key := ''
	
	if _any_npc_heckin_good_song_dancing():
		_turns_dancing += 1
		if _turns_dancing > 1:
			translation_key = 'NARRATOR_HECKIN_GOOD_SONG_MONSTERS_DANCING'
	else:
		_turns_dancing = 0
	return translation_key

func _any_npc_heckin_good_song_dancing() -> bool:
	var npcs := _turn_manager.get_npcs()
	for n in npcs:
		var status_effects := NodE.get_child(n, StatusEffectsList) as StatusEffectsList
		var is_dancing := status_effects.get_effect(HeckinGoodSongDancingEffect) != null
		if not is_dancing:
			continue
		return true
	return false


