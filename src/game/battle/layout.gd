class_name BattleLayout
extends Control

const LEFT_POSITION_PREFIX:= 'Left'
const RIGHT_POSITION_PREFIX = 'Right'
const ITEM_POSITION_PREFIX := 'Item'

func get_left_positions() -> Array:
	return _get_position_controls(LEFT_POSITION_PREFIX)

func get_right_positions() -> Array:
	return _get_position_controls(RIGHT_POSITION_PREFIX)

func get_item_position() -> Control:
	return _get_position_controls(ITEM_POSITION_PREFIX)[0]

func _get_position_controls(position_prefix: String) -> Array:
	var controls := []
	
	for child in get_children():
		if not child.name.begins_with(position_prefix):
			continue
		controls.push_back(child)
	
	return controls
