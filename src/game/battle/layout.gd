class_name BattleLayout
extends Node2D

const LEFT_POSITIONS_NAME := 'Positions_Left'
const RIGHT_POSITIONS_NAME = 'Positions_Right'
const ITEM_POSITION_NAME := 'Position_Item'

onready var _left_side_positions := get_node_or_null(LEFT_POSITIONS_NAME) as Node2D
onready var _right_side_positions := get_node_or_null(RIGHT_POSITIONS_NAME) as Node2D
onready var _item_position := get_node_or_null(ITEM_POSITION_NAME) as Node2D

func _ready() -> void:
	assert(_left_side_positions)
	assert(_right_side_positions)
	assert(_item_position)

func get_left_positions() -> PoolVector2Array:
	return _get_positions(_left_side_positions)

func get_right_positions() -> PoolVector2Array:
	return _get_positions(_right_side_positions)

func get_item_position() -> Vector2:
	return _get_positions(_item_position)[0]

func _get_positions(positions: Node2D) -> PoolVector2Array:
	var left_positions := PoolVector2Array()
	
	for child in positions.get_children():
		left_positions.push_back(child.global_position)
	
	return left_positions

func mirror() -> void:
	scale.x *= -1.0
	
	var tmp_side_position := _left_side_positions
	_left_side_positions = _right_side_positions
	_right_side_positions = tmp_side_position
	
	_left_side_positions.name += str(_left_side_positions.get_instance_id())
	_right_side_positions.name = RIGHT_POSITIONS_NAME
	_left_side_positions.name =  LEFT_POSITIONS_NAME
	
