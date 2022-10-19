class_name PinShadow
extends Node2D

const UPDATE_EVERY_SEC := 0.1

var _position_control: Control
var _showing_tween: SceneTreeTween

onready var _area := $Area as Area2D
onready var _shadow_sprite := $ShadowSprite as Node2D

func _init().() -> void:
	add_to_group('size_adapter')

func _ready() -> void:
	_shadow_sprite.visible = false
	_shadow_sprite.scale = Vector2.ZERO
	disappear()

func adapt(_size: float) -> void:
	if not _position_control:
		return
	
	var position := _position_control.get_global_rect().get_center()
	global_position = position

func attach_position(position_control: Control) -> void:
	_position_control = position_control
	
	_area.connect('area_entered', self, '_on_area_entered')
	_area.connect('area_exited', self, '_on_area_exited')
	adapt(0)

func _on_area_entered(_area) -> void:
	appear()

func _on_area_exited(_area) -> void:
	disappear()

func appear() -> void:
	_shadow_sprite.visible = true
	if _showing_tween and _showing_tween.is_running():
		_showing_tween.kill()
	
	_showing_tween = create_tween()
	_showing_tween.tween_property(_shadow_sprite, 'scale', Vector2.ONE, 0.2)
	_showing_tween.parallel().tween_property(_shadow_sprite, 'modulate:a', 1.0, 0.3)

func disappear() -> void:
	if _showing_tween and _showing_tween.is_running():
		_showing_tween.kill()
	
	_showing_tween = create_tween()
	_showing_tween.tween_property(_shadow_sprite, 'scale', Vector2.ZERO, 0.2)
	_showing_tween.parallel().tween_property(_shadow_sprite, 'modulate:a', 0.0, 0.3)
	_showing_tween.tween_callback(_shadow_sprite, 'set', ['visible', false])
