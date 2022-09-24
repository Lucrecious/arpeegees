extends Node

onready var _battle1 := $Battle1 as AudioStreamPlayer
onready var _battle1_default_db := -7.0

func play_theme() -> void:
	_battle1.volume_db = _battle1_default_db
	_battle1.play()

var _fade_out_in: SceneTreeTween
func pause_fade_out() -> void:
	if _fade_out_in:
		_fade_out_in.kill()
		_fade_out_in = null
	
	_fade_out_in = create_tween()
	_fade_out_in.tween_property(_battle1, 'volume_db', -40.0, 1.0)
	_fade_out_in.tween_callback(_battle1, 'set', ['stream_paused', true])

func unpause_fade_in() -> void:
	if _fade_out_in:
		_fade_out_in.kill()
		_fade_out_in = null
	
	_fade_out_in = create_tween()
	_fade_out_in.tween_callback(_battle1, 'set', ['stream_paused', false])
	_fade_out_in.tween_property(_battle1, 'volume_db', _battle1_default_db, 2.0)
