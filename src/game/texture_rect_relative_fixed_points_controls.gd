extends TextureRect

export(Array, NodePath) var children_to_track := []

var _original_positions := []

func _init().():
	add_to_group('size_adapter')

func _ready() -> void:
	yield(get_parent(), 'ready')
	
	var texture_x := rect_size.x
	var texture_y := texture_x / texture.get_size().aspect()
	
	for n in children_to_track:
		var child := get_node(n) as Control
		_original_positions.push_back(child.rect_position / Vector2(texture_x, texture_y))

func adapt(size: float) -> void:
	var texture_size := rect_size
	texture_size.y = texture_size.x / texture.get_size().aspect()
	
	for i in children_to_track.size():
		var p := children_to_track[i] as NodePath
		var r := _original_positions[i] as Vector2
		var child := get_node(p) as Control
		child.rect_position = texture_size * r
