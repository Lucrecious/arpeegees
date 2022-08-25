class_name HeckinGoodSongDancingEffect
extends Node

const RUNS_ALIVE := 2

signal start_turn_effect_finished()
signal text_triggered(translation_key)

var skip_turn_percent := .5

onready var runs_alive := RUNS_ALIVE
onready var _pin := NodE.get_ancestor(self, ArpeegeePinNode) as ArpeegeePinNode
onready var _actions := NodE.get_child(_pin, PinActions) as PinActions

func run_start_turn_effect() -> void:
	var tween := create_tween()
	tween.tween_interval(0.2)
	tween.tween_callback(self, 'emit_signal', ['start_turn_effect_finished'])
	
	if randf() > skip_turn_percent:
		return
	
	_actions.set_moveless(true)
	emit_signal('text_triggered', 'NARRATOR_HECKIN_GOOD_SONG_MONSTER_DISTRACTED')

func run_end_turn_effect() -> void:
	_actions.set_moveless(false)
