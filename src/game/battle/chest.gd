extends Control

onready var _top := $Chest/Bottom/Top as Control
onready var _glow := $Chest/Bottom/Glow as Control

func _ready() -> void:
	_glow.visible = false
	_glow.modulate.a = 0.0
	_top.visible = true

func run() -> void:
	var animation := create_tween()
	animation.tween_interval(1.5)
	
	animation.tween_property(_top, 'rect_position', Vector2.UP * 150.0, 1.0)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	animation.parallel().tween_callback(_glow, 'set', ['visible', true])
	animation.parallel().tween_property(_glow, 'modulate:a', 1.0, 0.5)
