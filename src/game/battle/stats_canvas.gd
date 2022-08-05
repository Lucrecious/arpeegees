class_name PinStatsCanvas
extends Control

onready var _stats_panel := $StatsPanel as StatPopup
onready var _battle_layer := $'%BattleLayer' as Node2D

var _current_pin: ArpeegeePinNode
func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return
	
	#if not visible:
	#	return
	
	#if not get_rect().has_point(get_local_mouse_position()):
	#	return
	
	var pin := _get_hovering_pin()
	if pin == _current_pin:
		return
	
	_current_pin = pin
	
	if _current_pin:
		_stats_panel.visible = true
		_stats_panel.set_as_toplevel(true)
		_show_stats(_current_pin)
	else:
		_stats_panel.visible = false
		_stats_panel.set_as_toplevel(false)
		

func _show_stats(pin: ArpeegeePinNode) -> void:
	_stats_panel.apply_pin(pin)
	var position := ActionUtils.get_top_right_corner_screen(pin)
	_stats_panel.rect_position = position
	_stats_panel.visible = true
	_stats_panel.set_as_toplevel(true)

func _get_hovering_pin() -> ArpeegeePinNode:
	var pins := NodE.get_children(_battle_layer, ArpeegeePinNode)
	for p in pins:
		var bounding_box := NodE.get_child(p, REferenceRect) as REferenceRect
		var rect := bounding_box.global_rect()
		var mouse_point := get_global_mouse_position()
		if not rect.has_point(mouse_point):
			continue
		
		return p
	
	return null
