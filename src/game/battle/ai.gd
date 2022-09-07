class_name NPCAI
extends Node

signal turn_finished()

export(NodePath) var _narrator_ui_path := NodePath()
export(int) var debug_action_index := -1

onready var _turn_manager := NodE.get_sibling(self, TurnManager) as TurnManager
onready var _narrator_ui := NodE.get_node(self, _narrator_ui_path, NarratorUI) as NarratorUI

func _ready() -> void:
	_turn_manager.connect('npc_turn_started', self, '_on_npc_turn_started')

func _on_npc_turn_started() -> void:
	var pin := _turn_manager.get_turn_pin()
	
	var actions_node := NodE.get_child(pin, PinActions) as PinActions
	var action_nodes := actions_node.get_pin_action_nodes()
	if action_nodes.empty():
		_turn_manager.finish_turn()
		return
	
	var tween := create_tween()
	if _narrator_ui.is_speaking():
		TweenExtension.pause_until_signal(tween, _narrator_ui, 'speaking_ended')
	
	tween.tween_interval(1.0)
	
	var action_index := randi() % action_nodes.size()
	if debug_action_index > -1:
		action_index = debug_action_index
	
	var node := action_nodes[action_index] as Node
	var action := node.pin_action() as PinAction
	
	if action.target_type == PinAction.TargetType.Single:
		var players := _turn_manager.get_players()
		
		tween.tween_callback(_turn_manager, 'run_action_with_target',
				[pin, node.name, players[randi() % players.size()]])
	
	elif action.target_type == PinAction.TargetType.Self:
		tween.tween_callback(_turn_manager, 'run_action', [pin, node.name])
	elif action.target_type == PinAction.TargetType.AllEnemies:
		var players := _turn_manager.get_players()
		tween.tween_callback(_turn_manager, 'run_action_with_targets', [pin, node.name, players])
	else:
		assert(false)
		return
