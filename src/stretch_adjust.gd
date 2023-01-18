extends Node

const MIN_STRETCH := 1.5
const MIN_WINDOW_SIZE_X := 1240

var _current_stretch := 1.0

func _ready() -> void:
	get_viewport().connect('size_changed', self, '_on_viewport_size_changed')
	
	_set_stretch(1.5)

func _set_stretch(factor: float) -> void:
	if is_equal_approx(factor, _current_stretch):
		return
	
	_current_stretch = factor
	
	get_tree().set_screen_stretch(
			SceneTree.STRETCH_MODE_DISABLED,
			SceneTree.STRETCH_ASPECT_KEEP_HEIGHT,
			Vector2.ZERO, factor)

func _on_viewport_size_changed() -> void:
	adapt(get_viewport().get_size_override().x)

var _current_size := 0.0
var _is_stretching := false
func adapt(size: float) -> void:
	size = OS.window_size.x
	
	if _is_stretching:
		return
	
	if abs(_current_size - size) < 50:
		return
	
	_current_size = size
	_is_stretching = true
	
	if size > MIN_WINDOW_SIZE_X:
		_set_stretch(MIN_STRETCH)
	else:
		var ratio := size / MIN_WINDOW_SIZE_X
		_set_stretch(ratio * MIN_STRETCH)
	
	_is_stretching = false
