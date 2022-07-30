class_name PinActions
extends Node2D

signal finished()

onready var _parent := get_parent() as Node2D
onready var _bounding_box := NodE.get_sibling(self, REferenceRect) as REferenceRect

func _ready() -> void:
	assert(_parent)

func get_pin_actions() -> Array:
	var pin_actions := []
	
	for child in get_children():
		if not child.has_method('pin_action'):
			continue
		
		var pin_action := child.pin_action() as PinAction
		pin_actions.push_back(pin_action)
	
	return pin_actions

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
	
	node.run(_parent, target, self, '_on_action_node_finished')

func _on_action_node_finished() -> void:
	emit_signal('finished')
