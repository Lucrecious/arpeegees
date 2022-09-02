extends Node2D


func _ready() -> void:
	var tween := create_tween()
	tween.tween_interval(3.0)
	tween.tween_callback(self, 'queue_free')
