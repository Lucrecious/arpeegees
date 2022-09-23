extends Node

const min_stretch := 1.5
const max_stretch := 3.0

onready var _boundaries := NodE.get_sibling_by_name(self, 'Main')\
		.get_node('Boundaries') as Control
onready var _original_size_x := _boundaries.rect_size.x

func _ready() -> void:
	_set_stretch(1.5)
	#get_viewport().connect('size_changed', self, '_on_size_changed')
	#_update_stretch()

func _on_size_changed() -> void:
	_update_stretch()

var _current_stretch := 1.0
func _update_stretch():
	OS.min_window_size = Vector2(300.0, 100.0)
	var factor := _boundaries.get_viewport_rect().size.x / _boundaries.rect_size.x
	factor *= _current_stretch
	factor = clamp(factor, min_stretch, max_stretch)
	
	_set_stretch(factor)

func _set_stretch(factor: float) -> void:
	if is_equal_approx(factor, _current_stretch):
		return
	
	_current_stretch = factor
	
	get_tree().set_screen_stretch(
			SceneTree.STRETCH_MODE_DISABLED,
			SceneTree.STRETCH_ASPECT_KEEP_HEIGHT,
			Vector2(300.0, 100.0), factor)
