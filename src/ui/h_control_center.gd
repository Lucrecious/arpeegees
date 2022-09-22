extends Node

export(NodePath) var _center_on_control_path := NodePath()

onready var _center_on_control := NodE.get_node(
		self, _center_on_control_path, Control) as Control
onready var _camera := get_parent() as Camera2D

func _ready() -> void:
	assert(_camera)
	
	get_viewport().connect('size_changed', self, '_on_viewport_size_changed')

func _on_viewport_size_changed() -> void:
	var rect := _center_on_control.get_global_rect()
	
	_camera.global_position.x = rect.get_center().x
	
