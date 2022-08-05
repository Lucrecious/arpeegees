class_name TargetSelector
extends Control

signal target_found(pin)

var _is_finding_target := false

onready var _line := $Line as Line2D
onready var _head := $Head as Polygon2D

var _available_targets := []

func _ready() -> void:
	visible = false

func start(caster: ArpeegeePinNode, available_targets: Array) -> void:
	if not caster:
		assert(false)
		return
	
	if available_targets.empty():
		assert(false)
		return
	
	if _is_finding_target:
		assert(false)
		return
	
	_is_finding_target = true
	_available_targets = available_targets.duplicate()
	
	var bounding_box := NodE.get_child(caster, REferenceRect) as REferenceRect
	if not bounding_box:
		assert(false)
		return
	
	_line.set_point_position(0, bounding_box.global_rect().get_center())
	
	visible = true
	
	get_viewport().warp_mouse(get_viewport_rect().get_center())
	
	place_head(get_viewport_rect().get_center())

func place_head(position: Vector2) -> void:
	_line.set_point_position(1, position)
	
	var angle_from_x := _line.get_point_position(0).angle_to_point(_line.get_point_position(1))
	_head.rotation = angle_from_x + PI
	
	var direction := (_line.get_point_position(1) - _line.get_point_position(0)).normalized()
	_head.position = _line.get_point_position(1) - (direction * 70.0)
	_line.set_point_position(1, _head.position)
	

func _gui_input(event: InputEvent) -> void:
	if not _is_finding_target:
		return
	
	if event is InputEventMouseMotion:
		place_head(get_local_mouse_position())
		return
	
	var mouse_button := event as InputEventMouseButton
	if mouse_button and mouse_button.pressed and mouse_button.button_index == BUTTON_LEFT:
		for pin in _available_targets:
			var bounding_box := NodE.get_child(pin, REferenceRect) as REferenceRect
			if bounding_box.global_rect().has_point(get_local_mouse_position()):
				_finish_finding_target(pin)
				return

func _finish_finding_target(pin: ArpeegeePinNode) -> void:
	visible = false
	_is_finding_target = false
	_available_targets.clear()
	emit_signal('target_found', pin)
