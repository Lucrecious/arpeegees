class_name HeckinGoodSongDancingEffect
extends Node

const RUNS_ALIVE := 2

signal start_turn_effect_finished()
signal text_triggered(translation_key)

var skip_turn_percent := .5
var narration_key := ''

var _dancing_tween: SceneTreeTween
var _is_powered_up := false

onready var runs_alive := RUNS_ALIVE
onready var _pin := NodE.get_ancestor(self, ArpeegeePinNode) as ArpeegeePinNode
onready var _actions := NodE.get_child(_pin, PinActions) as PinActions
onready var _sprite_switcher := NodE.get_child(_pin, SpriteSwitcher) as SpriteSwitcher
onready var _root_sprite := Components.root_sprite(_pin)

func _ready() -> void:
	_actions.connect('action_started', self, '_on_action_started')
	_actions.connect('action_ended', self, '_on_action_ended')
	
	if _actions.is_running_action():
		return
	
	_dancing_tween = _create_dancing_tween()
	_dancing_tween.pause()
	_on_action_ended()

func power_up() -> void:
	_is_powered_up = true
	skip_turn_percent = 0.8

func _on_action_started() -> void:
	_dancing_tween.pause()

func _on_action_ended() -> void:
	_dancing_tween.play()

func _create_dancing_tween() -> SceneTreeTween:
	var animation := create_tween()
	animation.set_loops()
	var material := _root_sprite.material as ShaderMaterial
	
	var skew_stepper := JuiceSteppers.SkewBackAndForth.new(animation, material)
	skew_stepper.offset = 0.07
	skew_stepper.between_offsets_sec = 1.0
	skew_stepper.offset_to_home_sec = 0.0
	skew_stepper.squish_bottom = 0.90
	skew_stepper.squish_top = 1.0
	
	skew_stepper.step()
	skew_stepper.step()
	skew_stepper.step()
	
	return animation

func run_start_turn_effect() -> void:
	var tween := create_tween()
	tween.tween_interval(0.2)
	tween.tween_callback(self, 'emit_signal', ['start_turn_effect_finished'])
	
	runs_alive -= 1
	
	if randf() > skip_turn_percent:
		return
	
	_actions.set_moveless(true)
	emit_signal('text_triggered', narration_key)
	

func run_end_turn_effect() -> void:
	_actions.set_moveless(false)

	if runs_alive > 0:
		return
	
	StatusEffect.queue_free_leave_particles_until_dead(get_parent())
	_reset_sprite()

func _reset_sprite() -> void:
	var shader := _root_sprite.material as ShaderMaterial
	shader.set_shader_param('top_skew', 0.0)
	shader.set_shader_param('squash', 1.0)
