class_name HeckinGoodSongDancingEffect
extends Node

const RUNS_ALIVE := 2

signal text_triggered(translation_key)

var skip_turn_percent := 1.0

onready var runs_alive := RUNS_ALIVE
onready var _pin := NodE.get_ancestor(self, ArpeegeePinNode) as ArpeegeePinNode
onready var _actions := NodE.get_child(_pin, PinActions) as PinActions

func estimated_sec() -> float:
	return NarratorUI.speak_estimate_sec(tr('NARRATOR_HECKIN_GOOD_SONG_MONSTER_DISTRACTED'))

func run_start_turn_effect() -> void:
	if randf() > skip_turn_percent:
		return
	
	_actions.set_moveless(true)
	emit_signal('text_triggered', 'NARRATOR_HECKIN_GOOD_SONG_MONSTER_DISTRACTED')

func run_end_turn_effect() -> void:
	_actions.set_moveless(false)
