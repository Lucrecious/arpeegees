class_name TurnManager
extends Control

const ActionMenuScene := preload('res://src/game/battle/action_menu.tscn')

var _ordered_pins := []

var _current_turn := 0

func initialize_turns(pins: Array) -> void:
	_ordered_pins = pins.duplicate()
	_ordered_pins.sort_custom(self, '_by_playable_by_topdown')
	
	if _ordered_pins.empty():
		return
	
	_do_turn(_current_turn, self, '_on_turn_finished')

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
	action_menu.rect_global_position = menu_corner
	
	for node in action_nodes:
		var action := node.pin_action() as PinAction
		var button := action_menu.add_pin_action(action)
		
		if action.target_type == PinAction.TargetType.Single:
			button.connect('pressed', self, '_run_action_with_target', [pin, node.name])
		elif action.target_type == PinAction.TargetType.Self:
			button.connect('pressed', self, '_run_action', [pin, node.name])
	
	actions_node.connect('action_started', self, '_on_action_started', [action_menu], CONNECT_ONESHOT)
	actions_node.connect('action_ended', self, '_on_action_ended', [object, callback], CONNECT_ONESHOT)

func _on_action_started(menu: PinActionMenu) -> void:
	menu.queue_free()

func _on_action_ended(object: Object, callback: String) -> void:
	object.call(callback)

func _run_action_with_target(pin: ArpeegeePinNode, action_name: String) -> void:
	var actions_node := NodE.get_child(pin, PinActions) as PinActions
	if pin.resource.type == ArpeegeePin.Type.Player:
		actions_node.run_action_with_target(action_name, _ordered_pins[-1])
	elif pin.resource.type == ArpeegeePin.Type.NPC:
		actions_node.run_action_with_target(action_name, _ordered_pins[0])
	else:
		assert(false)

func _run_action(pin: ArpeegeePinNode, action_name: String) -> void:
	var actions_node := NodE.get_child(pin, PinActions) as PinActions
	actions_node.run_action(action_name)

func _on_action_pressed(menu: PinActionMenu, pin: ArpeegeePinNode, action_node: Node,
	object: Object, callback: String) -> void:
	menu.queue_free()
	
	if pin.resource.type == ArpeegeePin.Type.Player:
		action_node.run_action_with_target()

func _on_turn_finished() -> void:
	_next_turn()

func _next_turn() -> void:
	_current_turn += 1
	_do_turn(_current_turn, self, '_on_turn_finished')

func _by_playable_by_topdown(node1: ArpeegeePinNode, node2: ArpeegeePinNode) -> bool:
	var resource1 := node1.resource
	var resource2 := node2.resource
	if resource1.type == resource2.type:
		return node1.global_position.y < node2.global_position.y
	
	return resource1.type == ArpeegeePin.Type.Player
