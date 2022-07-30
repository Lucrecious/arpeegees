class_name PinActionButton
extends Button

signal label_text_changed()
signal icon_name_changed()

export(String) var label_text := '' setget _label_text_set
func _label_text_set(value: String) -> void:
	if value == label_text:
		return
	
	label_text = value
	emit_signal('label_text_changed')

export(String) var icon_name := '' setget _icon_name_set
func _icon_name_set(value: String) -> void:
	if value == icon_name:
		return
	
	icon_name = value
	emit_signal('icon_name_changed')

onready var _icon := $'%Icon' as TextureRect
onready var _label := $'%Label' as Label

func _ready() -> void:
	connect('label_text_changed', self, '_on_label_text_changed')
	_on_label_text_changed()
	
	connect('icon_name_changed', self, '_on_icon_name_changed')
	_on_icon_name_changed()

func _on_label_text_changed() -> void:
	_update_label_text()

func _update_label_text() -> void:
	_label.text = label_text

func _on_icon_name_changed() -> void:
	_update_icon()

func _update_icon() -> void:
	_icon.texture = Icons.get(icon_name)
