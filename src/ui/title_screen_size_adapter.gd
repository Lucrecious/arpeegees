extends Node

export(NodePath) var main_path := NodePath()

onready var _main := get_node_or_null(main_path)

func _init().():
	add_to_group('size_adapter')

func _ready() -> void:
	assert(_main)

func adapt(size: float) -> void:
	var y := _main.get_battle_screen().title_bag_hint.rect_global_position.y as float
	get_parent().rect_global_position.y = y - get_parent().rect_size.y + 100.0
