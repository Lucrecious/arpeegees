class_name PinActionMenu
extends MarginContainer

signal action_picked(action_node, targets)

onready var _action_pick_menu := $'%ActionPickMenu' as PickMenu
onready var _pickable_targets_menu := $'%PickableTargetsMenu' as PickMenu

var _index_to_action_node := {}
var _action_node_to_pickable_targets := {}

func _ready() -> void:
	_pickable_targets_menu.set_header_text('Targets')

func initialize(pin: ArpeegeePinNode) -> void:
	visible = true
	_pickable_targets_menu.visible = false
	_action_pick_menu.visible = true
	
	_action_pick_menu.connect('option_picked', self, '_on_option_picked')
	_action_pick_menu.set_header_text(pin.nice_name)

func add_pin_action(action_node: Node, pickable_targets: Array) -> void:
	var pin_action := action_node.pin_action() as PinAction
	var index := _action_pick_menu.add_option(pin_action.nice_name)
	
	_index_to_action_node[index] = action_node
	_action_node_to_pickable_targets[action_node] = pickable_targets

func _on_option_picked(index: int) -> void:
	var action_node := _index_to_action_node[index] as Node
	var pickable_targets := _action_node_to_pickable_targets[action_node] as Array
	if pickable_targets.empty():
		emit_signal('action_picked', action_node, [])
		return
	
	_action_pick_menu.visible = false
	_pickable_targets_menu.visible = true
	
	for t in pickable_targets:
		var pin := t as ArpeegeePinNode
		_pickable_targets_menu.add_option(pin.nice_name)
	
	_pickable_targets_menu.add_option('BACK')
	
	_pickable_targets_menu.connect('option_picked', self, '_on_target_picked', [action_node])

func _on_target_picked(index: int, action_node: Node) -> void:
	_pickable_targets_menu.disconnect('option_picked', self, '_on_target_picked')
	_pickable_targets_menu.clear()
	
	var targets := _action_node_to_pickable_targets[action_node] as Array
	if index == targets.size():
		_pickable_targets_menu.visible = false
		_action_pick_menu.visible = true
		return
	
	var target := targets[index] as ArpeegeePinNode
	emit_signal('action_picked', action_node, [target])

func clear() -> void:
	visible = false
	_action_pick_menu.visible = false
	_pickable_targets_menu.visible = false
	
	_action_pick_menu.disconnect('option_picked', self, '_on_option_picked')
	_action_pick_menu.clear()
	_index_to_action_node.clear()
	_action_node_to_pickable_targets.clear()
