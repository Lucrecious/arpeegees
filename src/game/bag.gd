class_name PinBag
extends Control

signal open_animation_started()
signal open_animation_finished()

const SHAKE_DEGREES := 10.0
const SHAKE_PIXELS := 10.0
const SHAKE_BUILD_UP_PER_SEC := 1.0

var _shake := false
var _opened := false

onready var _noise := OpenSimplexNoise.new()
onready var _animation := $'%Animation' as AnimationPlayer
onready var _bag_sprite := $Bag/BagSprite as Node2D
onready var _shoot_hint := $ShootHint as Node2D

func _ready() -> void:
	reset()
	
	_noise.period = .2

func reset() -> void:
	ObjEct.connect_once(self, 'mouse_entered', self, '_on_mouse_entered')
	ObjEct.connect_once(self, 'mouse_exited', self, '_on_mouse_exited')
	_animation.play('RESET')
	_opened = false

func _open() -> void:
	if _opened:
		return
	
	_opened = true
	disconnect('mouse_entered', self, '_on_mouse_entered')
	disconnect('mouse_exited', self, '_on_mouse_exited')
	_end_shake(true)
	_animation.play('shake')
	_shoot_times = 0
	_shoot_offsets.shuffle()
	
	emit_signal('open_animation_started')

var _shoot_times := 0
var _shoot_offsets := [0, 100, -100]
func shoot_star() -> void:
	var star := preload('res://src/resources/arpeegee_pins/shoot_star.tscn').instance() as Node2D
	add_child(star)
	star.global_position = _shoot_hint.global_position
	star.position.x += _shoot_offsets[_shoot_times % _shoot_offsets.size()]
	_shoot_times += 1

func pins_drop_ready(animation_name: String) -> void:
	assert(_animation.current_animation == 'pop')
	emit_signal('open_animation_finished')

func _on_mouse_entered() -> void:
	_start_shake()

func _on_mouse_exited() -> void:
	_end_shake()

func _start_shake() -> void:
	_shake = true

func _end_shake(immediate := false) -> void:
	_shake = false
	
	if not immediate:
		return
	
	_shake_build_up = 0.0
	_bag_sprite.rotation_degrees = 0.0
	_bag_sprite.position = Vector2.ZERO

func _gui_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	
	var mouse_button := event as InputEventMouseButton
	if not mouse_button:
		return
	
	if mouse_button.button_index == BUTTON_LEFT and mouse_button.is_pressed():
		_open()
		return

var _sec_passed := 0.0
var _shake_build_up := 0.0
func _process(delta: float) -> void:
	_sec_passed += delta
	
	var previous_shake_build_up := _shake_build_up
	
	if _shake:
		_shake_build_up += delta * SHAKE_BUILD_UP_PER_SEC
	else:
		_shake_build_up -= delta * SHAKE_BUILD_UP_PER_SEC
	
	_shake_build_up = clamp(_shake_build_up, 0.0, 1.0)
	
	if is_equal_approx(_shake_build_up, 0.0):
		if not is_equal_approx(previous_shake_build_up, 0.0):
			_bag_sprite.position = Vector2.ZERO
			_bag_sprite.rotation_degrees = 0.0
		return
	
	var rotation_amount := min(_noise.get_noise_1d(_sec_passed) / .5, 1.0)
	var position_y_amount := min(_noise.get_noise_1d(_sec_passed + 10_000.0) / .5, 1.0)
	var position_x_amount := min(_noise.get_noise_1d(_sec_passed + 20_000.0) / .5, 1.0)
	_bag_sprite.rotation_degrees = rotation_amount * SHAKE_DEGREES * _shake_build_up
	_bag_sprite.position.x = position_x_amount * SHAKE_PIXELS * _shake_build_up
	_bag_sprite.position.y = position_y_amount * SHAKE_PIXELS * _shake_build_up
