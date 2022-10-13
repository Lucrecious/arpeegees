extends Node


export(NodePath) var _path := NodePath()
export(int) var size_limit_x := 1000
export(int) var size_y := 1000
export(int) var height_offset := 0
export(bool) var move_down := false
export(bool) var disabled := false
export(Array, NodePath) var _paths_copies := []
export(Array, int) var copy_height_offsets := []

onready var _texture := get_node(_path) as TextureRect
var _controls := []

func _init().():
	add_to_group('size_adapter')

func _ready() -> void:
	assert(_texture)
	
	for p in _paths_copies:
		_controls.push_back(get_node(p))

func adapt(size: float) -> void:
	if disabled:
		return
	
	if size <= size_limit_x:
		_texture.rect_position.y = height_offset
		_texture.rect_size.y = size_y
	else:
		var size_delta := size - size_limit_x
		var aspect := _texture.texture.get_size().aspect()
		var grow_amount := size_delta / aspect
		var effective_texture_height := _texture.rect_size.x / aspect
		
		if move_down:
			_texture.rect_position.y = height_offset + grow_amount
			_texture.rect_size.y = size_y + grow_amount
		else:
			_texture.rect_position.y = height_offset - grow_amount
			_texture.rect_size.y = size_y + grow_amount
		
		for i in _controls.size():
			var control := _controls[i] as Control
			var height_offset := copy_height_offsets[i] as int
			var moved_position := _texture.rect_position.y + effective_texture_height + height_offset
			control.rect_position.y = moved_position
