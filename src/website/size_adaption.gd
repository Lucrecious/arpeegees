extends Node

func _ready() -> void:
	get_viewport().connect('size_changed', self, '_on_viewport_size_changed')
	_on_viewport_size_changed()

func _on_viewport_size_changed() -> void:
	var size_x := get_viewport().get_size_override().x
	get_tree().call_group('size_adapter', 'adapt', size_x)
		
