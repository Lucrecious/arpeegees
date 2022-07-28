class_name BattleLayout
extends Node2D

const LeftPositionsName := 'Positions_Left'
const RightPositionsName = 'Positions_Right'

onready var _left_side_positions := get_node_or_null(LeftPositionsName) as Node2D
onready var _right_side_positions := get_node_or_null(RightPositionsName) as Node2D

func _ready() -> void:
	assert(_left_side_positions)
	assert(_right_side_positions)

func get_left_positions() -> PoolVector2Array:
	return _get_positions(_left_side_positions)

func get_right_positions() -> PoolVector2Array:
	return _get_positions(_right_side_positions)

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
	_right_side_positions.name = RightPositionsName
	_left_side_positions.name =  LeftPositionsName
	
