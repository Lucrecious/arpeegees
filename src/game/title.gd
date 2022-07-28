class_name TitleScreen
extends Control

onready var _bag := $'%Bag' as PinBag

func _ready() -> void:
	_bag.visible = false
	_bag.connect('open_animation_finished', self, '_on_pin_bag_opened')

func _on_pin_bag_opened() -> void:
	_spawn_pins()

func _spawn_pins() -> void:
	print('here')

func bounce_in_bag() -> void:
	var original_y := _bag.rect_position.y
	_bag.rect_position.y = original_y + 400.0
	_bag.visible = true
	
	get_tree().create_tween().tween_property(_bag, 'rect_position:y', original_y, 1.0)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
