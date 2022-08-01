class_name PinActions
extends Node2D

signal action_started()
signal action_started_with_name()
signal action_ended()

onready var _parent := get_parent() as Node2D
onready var _bounding_box := NodE.get_sibling(self, REferenceRect) as REferenceRect

func _ready() -> void:
	assert(_parent)

func get_pin_action_nodes() -> Array:
	var pin_action_nodes := []
	
	for child in get_children():
		if not child.has_method('pin_action'):
			continue
		
		pin_action_nodes.push_back(child)
	
	return pin_action_nodes

func run_action_with_target(action_name: String, target: Node2D) -> void:
	var node := NodE.get_child_by_name(self, action_name)
	if not node:
		get_tree().create_tween().tween_callback(self, '_on_action_node_finished')
		print_debug('%s failed to %s' % [_parent.name, action_name])
		return
	
	if not node.has_method('run'):
		get_tree().create_tween().tween_callback(self, '_on_action_node_finished')
		print_debug('%s does not have a run method' % [node.get_path()])
		return
	
	if target == null:
		node.run(_parent, self, '_on_action_node_finished')
	else:
		node.run(_parent, target, self, '_on_action_node_finished')
	
	emit_signal('action_started')
	emit_signal('action_started_with_name', action_name)

func run_action(action_name: String) -> void:
	run_action_with_target(action_name, null)

func _on_action_node_finished() -> void:
	emit_signal('action_ended')
