class_name PinActions
extends Node2D

signal action_started()
signal action_started_with_action_node()
signal action_ended()

onready var _parent := get_parent() as Node2D
onready var _bounding_box := NodE.get_sibling(self, REferenceRect) as REferenceRect

var _is_running_action := false
var _is_moveless := false

var _enabled := false
func enable() -> void:
	if _enabled:
		return
	
	_enabled = true

func disable() -> void:
	if not _enabled:
		return
	
	_enabled = false

func _ready() -> void:
	assert(_parent)

func is_running_action() -> bool:
	return _is_running_action

func set_moveless(is_moveless: bool) -> void:
	_is_moveless = is_moveless

func get_pin_action_nodes() -> Array:
	if _is_moveless:
		return []
	
	var pin_action_nodes := []
	
	for child in get_children():
		if not child.has_method('pin_action'):
			continue
		
		pin_action_nodes.push_back(child)
	
	return pin_action_nodes

func run_action_with_targets(action_name: String, targets: Array, multiple: bool) -> void:
	var node := NodE.get_child_by_name(self, action_name)
	if not node:
		print_debug('%s failed to %s, signals will not be called!' % [_parent.name, action_name])
		return
	
	if not node.has_method('run'):
		print_debug('%s does not have a run method, signals will not be called!' % [node.get_path()])
		return
	
	if targets.empty():
		node.run(_parent, self, '_on_action_node_finished')
	elif targets.size() == 1 and not multiple:
		node.run(_parent, targets[0], self, '_on_action_node_finished')
	else:
		node.run(_parent, targets, self, '_on_action_node_finished')
	
	_is_running_action = true
	emit_signal('action_started')
	emit_signal('action_started_with_action_node', node)

func run_action(action_name: String) -> void:
	run_action_with_targets(action_name, [], false)

func _on_action_node_finished() -> void:
	_is_running_action = false
	emit_signal('action_ended')
