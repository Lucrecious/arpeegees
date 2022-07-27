class_name TitleScreen
extends Control

onready var _bag := $'%Bag' as Control

func _ready() -> void:
	_bag.visible = false

func bounce_in_bag() -> void:
	var original_y := _bag.rect_position.y
	_bag.rect_position.y = original_y + 400.0
	_bag.visible = true
	
	get_tree().create_tween().tween_property(_bag, 'rect_position:y', original_y, 1.0)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
