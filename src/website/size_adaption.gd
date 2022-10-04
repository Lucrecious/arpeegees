extends Node

func _ready() -> void:
	get_viewport().connect('size_changed', self, '_on_viewport_size_changed')

func _on_viewport_size_changed() -> void:
	var size_x := get_viewport().get_size_override().x
	get_tree().call_group('size_normal', 'set', 'visible', size_x >= 1080)
	get_tree().call_group('size_small', 'set', 'visible', size_x < 1080)
		
