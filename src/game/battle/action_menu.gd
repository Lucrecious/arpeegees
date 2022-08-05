class_name PinActionMenu
extends Control

const ActionButton := preload('res://src/game/battle/action_button.tscn')

onready var _vbox := $VBox as VBoxContainer

func clear() -> void:
	for child in _vbox.get_children():
		_vbox.remove_child(child)
		child.queue_free()

func add_pin_action(action: PinAction) -> Button:
	var action_button := ActionButton.instance() as PinActionButton
	action_button.label_text = action.nice_name
	
	match action.action_type:
		PinAction.ActionType.Physical:
			action_button.icon_name = 'sword_attack'
		_:
			pass
	
	_vbox.add_child(action_button)
	return action_button
