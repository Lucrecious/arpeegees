class_name TargetSelector
extends Control

signal target_found(pin)

var _is_finding_target := false

onready var _line := $Line as Line2D
onready var _head := $Head as Polygon2D

var _available_targets := []
var _select_indicators := []
var _bounding_boxes := []

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
	for t in _available_targets:
		var select_indicator := NodE.get_child(t, SelectIndicater) as SelectIndicater
		var bounding_box := NodE.get_child(t, REferenceRect) as REferenceRect
		
		_select_indicators.push_back(select_indicator)
		_bounding_boxes.push_back(bounding_box)
	
	var bounding_box := NodE.get_child(caster, REferenceRect) as REferenceRect
	if not bounding_box:
		assert(false)
		return
	
	_line.set_point_position(0, bounding_box.global_rect().get_center())
	
	visible = true
	
	place_head(get_global_mouse_position())

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
		for s in _select_indicators:
			s.highlight(false)
		
		for i in _bounding_boxes.size():
			var bounding_box := _bounding_boxes[i] as REferenceRect
			if bounding_box.global_rect().has_point(get_local_mouse_position()):
				var select_indicator := _select_indicators[i] as SelectIndicater
				select_indicator.highlight(true)
		
		place_head(get_local_mouse_position())
		return
	
	var mouse_button := event as InputEventMouseButton
	if mouse_button and mouse_button.pressed and mouse_button.button_index == BUTTON_LEFT:
		for i in _available_targets.size():
			var pin := _available_targets[i] as ArpeegeePinNode
			var bounding_box := _bounding_boxes[i] as REferenceRect
			if bounding_box.global_rect().has_point(get_local_mouse_position()):
				_finish_finding_target(pin)
				return

func _finish_finding_target(pin: ArpeegeePinNode) -> void:
	visible = false
	_is_finding_target = false
	
	for s in _select_indicators:
		s.highlight(false)
	
	_available_targets.clear()
	_select_indicators.clear()
	_bounding_boxes.clear()
	emit_signal('target_found', pin)
