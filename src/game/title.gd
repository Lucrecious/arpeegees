class_name TitleScreen
extends Control

signal battle_screen_requested()

onready var _bag := $'%Bag' as PinBag

func _ready() -> void:
	_bag.visible = false
	_bag.connect('open_animation_finished', self, '_on_pin_bag_opened')

func _on_pin_bag_opened() -> void:
	emit_signal('battle_screen_requested', 3)

func bounce_in_bag() -> void:
	var original_y := _bag.rect_position.y
	_bag.rect_position.y = original_y - 1000.0
	_bag.visible = true
	
	get_tree().create_tween().tween_property(_bag, 'rect_position:y', original_y, 1.0)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
