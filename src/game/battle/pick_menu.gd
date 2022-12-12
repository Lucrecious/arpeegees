class_name PickMenu
extends Control

signal option_hover_changed()
signal option_picked(index)

onready var _header := $'%Header' as Label
onready var _vbox := $'%VBox' as VBoxContainer
onready var _label_template := $'%LabelTemplate' as Control
onready var _selector := $'%Selector' as Control

var _current_hover_index := -1

func _ready() -> void:
	_label_template.get_parent().remove_child(_label_template)
	_selector.visible = false
	
	connect('mouse_exited', self, '_on_mouse_exited')
	
	_create_selector_tween()
	
	connect('option_hover_changed', self, '_on_option_hover_changed')
	connect('option_picked', self, '_on_option_picked')

func get_hover_index() -> int:
	return _current_hover_index

func _on_option_picked(_index: int) -> void:
	Sounds.play('ConfirmUI')

func _create_selector_tween() -> void:
	var animation := _selector.create_tween()
	animation.set_loops()
	
	var sprite := _selector.get_child(0) as Control
	var original_sprite_position := sprite.rect_position
	
	animation.tween_property(sprite, 'rect_position:x', original_sprite_position.x - 5.0, 1.0)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	animation.tween_callback(sprite, 'set', ['rect_position', original_sprite_position])

func _on_option_hover_changed() -> void:
	if _current_hover_index != -1:
		Sounds.play('SelectingUI')
	_update_selector()

func _update_selector() -> void:
	if _current_hover_index == -1:
		_selector.visible = false
		return
	
	_selector.visible = true
	
	var control := _vbox.get_child(_current_hover_index) as Control
	var rect := control.get_global_rect()
	var selector_position := Vector2(rect.position.x, rect.get_center().y)
	_selector.rect_global_position = selector_position - _selector.rect_pivot_offset

func set_header_text(value: String) -> void:
	_header.text = value

func add_option(value: String) -> int:
	var label_template := _label_template.duplicate() as HBoxContainer
	var label := label_template.get_node('Label') as Label
	var icon := label_template.get_node('Control/Icon') as TextureRect
	icon.get_parent().rect_min_size = Vector2.ZERO
	icon.texture = null
	
	label.text = value
	_vbox.add_child(label_template)
	return label_template.get_index()

func set_icon(index: int, texture: Texture) -> void:
	var icon := _vbox.get_child(index).get_node('Control/Icon') as TextureRect
	icon.get_parent().rect_min_size = Vector2.ONE * 32.0
	icon.texture = texture

func clear() -> void:
	for child in _vbox.get_children():
		child.queue_free()

func _on_mouse_exited() -> void:
	reset_hover_index()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		update_hover_index()
		return
	
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.pressed and mouse_button.button_index == BUTTON_LEFT:
			if _current_hover_index == -1:
				return
			
			emit_signal('option_picked', _current_hover_index)
			return

func reset_hover_index() -> void:
	if _current_hover_index == -1:
		return
	
	_current_hover_index = -1
	emit_signal('option_hover_changed')

func update_hover_index(keep_last := true, force_notification := false) -> void:
	var hover_index := _current_hover_index if keep_last else -1
	for c in _vbox.get_children():
		var label_template := c as HBoxContainer
		var rect := label_template.get_global_rect()
		var mouse_position := label_template.get_global_mouse_position()
		if not rect.has_point(mouse_position):
			continue
		
		hover_index = label_template.get_index()
		break
	
	if not force_notification and hover_index == _current_hover_index:
		return
	
	_current_hover_index = hover_index
	emit_signal('option_hover_changed')
