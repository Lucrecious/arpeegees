class_name TurnManager
extends Control

signal battle_ended(end_condition)

enum EndCondition {
	None,
	PlayersDead,
	NPCsDead,
	EveryoneDead,
}

const ActionMenuScene := preload('res://src/game/battle/action_menu.tscn')

var _ordered_pins := []
var _players := []
var _npcs := []

var _current_turn := 0

onready var _target_selector := $'%TargetSelector' as TargetSelector

func initialize_turns(pins: Array) -> void:
	_ordered_pins = pins.duplicate()
	_players = _get_type(ArpeegeePin.Type.Player)
	_npcs = _get_type(ArpeegeePin.Type.NPC)
	
	_ordered_pins.sort_custom(self, '_by_playable_by_topdown')
	
	if _ordered_pins.empty():
		return
	
	_do_turn(_current_turn, self, '_on_turn_finished')

func _get_type(type: int) -> Array:
	var pins_of_type := []
	for p in _ordered_pins:
		var arpeegee := p.resource as ArpeegeePin
		if arpeegee.type != type:
			continue
		pins_of_type.push_back(p)
	
	return pins_of_type

func _do_turn(turn: int, object: Object, callback: String) -> void:
	var pin := _ordered_pins[turn % _ordered_pins.size()] as ArpeegeePinNode
	var health := NodE.get_child(pin, Health) as Health
	if health and health.current <= 0:
		_next_turn()
		return
	
	var actions_node := NodE.get_child(pin, PinActions) as PinActions
	var action_nodes := actions_node.get_pin_action_nodes()
	
	var action_menu := ActionMenuScene.instance() as PinActionMenu
	add_child(action_menu)
	var menu_corner := ActionUtils.get_top_right_corner_screen(pin)
	action_menu.rect_position = menu_corner
	
	actions_node.connect('action_started', self, '_on_action_started', [action_menu], CONNECT_ONESHOT)
	actions_node.connect('action_ended', self, '_on_action_ended', [object, callback], CONNECT_ONESHOT)
	
	var is_player := bool(pin.resource.type == ArpeegeePin.Type.Player)
	if is_player:
		for node in action_nodes:
			var action := node.pin_action() as PinAction
			var button := action_menu.add_pin_action(action)
			
			if action.target_type == PinAction.TargetType.Single:
				button.connect('pressed', self, '_run_action_with_target', [pin, node.name])
			elif action.target_type == PinAction.TargetType.Self:
				button.connect('pressed', self, '_run_action', [pin, node.name])
			else:
				assert(false)
	else:
		var tween := create_tween()
		tween.tween_interval(1.0)
		
		var node := action_nodes[randi() % action_nodes.size()] as Node
		var action := node.pin_action() as PinAction
		if action.target_type == PinAction.TargetType.Single:
			tween.tween_callback(self, '_run_action_with_target', [pin, node.name])
		elif action.target_type == PinAction.TargetType.Self:
			tween.tween_callback(self, '_run_action', [pin, node.name])
		else:
			assert(false)
		

func _on_action_started(menu: PinActionMenu) -> void:
	menu.queue_free()

func _on_action_ended(object: Object, callback: String) -> void:
	object.call(callback)

func _run_action_with_target(pin: ArpeegeePinNode, action_name: String) -> void:
	var actions_node := NodE.get_child(pin, PinActions) as PinActions
	if pin.resource.type == ArpeegeePin.Type.Player:
		_target_selector.connect('target_found', self, '_on_target_found',
				[actions_node, action_name], CONNECT_ONESHOT)
		_target_selector.start(pin, _npcs)
	elif pin.resource.type == ArpeegeePin.Type.NPC:
		actions_node.run_action_with_target(action_name, _players[randi() % _players.size()])
	else:
		assert(false)

func _on_target_found(pin: ArpeegeePinNode,
		actions_node: PinActions, action_name: String) -> void:
	actions_node.run_action_with_target(action_name, pin)

func _run_action(pin: ArpeegeePinNode, action_name: String) -> void:
	var actions_node := NodE.get_child(pin, PinActions) as PinActions
	actions_node.run_action(action_name)

func _on_action_pressed(menu: PinActionMenu, pin: ArpeegeePinNode, action_node: Node,
	object: Object, callback: String) -> void:
	menu.queue_free()
	
	if pin.resource.type == ArpeegeePin.Type.Player:
		action_node.run_action_with_target()

func _on_turn_finished() -> void:
	var end_condition := _is_game_finished()
	if end_condition != EndCondition.None:
		emit_signal('battle_ended', end_condition)
		return
	
	_next_turn()

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

func _next_turn() -> void:
	_current_turn += 1
	_do_turn(_current_turn, self, '_on_turn_finished')

func _by_playable_by_topdown(node1: ArpeegeePinNode, node2: ArpeegeePinNode) -> bool:
	var resource1 := node1.resource
	var resource2 := node2.resource
	if resource1.type == resource2.type:
		return node1.global_position.y < node2.global_position.y
	
	return resource1.type == ArpeegeePin.Type.Player
