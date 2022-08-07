class_name PinBag
extends Control

signal open_animation_finished()

const SHAKE_DEGREES := 10.0
const SHAKE_PIXELS := 10.0
const SHAKE_BUILD_UP_PER_SEC := 1.0
const PARTICLE_SPREAD_DEGREES := 15.0

var _shake := false
var _opened := false

onready var _noise := OpenSimplexNoise.new()
onready var _animation := $'%Animation' as AnimationPlayer
onready var _holder := $Holder as Control
onready var _star_particles := $'%StarParticles' as CPUParticles2D
onready var _star_particles_hint := $'%StarParticlesHint' as Node2D

func _ready() -> void:
	connect('mouse_entered', self, '_on_mouse_entered')
	connect('mouse_exited', self, '_on_mouse_exited')
	
	_noise.period = .2

var _shoot_tween: SceneTreeTween
func shoot_particles() -> void:
	if _shoot_tween:
		_shoot_tween.kill()
		_shoot_tween = null
	
	_shoot_tween = get_tree().create_tween()
	
	var angle_amount := rand_range(-1.0, 1.0)
	var rotation_radians := angle_amount * deg2rad(PARTICLE_SPREAD_DEGREES)
	var relative_destination := Vector2.UP.rotated(rotation_radians) * 1000.0
	
	var initial_displacement := Vector2(rand_range(-1.0, 1.0) * ((rect_size.x / 2.0) - 30.0), 0)
	_star_particles.emitting = true
	_star_particles.global_position = _star_particles_hint.global_position + initial_displacement
	_star_particles.global_position.y += 50.0
	
	_shoot_tween.tween_property(_star_particles, 'global_position', _star_particles.global_position + relative_destination, .5)
	_shoot_tween.tween_callback(_star_particles, 'set', ['emitting', false])

func open() -> void:
	if _opened:
		return
	
	_opened = true
	disconnect('mouse_entered', self, '_on_mouse_entered')
	disconnect('mouse_exited', self, '_on_mouse_exited')
	_end_shake(true)
	_animation.play('open')
	
	_animation.connect('animation_finished', self, '_on_animation_finished', [], CONNECT_ONESHOT)

func _on_animation_finished(_1: String) -> void:
	emit_signal('open_animation_finished')

func _on_mouse_entered() -> void:
	_start_shake()

func _on_mouse_exited() -> void:
	_end_shake()

func _start_shake() -> void:
	_shake = true
	_holder.rect_pivot_offset = rect_size / 2.0

func _end_shake(immediate := false) -> void:
	_shake = false
	
	if not immediate:
		return
	
	_shake_build_up = 0.0
	_holder.rect_rotation = 0.0
	_holder.rect_position = Vector2.ZERO

func _gui_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	
	var mouse_button := event as InputEventMouseButton
	if not mouse_button:
		return
	
	if mouse_button.button_index == BUTTON_LEFT and mouse_button.is_pressed():
		open()
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
			_holder.rect_position = Vector2.ZERO
			_holder.rect_rotation = 0.0
		return
	
	var rotation_amount := min(_noise.get_noise_1d(_sec_passed) / .5, 1.0)
	var position_y_amount := min(_noise.get_noise_1d(_sec_passed + 10_000.0) / .5, 1.0)
	var position_x_amount := min(_noise.get_noise_1d(_sec_passed + 20_000.0) / .5, 1.0)
	_holder.rect_rotation = rotation_amount * SHAKE_DEGREES * _shake_build_up
	_holder.rect_position.x = position_x_amount * SHAKE_PIXELS * _shake_build_up
	_holder.rect_position.y = position_y_amount * SHAKE_PIXELS * _shake_build_up
