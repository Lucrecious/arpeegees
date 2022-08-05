class_name PinStatsCanvas
extends Control

export(float) var delay_popup_sec := 1.0

onready var _stats_panel := $StatsPanel as StatPopup
onready var _battle_layer := $'%BattleLayer' as Node2D
onready var _timer := NodE.add_child(self,
		TimEr.one_shot(delay_popup_sec, self, '_on_timeout', true)) as Timer

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if _stats_panel.visible:
			_stats_panel.visible = false
			_stats_panel.set_as_toplevel(false)
		
		_timer.stop()
		_timer.start()

func _on_timeout() -> void:
	_show_stats_if_possible()

func _show_stats_if_possible() -> void:
	var hovering_pin := _get_hovering_pin()
	if not hovering_pin:
		return
	
	_stats_panel.apply_pin(hovering_pin)
	var position := ActionUtils.get_top_right_corner_screen(hovering_pin)
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
