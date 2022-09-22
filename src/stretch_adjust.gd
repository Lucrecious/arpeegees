extends Node

const stretch := 1.5

func _ready() -> void:
	OS.min_window_size = Vector2(300.0, 100.0)
	get_tree().set_screen_stretch(
			SceneTree.STRETCH_MODE_DISABLED,
			SceneTree.STRETCH_ASPECT_KEEP_HEIGHT,
			Vector2(300.0, 100.0), stretch)
