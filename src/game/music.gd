extends Node

onready var _battle1 := $Battle1 as AudioStreamPlayer
onready var _battle1_default_db := -7.0

func play_theme() -> void:
	_battle1.volume_db = _battle1_default_db
	_battle1.play()

func pause_fade_out() -> void:
	var fade_out := create_tween()
	fade_out.tween_property(_battle1, 'volume_db', -40.0, 1.0)
	fade_out.tween_callback(_battle1, 'set', ['stream_paused', true])

func unpause_fade_in() -> void:
	var fade_in := create_tween()
	fade_in.tween_callback(_battle1, 'set', ['stream_paused', false])
	fade_in.tween_property(_battle1, 'volume_db', _battle1_default_db, 2.0)
