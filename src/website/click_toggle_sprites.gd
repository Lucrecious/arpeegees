extends TextureButton

var _blinking: SceneTreeTween
func _ready() -> void:
	assert(get_child_count() == 2)
	connect('pressed', self, '_on_button_pressed')
	connect('mouse_entered', self, '_on_mouse_entered')
	connect('mouse_exited', self, '_on_mouse_exited')
	
	_blinking = create_tween()
	_blinking.tween_property(self, 'modulate', Color.white, 0.2)\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	_blinking.tween_property(self, 'modulate', Color.lightgray, 0.2)\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	_blinking.set_loops()
	_blinking.pause()

var _mouse_inside := false
var _playing_toggle := false

func _on_mouse_entered() -> void:
	_mouse_inside = true
	
	if _playing_toggle:
		return
	
	_blinking.play()

func _on_mouse_exited() -> void:
	_mouse_inside = false
	
	if _playing_toggle:
		return
	
	_blinking.stop()
	modulate = Color.white

func _on_button_pressed() -> void:
	if _playing_toggle:
		return
	
	_blinking.stop()
	modulate = Color.white
	
	_playing_toggle = true
	
	VFX.physical_impactv(get_child(0), get_child(0).get_global_mouse_position())
	
	get_child(0).visible = false
	get_child(1).visible = true
	
	yield(get_tree().create_timer(0.6), 'timeout')
	
	get_child(0).visible = true
	get_child(1).visible = false
	_playing_toggle = false
	
	if _mouse_inside:
		_on_mouse_entered()

