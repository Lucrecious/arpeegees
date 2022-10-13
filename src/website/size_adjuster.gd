extends Node


export(NodePath) var _path := NodePath()
export(int) var size_limit_x := 1000
export(int) var size_y := 1000
export(int) var height_offset := 0
export(bool) var move_down := false
export(bool) var disabled := false

onready var _control := get_node(_path) as TextureRect

func _init().():
	add_to_group('size_adapter')

func _ready() -> void:
	assert(_control)

func adapt(size: float) -> void:
	if disabled:
		return
	
	if size <= size_limit_x:
		_control.rect_position.y = height_offset
		_control.rect_size.y = size_y
	else:
		var size_delta := size - size_limit_x
		var ratio := _control.texture.get_size()
		var grow_amount := (size_delta * ratio.y) / ratio.x
		if move_down:
			_control.rect_position.y = height_offset + grow_amount
			_control.rect_size.y = size_y + grow_amount
		else:
			_control.rect_position.y = height_offset - grow_amount
			_control.rect_size.y = size_y + grow_amount
		
