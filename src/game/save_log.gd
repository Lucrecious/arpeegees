extends Button

onready var _alert_dialog := NodE.get_sibling_by_name(self, 'ErrorDialog') as AcceptDialog

func _ready() -> void:
	assert(_alert_dialog)
	
	connect('pressed', self, '_on_pressed')
	
	_alert_dialog.get_label().align = Label.ALIGN_CENTER
	_alert_dialog.get_label().valign = Label.VALIGN_CENTER

func _on_pressed() -> void:
	#_file_dialog.popup_centered()
	Logger.flush_buffers()
	
	if OS.get_name() == 'HTML5':
		var data := PoolStringArray(Logger.get_memory()).join('\\n')
		#var ret = JavaScript.eval("save_file('%s')" % data)
		#print("eval returns: ", ret)
	else:
		print('TODO: print log')
		return
