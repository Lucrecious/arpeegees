class_name PinShadow
extends Node2D

const UPDATE_EVERY_SEC := 0.1

var _position_control: Control
var _attached_pin_node: ArpeegeePinNode
var _pin_box: REferenceRect

var _showing_tween: SceneTreeTween

func _init().() -> void:
	add_to_group('size_adapter')

func _ready() -> void:
	visible = false
	scale = Vector2.ZERO
	disappear()

func adapt(size: float) -> void:
	if not _position_control:
		return
	
	var position := _position_control.get_global_rect().get_center()
	global_position = position

func attach_pin(position_control: Control, pin: ArpeegeePinNode) -> void:
	_position_control = position_control
	_attached_pin_node = pin
	_pin_box = NodE.get_child(pin, REferenceRect) as REferenceRect

func appear() -> void:
	visible = true
	if _showing_tween and _showing_tween.is_running():
		_showing_tween.kill()
	
	_showing_tween = create_tween()
	_showing_tween.tween_property(self, 'scale', Vector2.ONE, 0.2)
	_showing_tween.parallel().tween_property(self, 'modulate:a', 1.0, 0.3)

func disappear() -> void:
	if _showing_tween and _showing_tween.is_running():
		_showing_tween.kill()
	
	_showing_tween = create_tween()
	_showing_tween.tween_property(self, 'scale', Vector2.ZERO, 0.2)
	_showing_tween.parallel().tween_property(self, 'modulate:a', 0.0, 0.3)
	_showing_tween.tween_callback(self, 'set', ['visible', false])

var _update_sec := 0.0
var _is_under_player := false
func _process(delta: float) -> void:
	if not _pin_box:
		return
	
	_update_sec += delta
	if _update_sec < UPDATE_EVERY_SEC:
		return
	
	_update_sec = 0.0
	
	var rect := _pin_box.global_rect()
	var check_point := Vector2(global_position.x, rect.get_center().y)
	var is_under_player := rect.has_point(check_point)
	
	if is_under_player == _is_under_player:
		return
	
	_is_under_player = is_under_player
	
	if _is_under_player:
		appear()
	else:
		disappear()
