class_name NPCAI
extends Node

signal turn_finished()

export(NodePath) var _narrator_ui_path := NodePath()
export(int) var debug_action_index := -1

onready var _turn_manager := NodE.get_sibling(self, TurnManager) as TurnManager
onready var _narrator_ui := NodE.get_node(self, _narrator_ui_path, NarratorUI) as NarratorUI

func _ready() -> void:
	if not Debug.play_as_npcs:
		_turn_manager.connect('npc_turn_started', self, '_on_npc_turn_started')

func _on_npc_turn_started() -> void:
	var pin := _turn_manager.get_turn_pin()
	
	var actions_node := NodE.get_child(pin, PinActions) as PinActions
	var action_nodes := actions_node.get_pin_action_nodes()
	var health := NodE.get_child(pin, Health) as Health
	if action_nodes.empty() or health.current <= 0:
		_turn_manager.finish_turn()
		return
	
	var tween := create_tween()
	TweenExtension.pause_until_signal_if_condition(tween, _narrator_ui, 'speaking_ended',
			_narrator_ui, 'is_speaking')
	
	tween.tween_interval(1.0)
	
	var action_index := randi() % action_nodes.size()
	if debug_action_index > -1:
		action_index = debug_action_index
		action_index = min(action_nodes.size() - 1, action_index)
	
	var node := action_nodes[action_index] as Node
	var action := node.pin_action() as PinAction
	
	if action.target_type == PinAction.TargetType.Single:
		var players := TurnManager.is_alive(_turn_manager.get_players())
		var wont_attack_paladin := NodE.get_child(pin, WontAttackPaladin, false) as WontAttackPaladin
		if wont_attack_paladin:
			players = TurnManager.remove_by_file(players, 'paladin.tscn')
			players = TurnManager.remove_by_file(players, 'paladin_no_sword.tscn')
			players = TurnManager.remove_by_file(players, 'holy_paladin.tscn')
			if players.empty():
				_narrator_ui.speak_tr('NARRATOR_KOBOLDIO_FRIENDLY_PALADIN', true)
				_turn_manager.finish_turn()
				return
		
		tween.tween_callback(_turn_manager, 'run_action_with_target',
				[pin, node.name, players[randi() % players.size()]])
	
	elif action.target_type == PinAction.TargetType.Self:
		tween.tween_callback(_turn_manager, 'run_action', [pin, node.name])
	elif action.target_type == PinAction.TargetType.AllEnemies:
		var players := TurnManager.is_alive(_turn_manager.get_players())
		
		
		tween.tween_callback(_turn_manager, 'run_action_with_targets', [pin, node.name, players])
	elif action.target_type == PinAction.TargetType.AllAllies:
		var npcs := _turn_manager.get_npcs()
		tween.tween_callback(_turn_manager, 'run_action_with_targets', [pin, node.name, npcs])
	else:
		assert(false)
		return
