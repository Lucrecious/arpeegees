class_name GameFrameWebInterop
extends Node

const WebDict := {
	is_on_mobile = false
}

var _on_entered_screen_js_callback := JavaScript.create_callback(self, '_on_entered_screen')
var _on_exited_screen_js_callback := JavaScript.create_callback(self, '_on_exited_screen')

func _ready() -> void:
	if OS.get_name() != 'HTML5':
		return
	
	var document := JavaScript.get_interface('document')
	var canvas = document.getElementById('canvas')
	canvas.addEventListener('enteredscreen', _on_entered_screen_js_callback)
	canvas.addEventListener('exitedscreen', _on_exited_screen_js_callback)
	
	WebDict.is_on_mobile = document.isOnMobile()

func _on_entered_screen(args) -> void:
	_mute_play_audio(false)

func _on_exited_screen(args) -> void:
	_mute_play_audio(true)

var _mute_play_tween: SceneTreeTween
func _mute_play_audio(mute: bool) -> void:
	var master_index := AudioServer.get_bus_index('All')
	#var initial_db := _get_volume_on_bus(master_index)
	
	if _mute_play_tween:
		_mute_play_tween.kill()
		_mute_play_tween = null
	
	_mute_play_tween = create_tween()
	if mute:
		_mute_play_tween.tween_method(self, '_set_volume_on_bus', 0.0, -30.0, 1.0, [master_index])\
				.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		_mute_play_tween.tween_callback(AudioServer, 'set_bus_mute', [master_index, true])
	else:
		_mute_play_tween.tween_callback(AudioServer, 'set_bus_mute', [master_index, false])
		_mute_play_tween.tween_method(self, '_set_volume_on_bus', -30.0, 0.0, 1.0, [master_index])\
				.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
func _set_volume_on_bus(volume_db: float, index: int) -> void:
	AudioServer.set_bus_volume_db(index, volume_db)

func _get_volume_on_bus(index: int) -> float:
	return AudioServer.get_bus_volume_db(index)
