class_name PinActionMenu
extends Control

const ActionButton := preload('res://src/game/battle/action_button.tscn')

var pass_all_mouse_input := true setget _pass_all_mouse_input_set
func _pass_all_mouse_input_set(value: bool) -> void:
	if is_inside_tree():
		assert(false)
		return
	
	pass_all_mouse_input = value

onready var _vbox := $VBox as VBoxContainer

func _ready() -> void:
	if not pass_all_mouse_input:
		return
	
	mouse_filter = Control.MOUSE_FILTER_PASS
	_vbox.mouse_filter = Control.MOUSE_FILTER_PASS

func clear() -> void:
	for child in _vbox.get_children():
		_vbox.remove_child(child)
		child.queue_free()

func add_pin_action(action: PinAction) -> Button:
	var action_button := ActionButton.instance() as PinActionButton
	if pass_all_mouse_input:
		action_button.mouse_filter = Control.MOUSE_FILTER_PASS
		for child in NodE.get_children_recursive(action_button, Control):
			child.mouse_filter = Control.MOUSE_FILTER_PASS
	
	action_button.label_text = action.nice_name
	
	match action.action_type:
		PinAction.ActionType.Physical:
			action_button.icon_name = 'sword_attack'
		_:
			pass
	
	_vbox.add_child(action_button)
	return action_button
