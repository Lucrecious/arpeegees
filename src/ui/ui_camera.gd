class_name UICamera
extends Node2D


export(NodePath) var _control_path := NodePath()

onready var _control := NodE.get_node(self, _control_path, Control) as Control

func _input(event: InputEvent) -> void:
	var viewport := _control.get_viewport()
	if event is InputEventPanGesture:
		var pan_gesture := event as InputEventPanGesture
		var distance := pan_gesture.delta * 100.0 * Vector2.UP
		viewport.canvas_transform = viewport.canvas_transform.translated(distance)
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.pressed:
			var distance := Vector2.ZERO
			if mouse_button.button_index == BUTTON_WHEEL_UP:
				distance = Vector2.DOWN * 25.0
			elif mouse_button.button_index == BUTTON_WHEEL_DOWN:
				distance = Vector2.UP * 25.0
			
			if not distance.is_equal_approx(Vector2.ZERO):
				viewport.canvas_transform = viewport.canvas_transform.translated(distance)
	
	var rect := _control.get_global_rect()
	var viewport_size := get_viewport_rect().size
	
	if viewport.canvas_transform.origin.y < -rect.end.y + viewport_size.y:
		viewport.canvas_transform.origin.y = -rect.end.y + viewport_size.y

	if viewport.canvas_transform.origin.y > -rect.position.y:
		viewport.canvas_transform.origin.y = -rect.position.y

