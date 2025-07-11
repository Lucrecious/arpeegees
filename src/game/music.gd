extends Node

onready var _battle1 := $Battle1 as AudioStreamPlayer
onready var _pickup := $PickUp as AudioStreamPlayer
onready var _battle1_default_db := -7.0

func play_theme() -> void:
	_battle1.volume_db = _battle1_default_db
	_pickup.volume_db = _battle1_default_db
	
	_pickup.play()
	
	yield(get_tree().create_timer(0.4), 'timeout')
	
	_battle1.play()

func play_victory() -> void:
	_play_ending($Victory)

func play_defeat() -> void:
	_play_ending($Defeat)

func _play_ending(sound: AudioStreamPlayer) -> void:
	pause_fade_out(true)
	sound.play()

func stop_theme() -> void:
	var stop_music := true
	pause_fade_out(stop_music)

var _fade_out_in: SceneTreeTween
func pause_fade_out(stop := false) -> void:
	if _fade_out_in:
		_fade_out_in.kill()
		_fade_out_in = null
	
	_fade_out_in = create_tween()
	_fade_out_in.tween_property(_battle1, 'volume_db', -40.0, 1.0)
	if not stop:
		_fade_out_in.tween_callback(_battle1, 'set', ['stream_paused', true])
	else:
		_fade_out_in.tween_callback(_battle1, 'stop')

func unpause_fade_in() -> void:
	if _fade_out_in:
		_fade_out_in.kill()
		_fade_out_in = null
	
	_fade_out_in = create_tween()
	_fade_out_in.tween_callback(_battle1, 'set', ['stream_paused', false])
	_fade_out_in.tween_property(_battle1, 'volume_db', _battle1_default_db, 2.0)
