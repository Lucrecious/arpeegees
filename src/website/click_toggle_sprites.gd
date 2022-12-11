extends TextureButton

func _ready() -> void:
	assert(get_child_count() == 2)
	connect('pressed', self, '_on_button_pressed')

var _waiting := false
func _on_button_pressed() -> void:
	if _waiting:
		return
	_waiting = true
	
	VFX.physical_impactv(get_child(0), get_child(0).get_global_mouse_position())
	
	get_child(0).visible = false
	get_child(1).visible = true
	
	yield(get_tree().create_timer(0.6), 'timeout')
	
	get_child(0).visible = true
	get_child(1).visible = false
	_waiting = false

