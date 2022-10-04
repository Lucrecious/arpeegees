class_name SizeAdapter
extends Node

export(NodePath) var _smaller_path := NodePath()
export(NodePath) var _bigger_path := NodePath()
export(int) var size_limit := 1000

onready var _smaller := get_node(_smaller_path) as Control
onready var _bigger := get_node(_bigger_path) as Control

func _init().():
	add_to_group('size_adapter')

func _ready() -> void:
	assert(_smaller)
	assert(_bigger)

func adapt(size: float) -> void:
	_smaller.visible = size < size_limit
	_bigger.visible = size >= size_limit
