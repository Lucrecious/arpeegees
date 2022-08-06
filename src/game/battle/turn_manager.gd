class_name TurnManager
extends Node

signal player_turn_started()
signal npc_turn_started()
signal action_started()
signal action_ended()
signal battle_ended(end_condition)

enum EndCondition {
	None,
	PlayersDead,
	NPCsDead,
	EveryoneDead,
}

var _ordered_pins := []
var _players := []
var _npcs := []

var _is_running_action := false

var _current_turn := 0

func initialize_turns(pins: Array) -> void:
	_ordered_pins = pins.duplicate()
	_players = _get_type(ArpeegeePin.Type.Player)
	_npcs = _get_type(ArpeegeePin.Type.NPC)
	
	_ordered_pins.sort_custom(self, '_by_playable_by_topdown')
	
	if _ordered_pins.empty():
		assert(false)
		return
	
	_do_turn(_current_turn)

func get_npcs() -> Array:
	return _npcs.duplicate()

func get_players() -> Array:
	return _players.duplicate()

func next_turn() -> void:
	if _is_running_action:
		assert(false)
		return
	
	_current_turn += 1
	_do_turn(_current_turn)

func get_turn_pin() -> ArpeegeePinNode:
	return _ordered_pins[_current_turn % _ordered_pins.size()] as ArpeegeePinNode

func run_action_with_target(pin: ArpeegeePinNode, action_name: String, target: ArpeegeePinNode) -> void:
	var actions_node := NodE.get_child(pin, PinActions) as PinActions
	actions_node.connect('action_started', self, '_on_action_started', [],
			CONNECT_ONESHOT | CONNECT_DEFERRED | CONNECT_REFERENCE_COUNTED)
	actions_node.connect('action_ended', self, '_on_action_ended', [],
			CONNECT_ONESHOT | CONNECT_DEFERRED | CONNECT_REFERENCE_COUNTED)
	
	if target:
		actions_node.run_action_with_target(action_name, target)
	else:
		actions_node.run_action(action_name)

func run_action(pin: ArpeegeePinNode, action_name: String) -> void:
	run_action_with_target(pin, action_name, null)

func is_running_action() -> bool:
	return _is_running_action

func _on_action_started() -> void:
	_is_running_action = true
	emit_signal('action_started')

func _on_action_ended() -> void:
	_is_running_action = false
	emit_signal('action_ended')

func _get_type(type: int) -> Array:
	var pins_of_type := []
	for p in _ordered_pins:
		var arpeegee := p.resource as ArpeegeePin
		if arpeegee.type != type:
			continue
		pins_of_type.push_back(p)
	
	return pins_of_type

func _do_turn(turn: int) -> void:
	var end_condition := _is_game_finished()
	if end_condition != EndCondition.None:
		emit_signal('battle_ended', end_condition)
		return
	
	var pin := _ordered_pins[turn % _ordered_pins.size()] as ArpeegeePinNode
	var health := NodE.get_child(pin, Health) as Health
	if health and health.current <= 0:
		next_turn()
		return
		
	var is_player := bool(pin.resource.type == ArpeegeePin.Type.Player)
	if is_player:
		emit_signal('player_turn_started')
	else:
		emit_signal('npc_turn_started')

func _is_game_finished() -> int:
	var all_players_dead := _is_all_dead(_players)
	var all_npcs_dead := _is_all_dead(_npcs)
	
	if all_players_dead and all_npcs_dead:
		return EndCondition.EveryoneDead
	
	if all_npcs_dead:
		return EndCondition.NPCsDead
	
	if all_players_dead:
		return EndCondition.PlayersDead
	
	return EndCondition.None

func _is_all_dead(pins: Array) -> bool:
	for p in pins:
		var health := NodE.get_child(p, Health) as Health
		if not health:
			continue
		
		if health.current > 0:
			return false
	
	return true

func _by_playable_by_topdown(node1: ArpeegeePinNode, node2: ArpeegeePinNode) -> bool:
	var resource1 := node1.resource
	var resource2 := node2.resource
	if resource1.type == resource2.type:
		return node1.global_position.y < node2.global_position.y
	
	return resource1.type == ArpeegeePin.Type.Player
