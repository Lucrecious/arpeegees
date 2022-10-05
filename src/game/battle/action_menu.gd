class_name PinActionMenu
extends MarginContainer

signal action_picked(action_node, targets)
signal target_hovered(target)
signal action_hovered(action_node)
signal shown()
signal hidden()

onready var _action_pick_menu := $'%ActionPickMenu' as PickMenu
onready var _pickable_targets_menu := $'%PickableTargetsMenu' as PickMenu

var _index_to_action_node := {}
var _action_node_to_pickable_targets := {}
var _current_index := -1

func _ready() -> void:
	_pickable_targets_menu.set_header_text('Targets')
	
	_action_pick_menu.connect('option_hover_changed', self, '_on_action_hover_changed')
	_pickable_targets_menu.connect('option_hover_changed', self, '_on_option_hover_changed')

func hidden() -> void:
	_to_hide()

func _on_action_hover_changed() -> void:
	var index := _action_pick_menu.get_hover_index()
	var action_node := _index_to_action_node.get(index, null) as Node
	if not action_node:
		emit_signal('action_hovered', null)
		return
	
	emit_signal('action_hovered', action_node)

func _on_option_hover_changed() -> void:
	if _current_index == -1:
		emit_signal('target_hovered', null)
		return
	
	var action_node := _index_to_action_node.get(_current_index, null) as Node
	if not action_node:
		return
		
	var index := _pickable_targets_menu.get_hover_index()
	if index < 0:
		emit_signal('target_hovered', null)
		return
	
	var targets := _action_node_to_pickable_targets[action_node] as Array
	if index > targets.size() - 1:
		emit_signal('target_hovered', null)
		return
	
	var pin := targets[index] as ArpeegeePinNode
	emit_signal('target_hovered', pin)

func _to_hide() -> void:
	visible = false
		
	_action_pick_menu.visible = false
	_pickable_targets_menu.visible = false
	emit_signal('hidden')

func _to_show() -> void:
	visible = true
	_pickable_targets_menu.visible = false
	_action_pick_menu.visible = true
	_action_pick_menu.update_hover_index(false, true)
	emit_signal('shown')

func initialize(pin: ArpeegeePinNode) -> void:
	_to_show()
	
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
	
	_current_index = index
	_action_pick_menu.visible = false
	_pickable_targets_menu.visible = true
	_pickable_targets_menu.call_deferred('update_hover_index', false, true)
	
	for t in pickable_targets:
		var pin := t as ArpeegeePinNode
		_pickable_targets_menu.add_option(pin.nice_name)
	
	_pickable_targets_menu.add_option('BACK')
	
	_pickable_targets_menu.connect('option_picked', self, '_on_target_picked', [action_node])

func _on_target_picked(index: int, action_node: Node) -> void:
	emit_signal('target_hovered', null)
	_current_index = -1
	
	_pickable_targets_menu.disconnect('option_picked', self, '_on_target_picked')
	_pickable_targets_menu.clear()
	
	var targets := _action_node_to_pickable_targets[action_node] as Array
	if index == targets.size():
		_pickable_targets_menu.visible = false
		_action_pick_menu.visible = true
		_action_pick_menu.update_hover_index(false, true)
		return
	
	var target := targets[index] as ArpeegeePinNode
	emit_signal('action_picked', action_node, [target])

func clear() -> void:
	_to_hide()
	
	_action_pick_menu.disconnect('option_picked', self, '_on_option_picked')
	_action_pick_menu.clear()
	_index_to_action_node.clear()
	_action_node_to_pickable_targets.clear()
