class_name SelectIndicater
extends Node

onready var _sprite := NodE.get_sibling(self, RootSprite) as RootSprite
onready var _shader := _sprite.material as ShaderMaterial

var _highlighted := false

func highlight(value: bool) -> void:
	if value == _highlighted:
		return
	
	_highlighted = value
	
	if _highlighted:
		_shader.set_shader_param('line_thickness', 15.0)
	else:
		_shader.set_shader_param('line_thickness', 0.0)
