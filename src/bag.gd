class_name CardBag
extends Control

signal opened()

const SHAKE_DEGREES := 10.0

var _shake := false
var _opened := false

onready var _noise := OpenSimplexNoise.new()
onready var _animation := $'%Animation' as AnimationPlayer
onready var _holder := $Holder as Control

func _ready() -> void:
	connect('mouse_entered', self, '_on_mouse_entered')
	connect('mouse_exited', self, '_on_mouse_exited')
	
	_noise.period = .25

func open() -> void:
	if _opened:
		return
	
	_opened = true
	disconnect('mouse_entered', self, '_on_mouse_entered')
	disconnect('mouse_exited', self, '_on_mouse_exited')
	_end_shake()
	_animation.play('open')
	emit_signal('opened')

func _on_mouse_entered() -> void:
	_start_shake()

func _on_mouse_exited() -> void:
	_end_shake()

func _start_shake() -> void:
	_shake = true

func _end_shake() -> void:
	_shake = false
	_holder.rect_rotation = 0.0

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
func _process(delta: float) -> void:
	_sec_passed += delta
	
	if not _shake:
		return
	
	var shake_amount := min(_noise.get_noise_1d(_sec_passed) / .5, 1.0)
	_holder.rect_rotation = shake_amount * SHAKE_DEGREES
