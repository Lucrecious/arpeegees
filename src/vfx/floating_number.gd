class_name FloatingNumber
extends Node2D

export(int) var value := 0

func _ready() -> void:
	var label := $CenterContainer/Label as Label
	if value > 0:
		label.modulate = Color.lightgreen
		label.text = '+%d' % value
	else:
		label.modulate = Color.lightcoral
		label.text = '%d' % value

func float_up(float_up_pixels := 100.0) -> void:
	scale = Vector2.ONE * 2.0
	var tween := create_tween()
	tween.tween_property(self, 'scale', Vector2.ONE, .2)
	tween.parallel().tween_property(self, 'position:y', position.y - float_up_pixels, 1.0)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.tween_interval(1.5)
	tween.tween_property(self, 'modulate:a', 0.0, 1.0)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_callback(self, 'queue_free')
