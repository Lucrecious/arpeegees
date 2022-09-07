class_name SkipTurnStartTurnEffect
extends Node

signal text_triggered(translation_key)
signal start_turn_effect_finished()

const RUNS_ALIVE := 1

export(String) var text_key := ''

var runs_alive := RUNS_ALIVE

onready var _pin := NodE.get_ancestor(self, ArpeegeePinNode) as ArpeegeePinNode
onready var _actions := NodE.get_child(_pin, PinActions) as PinActions

func run_start_turn_effect() -> void:
	var tween := create_tween()
	tween.tween_interval(0.2)
	tween.tween_callback(self, 'emit_signal', ['start_turn_effect_finished'])
	
	runs_alive -= 1
	
	_actions.set_moveless(true)
	if text_key.empty():
		return
	
	emit_signal('text_triggered', text_key)
	

func run_end_turn_effect() -> void:
	_actions.set_moveless(false)

	if runs_alive > 0:
		return
	
	StatusEffect.queue_free_leave_particles_until_dead(get_parent())
