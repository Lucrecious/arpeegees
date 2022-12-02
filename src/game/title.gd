class_name TitleScreen
extends Control

signal battle_screen_requested()
signal bag_open_finished()

onready var _bag := $'%Bag' as PinBag
onready var _shockwave := $'%Shockwave' as Control
onready var _sounds := NodE.get_child(self, SoundsComponent) as SoundsComponent
var _bag_opened_finished := false

func _ready() -> void:
	_bag.connect('open_animation_started', self, '_on_pin_bag_opened')
	_bag.connect('open_animation_finished', self, '_on_pin_bag_opened_finished')

func reset() -> void:
	_bag.reset()
	_bag_opened_finished = false

func is_bag_opened_finished() -> bool:
	return _bag_opened_finished

func _on_pin_bag_opened_finished() -> void:
	_bag_opened_finished = true
	emit_signal('bag_open_finished')

func _on_bag_exploded() -> void:
	var shader := _shockwave.material as ShaderMaterial
	
	_do_camera_shake_if_possible()
	
	var rect := _bag.get_global_rect()
	
	var sparkle_explosions := VFX.random_sparkle_explosions()
	NodE.add_children(self, sparkle_explosions)
	for s in sparkle_explosions:
		s.global_position = rect.get_center()
	
	var center_ratio := rect.get_center() / _bag.get_viewport_rect().size
	shader.set_shader_param('center', center_ratio)
	
	var radius_tween := create_tween()
	ActionUtils.add_shader_param_interpolation(radius_tween, shader,
			'radius', 0.0, 1.0, 0.55)
	
	var width_tween := create_tween()
	width_tween.tween_interval(0.45)
	ActionUtils.add_shader_param_interpolation(width_tween, shader,
			'width', 0.05, 0.0, 0.2)

func _do_camera_shake_if_possible() -> void:
	var camera := NodE.get_sibling(self, Camera2D, false) as Camera2D
	if not camera:
		return
	
	var camera_shake := NodE.get_child(camera, CameraShake) as CameraShake
	if not camera_shake:
		return
	
	camera_shake.add_trauma(1.0, 1.0)

func _on_pin_bag_opened() -> void:
	emit_signal('battle_screen_requested', 3)

